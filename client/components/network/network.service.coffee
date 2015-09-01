'use strict'

s = service = null

Function::property = (prop, desc) ->
  Object.defineProperty @prototype, prop, desc

class NetworkService
  disconnected: true
  connecting: false
  doReconnect: true

  reconnTimeout: null
  attempts: 0
  status: "Disconnected from the server."

  @property "activeMatch",
    get: ->
      _.find @availableGames, (game)->
        for plyr in game.Players
          return true if plyr.SID is service.user.steam.steamid
        false

  activeChallenge: null
  activeResult: null
  hasChallenge: false
  chats: {}
  oldChats: null

  members: {}

  liveMatches: []
  availableGames: []

  adminMatches: []

  sa: (cb)->
    @safeApply @scope, ->
      cb()

  constructor: (@scope, @timeout, @safeApply, @leagueStore, @interval)->
    $.connection.hub.logging = true
    $.connection.hub.connectionSlow => s.sa =>
      #@disconnected = true
      #@connecting = true
      #@status = "Connection is slow, trying to re-establish..."
      console.log "Connection slow event."
    $.connection.hub.starting => s.sa =>
      @disconnected = true
      @connecting = true
      @status = "Attempting to connect..."
    $.connection.hub.reconnecting => s.sa =>
      # Causes problems.
      #@connecting = true
      #@disconnected = true
      #@status = "Attempting to reconnect..."
      @disconnect()
      @reconnect()
    $.connection.hub.reconnected => s.sa =>
      @connecting = false
      @disconnected = false
      @attempts = 0
      @status = "Reconnected to the server."
    $.connection.hub.error (err)=> s.sa =>
      console.log "SignalR error: "+err
    $.connection.hub.disconnected => s.sa =>
      @connecting = false
      console.log "Disconnected from the network..."
      @disconnect()
      @reconnect()

  disconnect: ->
    @connecting = false
    $.connection.hub.stop()
    if @reconnTimeout?
      @timeout.cancel(@reconnTimeout)
      @reconnTimeout = null
    @disconnected = true

  reconnect: ->
    if @doReconnect
      if !@reconnTimeout?
        @safeApply @scope, =>
          @disconnected = true
          @status = "Reconnecting in 3 seconds, attempt ##{@attempts}..."
        @reconnTimeout = @timeout(=>
          @reconnTimeout = null
          @connect()
        , 3000)
    else
      console.log "Not reconnecting."

  handlers:
    admin: {}
    matches:
      onLobbyReady: -> s.sa -> s.scope.$broadcast "lobbyReady"
      onKickedFromMatch: -> s.sa -> s.scope.$broadcast "kickedFromSG"
      refreshLeagues: -> s.sa -> s.leagueStore.refresh()
      challengeSnapshot: (match)-> s.sa ->
        service.activeChallenge = match
        service.hasChallenge = service.activeChallenge?
        service.scope.$broadcast 'challengeSnapshot', service.activeChallenge
      # v2
      clearChallenge: -> s.sa ->
        service.activeChallenge = null
        service.hasChallenge = false
        service.scope.$broadcast 'challengeSnapshot', null
      systemMessage: (title, message)-> s.sa ->
        console.log "System notification: #{title} #{message}"
        swal
          title: title
          text: message
          type: "info"
      resultSnapshot: (snp)-> s.sa ->
        service.activeResult = snp
        service.scope.$broadcast "resultSnapshot", null
      matchPlayersSnapshot: (id, players)-> s.sa ->
        match = _.findWhere service.availableGames, {Id: id}
        if !match?
          console.log "Received match player snapshot for an unknown match #{id}"
        else
          match.Players = players
      availableGameUpdate: (upd)-> s.sa ->
        for match in upd
          idx = _.findIndex service.availableGames, {Id: match.Id}
          if idx isnt -1
            service.availableGames[idx] = match
          else
            match.PlayersOpen = true
            service.availableGames[service.availableGames.length] = match
            service.scope.$broadcast "newGameHosted", match
      availableGameRemove: (upd)-> s.sa ->
        for id in upd
          idx = _.findIndex service.availableGames, {Id: id}
          if idx isnt -1
            [game] = service.availableGames.splice idx, 1
            service.scope.$broadcast "gameCanceled", game
      clearSetup: (id)-> s.sa ->
        idx = _.findIndex service.availableGames, {Id: id}
        if idx isnt -1
          service.availableGames[idx].Setup = null
      setupSnapshot: (upd)-> s.sa ->
        idx = _.findIndex service.availableGames, {Id: upd.Id}
        if idx isnt -1
          service.availableGames[idx].Setup = upd
      infoSnapshot: (snap)-> s.sa ->
        #find the match
        match = _.findWhere service.availableGames, {Id: snap.Id}
        if match?
          match.Info = snap
    chat:
      globalMemberSnapshot: (upd)-> s.sa ->
        for memb in upd
          service.members[memb.SteamID] = memb
      globalMemberUpdate: (id, key, value)-> s.sa ->
        memb = service.members[id]
        if memb?
          memb[key] = value
      globalMemberRemove: (upd)-> s.sa -> delete service.members[upd.id]
      onChatMessage: (chatid, memberid, text, isservice, time, chatname)->
        s.sa ->
          chat = service.chatByID chatid
          if !chat?
            console.log "Message for unknown chat #{chatid}"
          else
            service.scope.$broadcast "chatMessage", chatid, memberid, text, isservice, time, chatname
            chat.messages.push
              member: memberid
              msg: text
              name: if memberid is "system" then "system" else service.members[memberid].Name
              date: time
              Auto: isservice
            if chat.messages.length > 150
              chat.messages.splice 0, 1
      #add or remove a chat channel
      channelUpdate: (chan)-> s.sa ->
        echan = service.chats[chan.Id]
        unless echan?
          chan.messages = []
          if service.oldChats?
            oldChat = _.findWhere(_.values(service.oldChats), {Name: chan.Name})
            if oldChat?
              chan.messages = _.filter oldChat.messages, (message)->
                !message.Auto
              if chan.messages.length > 0
                chan.messages.push
                  member: "system"
                  msg: "-- reconnected --"
                  name: "system"
                  date: new Date()
                  Auto: true
          service.chats[chan.Id] = chan
          service.scope.$broadcast 'chatChannelAdd'
        else
          _.merge echan, chan
      channelRemove: (id)-> s.sa ->
        delete service.chats[id]
        service.scope.$broadcast 'chatChannelRm'
      #add or remove a chat member
      chatMemberAdded: (id, members)-> s.sa ->
        chat = service.chatByID id
        if !chat?
          console.log "WARN -> chat member(s) added to unknown chat"
          console.log upd
        else
          for memb in members
            chat.Members.push memb unless memb in chat.Members
        service.scope.$broadcast 'chatMemberAdd'
      chatMemberRemoved: (id, members)-> s.sa ->
        chat = service.chatByID id
        if !chat?
          console.log "WARN -> chat member(s) removed from unknown chat"
          console.log members
        else
          for memb in members
            idx = chat.Members.indexOf memb
            continue if idx is -1
            chat.Members.splice idx, 1
        service.scope.$broadcast 'chatMemberRm'

  connect: ->
    if !@disconnected || @connecting
      return
    @attempts += 1

    if !@oldChats?
      @oldChats = @chats
    @chats = {}
    @activeResult = null
    @adminMatches.length = 0
    @activeChallenge = null
    @availableGames.length = 0
    if !@server?
      console.log "No server info yet."
      @status = "Waiting for server info..."
    else
      @connecting = true
      console.log "Connecting to #{@server}..."

      $.connection.hub.url = @server
      $.connection.hub.qs =
        token: @token

      for name, cbs of @handlers
        cont = $.connection[name]
        @[name] = cont.server
        console.log name
        unless cont?
          continue
        for cbn, cb of cbs
          cont.client[cbn] = cb

      safeApply = @safeApply
      scope = @scope
      serv = @
      $.connection.hub.start().done => s.sa =>
        console.log "Connected to the network!"
        @oldChats = null
        if @reconnTimeout?
          @timeout.cancel(@reconnTimeout)
        @reconnTimeout = null
        @connecting = false
        @disconnected = false
        @status = "Connected to the network."
        @attempts = 0

  chatByID: (id)->
    @chats[id]

  chatByName: (name)->
    _.findWhere(_.values(@chats), {Name: name})

  fetchMatches: ->
    #return
    @matches.invoke('getpublicgamelist').then (ms)=>
      @safeApply @scope, =>
        @liveMatches.length = 0
        for game in ms
          @liveMatches[@liveMatches.length] = game
      @matches.invoke('getavailablegamelist').then (ms)=>
        @safeApply @scope, =>
          #use the same array
          @availableGames.length = 0
          for game in ms
            @availableGames[@availableGames.length] = game

angular.module('webleagueApp').factory 'Network', ($rootScope, $timeout, Auth, LeagueStore, safeApply, $interval) ->
  service = new NetworkService $rootScope, $timeout, safeApply, LeagueStore, $interval
  checkLogin = ->
    console.log "check login"
    Auth.getLoginStatus (currentUser, currentToken, currentServer)->
      service.token = currentToken
      service.server = currentServer
      service.user = currentUser
      if currentUser?
        service.connect()
      else
        service.disconnect()
  $rootScope.$on 'authStatusChange', ->
    checkLogin()
  checkLogin()
  $(window).unload ->
    service.disconnect()
  window.service = s = service
