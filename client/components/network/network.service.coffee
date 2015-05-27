'use strict'

Function::property = (prop, desc) ->
  Object.defineProperty @prototype, prop, desc

class NetworkService
  disconnected: true
  doReconnect: true
  connecting: false
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

  constructor: (@scope, @timeout, @safeApply, @leagueStore)->
  disconnect: ->
    @connecting = false
    if @conn?
      @conn.disconnect()
      @conn = null
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

  methods:
    admin:
      killmatch: (mid)->
        console.log "kill match #{mid}"
        @invoke("killmatch", {Id: mid})
    matches:
      finalizematch: ->
        @invoke("finalizematch").then (err)->
          return if !err?
          new PNotify
            title: "Can't Start Match"
            text: err
            type: "error"
          return
      pickPlayer: (sid)->
        @invoke "pickPlayer", {SID: sid}
      kickPlayer: (sid)->
        @invoke "kickPlayer", {SID: sid}
      leavematch: ->
        (@invoke "leavematch").then (err)->
          return if !err?
          new PNotify
            title: "Leave Error"
            text: err
            type: "error"
          return
      cancelChallenge: ->
        (@invoke "cancelchallenge").then (err)->
          return if !err?
          new PNotify
            title: "Cancel Error"
            text: err
            type: "error"
          return
      startmatch: ->
        @invoke("startmatch").then (err)->
          return if !err?
          new PNotify
            title: "Can't Start Match"
            text: err
            type: "error"
          return
      creatematch: (options)->
        @invoke("creatematch", options).then (err)->
          return if !err?
          new PNotify
            title: "Can't Create Match"
            text: err
            type: "error"
          return
      respondchallenge: (chal)->
        @invoke "challengeresponse", {accept: chal}
      joinmatch: (options)->
        @invoke("joinmatch", options).then (err)->
          return if !err?
          new PNotify
            title: "Can't Join Match"
            text: err
            type: "error"
          return
      switchteam: ->
        @invoke("switchteam").then (err)->
          return if !err?
          new PNotify
            title: "Can't Switch Teams"
            text: err
            type: "error"
          return
      startchallenge: (tsid, gid, typ)->
        typ = typ || 1
        @invoke("startchallenge", {ChallengedSID: tsid, GameMode: gid, MatchType: typ}).then (err)->
          return if !err?
          new PNotify
            title: "Challenge Error"
            text: err
            type: "error"
          return
      dismissResult: ->
        @invoke "dismissresult"
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
      onlobbyready: ->
        @scope.$broadcast "lobbyReady"
      onkickedfromsg: ->
        @scope.$broadcast "kickedFromSG"
      refreshleagues: ->
        @leagueStore.refresh()
      userped: ->
        console.log "Connection userped"
        @status = "You have logged into your account from another location and are disconnected. Refresh to re-connect."
        @disconnected = true
        @_activeMatch = null
        @activeChallenge = null
        @activeResult = null
        @doReconnect = false
        @hasChallenge = false
        @chats = {}
        @liveMatches.length = 0
        @availableGames.length = 0
        @adminMatches.length = 0
        @disconnect()
      matchsnapshot: (match)->
        @_activeMatch = match
      challengesnapshot: (match)->
        @activeChallenge = match
        @hasChallenge = @activeChallenge?
        @scope.$broadcast 'challengeSnapshot', @activeChallenge
      clearchallenge: ->
        @activeChallenge = null
        @hasChallenge = false
        @scope.$broadcast 'challengeSnapshot', null
      sysnot: (nt)->
        console.log "System notification: #{JSON.stringify nt}"
        swal
          title: nt.Title
          text: nt.Message
          type: "info"
      resultsnapshot: (snp)->
        @activeResult = snp
        @scope.$broadcast "resultSnapshot", null
      matchplayerssnapshot: (upd)->
        match = _.findWhere @availableGames, {Id: upd.Id}
        if !match?
          console.log "Received match player snapshot for an unknown match #{upd.Id}"
        else
          match.Players = upd.Players
      publicmatchupd: (upd)->
        for match in upd.matches
          idx = _.findIndex @liveMatches, {Id: match.Id}
          if idx isnt -1
            @liveMatches[idx] = match
          else
            @liveMatches[@liveMatches.length] = match
      publicmatchrm: (upd)->
        for id in upd.ids
          idx = _.findIndex @liveMatches, {Id: id}
          if idx isnt -1
            @liveMatches.splice idx, 1
      availablegameupd: (upd)->
        for match in upd.matches
          idx = _.findIndex @availableGames, {Id: match.Id}
          if idx isnt -1
            @availableGames[idx] = match
          else
            match.PlayersOpen = true
            @availableGames[@availableGames.length] = match
            @scope.$broadcast "newGameHosted", match
      availablegamerm: (upd)->
        for id in upd.ids
          idx = _.findIndex @availableGames, {Id: id}
          if idx isnt -1
            [game] = @availableGames.splice idx, 1
            @scope.$broadcast "gameCanceled", game
      #clearsetup: ->
      #  if @activeMatch?
          #find the match
      #    mtchs = _.where @availableGames, {Id: @activeMatch.Id}
      #    mtchs[mtchs.length] = @activeMatch
      #    for match in mtchs
      #      match.Setup = null
      clearsetupmatch: (upd)->
        idx = _.findIndex @availableGames, {Id: upd.Id}
        if idx isnt -1
          @availableGames[idx].Setup = null
      setupsnapshot: (upd)->
        idx = _.findIndex @availableGames, {Id: upd.Id}
        if idx isnt -1
          @availableGames[idx].Setup = upd
      infosnapshot: (snap)->
        #find the match
        match = _.findWhere @availableGames, {Id: snap.Id}
        if match?
          match.Info = snap
    chat:
      onopen: (ci)->
        @chat.invoke('authinfo').then (auths)=>
          @safeApply @scope, =>
            if auths.length is 0
              @status = "Authentication failed. Try signing out and back in."
              @disconnected = true
              @doReconnect = false
              @disconnect()
            else
              console.log "Authenticated with auth groups #{auths}"
              @fetchMatches()
      globalmembersnap: (upd)->
        delete @members[memb] for memb in @members
        for memb in upd.members
          @members[memb.SteamID] = memb
        console.log upd
      globalmemberupdate: (upd)->
        memb = @members[upd.id]
        if memb?
          memb[upd.key] = upd.value
        console.log upd
        console.log memb
      globalmemberrm: (upd)->
        console.log upd
      onchatmessage: (upd)->
        chat = @chatByID upd.Id
        if !chat?
          console.log "Message for unknown chat #{upd.Id}"
        else
          chat.messages.push
            member: upd.Member
            msg: upd.Text
            name: if upd.Member is "system" then "system" else @members[upd.Member].Name
            Auto: upd.Auto
      #add or remove a chat channel
      chatchannelupd: (upd)->
        for chan in upd.channels
          echan = @chats[chan.Id]
          unless echan?
            chan.messages = []
            @chats[chan.Id] = chan
            @scope.$broadcast 'chatChannelAdd'
          else
            _.merge echan, chan
      chatchannelrm: (upd)->
        for id in upd.ids
          delete @chats[id]
        @scope.$broadcast 'chatChannelRm'
      #add or remove a chat member
      chatmemberadd: (upd)->
        chat = @chatByID upd.id
        if !chat?
          console.log "WARN -> chat member(s) added to unknown chat"
          console.log upd
        else
          for memb in upd.members
            chat.Members.push memb unless memb in chat.Members
        @scope.$broadcast 'chatMemberAdd'
      chatmemberrm: (upd)->
        chat = @chatByID upd.id
        if !chat?
          console.log "WARN -> chat member(s) removed from unknown chat"
          console.log upd
        else
          for memb in upd.members
            idx = chat.Members.indexOf memb
            continue if idx is -1
            chat.Members.splice idx, 1
        @scope.$broadcast 'chatMemberRm'

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
      conts = _.keys @handlers
      if !@conn?
        if !_.contains(@user.authItems, "admin")
          conts = _.without conts, "admin"
        console.log conts
        @conn = new XSockets.WebSocket @server, conts, {token:@token}
      safeApply = @safeApply
      scope = @scope
      serv = @
      @conn.onconnected = =>
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
        for name, cbs of @handlers
          continue unless _.contains conts, name
          @[name] = cont = @conn.controller name
          continue unless cont?
          for cbn, cb of cbs
            do (cbn, cb, cont, name) ->
              cont[cbn] = (arg)->
                safeApply scope, ->
                  cb.call serv, arg
        for name, cbs of @methods
          continue unless _.contains conts, name
          @[name] = cont = @conn.controller name
          continue unless cont?
          cont.do = {}
          for cbn, cb of cbs
            do (cbn, cb, cont, name) ->
              cont.do[cbn] = ->
                cb.apply cont, arguments
      @conn.ondisconnected = =>
        @connecting = false
        console.log "Disconnected from the network..."
        @disconnect()
        @reconnect()

  chatByID: (id)->
    @chats[id]
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

angular.module('webleagueApp').factory 'Network', ($rootScope, $timeout, Auth, LeagueStore, safeApply) ->
  service = new NetworkService $rootScope, $timeout, safeApply, LeagueStore
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
