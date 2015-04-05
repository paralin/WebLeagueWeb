'use strict'

class NetworkService
  disconnected: true
  doReconnect: true
  reconnTimeout: null
  attempts: 0
  status: "Disconnected from the server."

  activeMatch: null
  activeChallenge: null
  activeResult: null
  hasChallenge: false
  chats: []
  liveMatches: []
  availableGames: []

  adminMatches: []

  constructor: (@scope, @timeout, @safeApply)->
  disconnect: ->
    console.log "Disconnect called"
    if @conn?
      @conn.disconnect()
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
      leavematch: ->
        (@invoke "leavematch").then (err)->
          return if !err?
          new PNotify
            title: "Leave Error"
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
      startchallenge: (tsid, gid)->
        @invoke("startchallenge", {ChallengedSID: tsid, GameMode: gid}).then (err)->
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
      userped: ->
        console.log "Connection userped"
        @status = "You have logged into your account from another location and are disconnected."
        @disconnected = true
        @activeMatch = null
        bootbox.hideAll()
        @activeChallenge = null
        @activeResult = null
        @doReconnect = false
        @hasChallenge = false
        @chats.length = 0
        @liveMatches.length = 0
        @availableGames.length = 0
        @adminMatches.length = 0
        @disconnect()
      matchsnapshot: (match)->
        @activeMatch = match
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
        #find the match
        mtchs = []
        match = _.find @availableGames, {Id: upd.Id}
        mtchs[mtchs.length] = match if match?
        mtchs[mtchs.length] = @activeMatch if @activeMatch? && @activeMatch.Id is upd.Id
        if mtchs.length is 0
          console.log "Received match player remove for an unknown match #{upd.Id}"
        for match in mtchs
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
            @availableGames[@availableGames.length] = match
            @scope.$broadcast "newGameHosted"
      availablegamerm: (upd)->
        for id in upd.ids
          idx = _.findIndex @availableGames, {Id: id}
          if idx isnt -1
            [game] = @availableGames.splice idx, 1
            @scope.$broadcast "gameCanceled", game
      clearsetup: ->
        if @activeMatch?
          #find the match
          mtchs = _.where @availableGames, {Id: @activeMatch.Id}
          mtchs[mtchs.length] = @activeMatch
          for match in mtchs
            match.Setup = null
      setupsnapshot: (snap)->
        if @activeMatch?
          #find the match
          mtchs = _.where @availableGames, {Id: @activeMatch.Id}
          mtchs[mtchs.length] = @activeMatch
          for match in mtchs
            match.Setup = snap
      infosnapshot: (snap)->
        #find the match
        mtchs = _.where @availableGames, {Id: snap.Id}
        mtchs[mtchs.length] = @activeMatch if @activeMatch? && @activeMatch.Id is snap.Id
        for match in mtchs
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
              #@chat.invoke('joinorcreate', {Name: "main"})
              @fetchMatches()
      onchatmessage: (upd)->
        chat = @chatByID upd.Id
        if !chat?
          console.log "Message for unknown chat #{upd.Id}"
        else
          chat.messages.push
            member: upd.Member.ID
            msg: upd.Text
            name: chat.Members[upd.Member.ID].Name
            Auto: upd.Auto
      #add or remove a chat channel
      chatchannelupd: (upd)->
        for chan in upd.channels
          console.log chan
          #get idx in array
          idx = _.findIndex @chats, {Id: chan.Id}
          if idx is -1
            chan.messages = []
            @chats.push chan
          else
            _.merge @chats[idx], chan
        #@scope.$broadcast 'chatMembersUpd'
        @scope.$broadcast 'chatChannelAdd'
      chatchannelrm: (upd)->
        for id in upd.ids
          idx = _.findIndex @chats, {Id: id}
          @chats.splice idx, 1 if idx > -1
        @scope.$broadcast 'chatMembersUpd'
      #add or remove a chat member
      chatmemberupd: (upd)->
        chat = @chatByID upd.id
        if !chat?
          console.log "WARN -> chat member(s) added to unknown chat"
          console.log upd
        else
          for memb in upd.members
            chat.Members[memb.ID] = memb
        @scope.$broadcast 'chatMembersUpd'
      chatmemberrm: (upd)->
        chat = @chatByID upd.id
        if !chat?
          console.log "WARN -> chat member(s) removed from unknown chat"
          console.log upd
        else
          for memb in upd.members
            delete chat.Members[memb]
        @scope.$broadcast 'chatMembersUpd'

  connect: ->
    if !@disconnected
      return
    @attempts += 1
    if !@server?
      console.log "No server info yet."
      @status = "Waiting for server info..."
    else
      @status = "Connecting to the network..."
      console.log "Connecting to #{@server}..."
      conts = _.keys @handlers
      if !@conn?
        if !_.contains(@user.authItems, "admin")
          conts = _.without conts, "admin"
        console.log conts
        @conn = new XSockets.WebSocket @server, conts, {token:@token}
      else
        @conn.reconnect()
      safeApply = @safeApply
      scope = @scope
      serv = @
      @conn.onconnected = =>
        console.log "Connected to the network!"
        if @reconnTimeout?
          @timeout.cancel(@reconnTimeout)
          @reconnTimeout = null
        safeApply scope, =>
          @disconnected = false
          @status = "Connected to the network."
          @attempts = 0
          @chats.length = 0
          @activeMatch = null
          @activeResult = null
          @adminMatches.length = 0
          bootbox.hideAll()
          @activeChallenge = null
        for name, cbs of @handlers
          continue unless _.contains conts, name
          @[name] = cont = @conn.controller name
          for cbn, cb of cbs
            do (cbn, cb, cont, name) ->
              cont[cbn] = (arg)->
                safeApply scope, ->
                  cb.call serv, arg
        for name, cbs of @methods
          continue unless _.contains conts, name
          @[name] = cont = @conn.controller name
          cont.do = {}
          for cbn, cb of cbs
            do (cbn, cb, cont, name) ->
              cont.do[cbn] = ->
                cb.apply cont, arguments
      @conn.ondisconnected = =>
        console.log "Disconnected from the network..."
        #@disconnect()
        @reconnect()

  chatByID: (id)->
    _.find @chats, {Id: id}
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

angular.module('webleagueApp').factory 'Network', ($rootScope, $timeout, Auth, safeApply) ->
  service = new NetworkService $rootScope, $timeout, safeApply
  Auth.getLoginStatus (currentUser, currentToken, currentServer)->
    service.token = currentToken
    service.server = currentServer
    service.user = currentUser
    service.connect()
  $(window).unload ->
    service.disconnect()
  window.service = service
