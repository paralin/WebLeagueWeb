'use strict'

service = null

Function::property = (prop, desc) ->
  Object.defineProperty @prototype, prop, desc

class NetworkService
  disconnected: true
  connecting: false
  doReconnect: true

  reconnTimeout: null
  attempts: 0
  status: "Disconnected from the server."

  _activeMatch: null
  @property "activeMatch",
    get: ->
      return null if !@_activeMatch?
      _.findWhere @availableGames, {Id: @_activeMatch.Id}

  activeChallenge: null
  activeResult: null
  hasChallenge: false
  chats: {}

  members: {}

  liveMatches: []
  availableGames: []

  adminMatches: []

  constructor: (@scope, @timeout, @safeApply, @leagueStore, @interval)->
    $.connection.hub.connectionSlow =>
      # Don't display anything yet
      @status = "Connection is slow, trying to re-establish..."
    $.connection.hub.starting =>
      @status = "Attempting to connect..."
    $.connection.hub.reconnecting =>
      @connecting = true
      @disconnected = true
      @status = "Attempting to reconnect..."
    $.connection.hub.reconnected =>
      @connecting = false
      @disconnected = false
      @attempts = 0
      @status = "Reconnected to the server."
    $.connection.hub.error (err)=>
      console.log "SignalR error: "+err
    $.connection.hub.disconnected =>
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
    admin:
      onopen: ->
        @admin.invoke('getgamelist').then (ms)=>
          @safeApply @scope, =>
            @adminMatches.length = 0
            for game in ms
              @adminMatches[@adminMatches.length] = game
      availablegameupd: (upd)->
        for match in upd.matches
          idx = _.findIndex @adminMatches, {Id: match.Id}
          if idx isnt -1
            @adminMatches[idx] = match
          else
            @adminMatches[@adminMatches.length] = match
      availablegamerm: (upd)->
        for id in upd.ids
          idx = _.findIndex @adminMatches, {Id: id}
          if idx isnt -1
            @adminMatches.splice idx, 1
      clearsetupmatch: (upd)->
        idx = _.findIndex @adminMatches, {Id: upd.Id}
        if idx isnt -1
          @adminMatches[idx].Setup = null
      setupsnapshot: (upd)->
        idx = _.findIndex @adminMatches, {Id: upd.Id}
        if idx isnt -1
          @adminMatches[idx].Setup = upd
      infosnapshot: (upd)->
        idx = _.findIndex @adminMatches, {Id: upd.Id}
        if idx isnt -1
          @adminMatches[idx].Info = upd
      matchplayerssnapshot: (upd)->
        match = _.find @adminMatches, {Id: upd.Id}
        if match?
          match.Players = upd.Players
    matches:
      onLobbyReady: ->
        service.scope.$broadcast "lobbyReady"
      onKickedFromMatch: ->
        service.scope.$broadcast "kickedFromSG"
      refreshLeagues: ->
        service.leagueStore.refresh()
      matchSnapshot: (match)->
        service._activeMatch = match
        idx = _.findIndex service.availableGames, {Id: match.Id}
        if idx isnt -1
          service.availableGames[idx] = match
        else
          match.PlayersOpen = true
          service.availableGames[service.availableGames.length] = match
      challengeSnapshot: (match)->
        service.activeChallenge = match
        service.hasChallenge = service.activeChallenge?
        service.scope.$broadcast 'challengeSnapshot', service.activeChallenge
      # v2
      clearChallenge: ->
        service.activeChallenge = null
        service.hasChallenge = false
        service.scope.$broadcast 'challengeSnapshot', null
      systemMessage: (title, message)->
        console.log "System notification: #{title} #{message}"
        swal
          title: title
          text: message
          type: "info"
      resultSnapshot: (snp)->
        service.activeResult = snp
        service.scope.$broadcast "resultSnapshot", null
      matchPlayersSnapshot: (upd)->
        match = _.findWhere service.availableGames, {Id: upd.Id}
        if !match?
          console.log "Received match player snapshot for an unknown match #{upd.Id}"
        else
          match.Players = upd.Players
      availableGameUpdate: (upd)->
        for match in upd
          idx = _.findIndex service.availableGames, {Id: match.Id}
          if idx isnt -1
            service.availableGames[idx] = match
          else
            match.PlayersOpen = true
            service.availableGames[service.availableGames.length] = match
            service.scope.$broadcast "newGameHosted", match
      availableGameRemove: (upd)->
        for id in upd
          idx = _.findIndex service.availableGames, {Id: id}
          if idx isnt -1
            [game] = service.availableGames.splice idx, 1
            service.scope.$broadcast "gameCanceled", game
      clearSetup: (id)->
        idx = _.findIndex service.availableGames, {Id: id}
        if idx isnt -1
          service.availableGames[idx].Setup = null
      setupSnapshot: (upd)->
        idx = _.findIndex service.availableGames, {Id: upd.Id}
        if idx isnt -1
          service.availableGames[idx].Setup = upd
      infoSnapshot: (snap)->
        #find the match
        match = _.findWhere service.availableGames, {Id: snap.Id}
        if match?
          match.Info = snap
    chat:
      globalmembersnap: (upd)->
        for memb in upd.members
          service.members[memb.SteamID] = memb
      globalmemberupdate: (upd)->
        memb = service.members[upd.id]
        if memb?
          memb[upd.key] = upd.value
      globalmemberrm: (upd)->
        delete service.members[upd.id]
      onchatmessage: (upd)->
        #console.log upd
        chat = null
        if upd.ChatId
          chat = service.chatByID upd.ChatId
        else
          chat = service.chatByName upd.Channel
        if !chat?
          console.log "Message for unknown chat #{upd.ChatId || upd.Channel}"
        else
          service.scope.$broadcast "chatMessage", upd, chat
          chat.messages.push
            member: upd.Member
            msg: upd.Text
            name: if upd.Member is "system" then "system" else service.members[upd.Member].Name
            date: upd.Date
            Auto: upd.Auto
          if chat.messages.length > 150
            chat.messages.splice 0, 1
      #add or remove a chat channel
      channelUpdate: (chan)->
        echan = service.chats[chan.Id]
        unless echan?
          chan.messages = []
          service.chats[chan.Id] = chan
          service.scope.$broadcast 'chatChannelAdd'
        else
          _.merge echan, chan
      channelRemove: (id)->
        delete service.chats[id]
        service.scope.$broadcast 'chatChannelRm'
      #add or remove a chat member
      chatMemberAdded: (id, members)->
        chat = service.chatByID id
        if !chat?
          console.log "WARN -> chat member(s) added to unknown chat"
          console.log upd
        else
          for memb in members
            chat.Members.push memb unless memb in chat.Members
        service.scope.$broadcast 'chatMemberAdd'
      chatMemberRemoved: (id, members)->
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
        @[name] = cont = $.connection[name]
        continue unless cont?
        for cbn, cb of cbs
          cont.client[cbn] = cb

      safeApply = @safeApply
      scope = @scope
      serv = @
      $.connection.hub.start().done =>
        @connecting = false
        console.log "Connected to the network!"
        if @reconnTimeout?
          @timeout.cancel(@reconnTimeout)
          @reconnTimeout = null
        safeApply scope, =>
          @disconnected = false
          @status = "Connected to the network."
          @attempts = 0
          @chats = {}
          @_activeMatch = null
          @activeResult = null
          @adminMatches.length = 0
          @activeChallenge = null

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
  window.service = service
