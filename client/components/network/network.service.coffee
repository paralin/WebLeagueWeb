'use strict'

class NetworkService
  disconnected: true
  doReconnect: true
  reconnTimeout: null
  attempts: 0
  status: "Disconnected from the server."

  chats: []
  liveMatches: []
  ###[
    {
      Name: "Test"
      Mode: 1
      Public: true
    }
  ]###
  availableGames: [{
      Info: 
        Name: "This will be a fun test game."
        Mode: 1
        Public: true
      GameType: 0
      Players: [
        {
          SID: '0305235032'
          Name: "Quantum"
          Avatar: "http://media.steampowered.com/steamcommunity/public/images/avatars/5c/5c82337faff6f3e87a3c1434cd0001afa7632c3e_full.jpg"
          Team: 1
        }
      ]
    }]

  constructor: (@scope, @timeout, @safeApply)->
  disconnect: ->
    if @conn?
      if @cont
        @cont.close()
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

  handlers: 
    #games: {}
    chat:
      onchatmessage: (upd)->
        chat = @chatByID upd.Id
        if !chat?
          console.log "Message for unknown chat #{upd.Id}"
        else
          chat.messages.push
            member: upd.Member.ID
            msg: upd.Text
      #add or remove a chat channel
      chatchannelupd: (upd)->
        for chan in upd.channels
          console.log "chat add/update"
          console.log chan
          #get idx in array
          idx = _.findIndex @chats, {Id: chan.Id}
          if idx is -1
            chan.messages = []
            @chats.push chan
          else
            _.merge @chats[idx], chan
      chatchannelrm: (upd)->
          console.log "removed chats: #{JSON.stringify upd.ids}"
          for id in upd.ids
            idx = _.findIndex @chats, {Id: id}
            @chats.splice idx, 1 if idx > -1
            return
      #add or remove a chat member
      chatmemberupd: (upd)->
        chat = @chatByID upd.id
        if !chat?
          console.log "WARN -> chat member(s) added to unknown chat"
          console.log upd
        else
          for memb in upd.members
            chat.Members[memb.ID] = memb
      chatmemberrm: (upd)->
        chat = @chatByID upd.id
        if !chat?
          console.log "WARN -> chat member(s) removed from unknown chat"
          console.log upd
        else
          for memb in upd.members
            delete chat.Members[memb]
          return

  connect: ->
    @attempts += 1
    @disconnect()
    if !@server?
      console.log "No server info yet."
      @status = "Waiting for server info..."
    else
      @status = "Connecting to the network..."
      console.log "Connecting to #{@server}..."
      if !@conn?
        conts = _.keys @handlers
        conts.unshift 'auth'
        #conts.push "games"
        @conn = new XSockets.WebSocket @server, conts
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
        for name, cbs of @handlers
          @[name] = cont = @conn.controller name
          cont.isopened = false
          do (cont, name)=>
            cont.onopen = (ci)->
              console.log "#{name} opened."
              @isopened = true
          for cbn, cb of cbs
            do (cbn, cb, cont, name) ->
              cont[cbn] = (arg)->
                console.log cbn
                console.log arg
                safeApply scope, -> 
                  cb.call serv, arg
        @auth = @conn.controller 'auth'
        @auth.onopen = (ci)=>
          console.log "Authenticating..."
          @auth.invoke('authwithtoken', {token:@token}).then (success)=>
            console.log "Auth result: #{success}"
            if success
              @chat.invoke('joinorcreate', {Name: "main"})
              @chat.invoke('joinorcreate', {Name: "developers"})
              @fetchMatches()
            else
              console.log "Authentication failed."
              @status = "Authentication failed. Try signing out and back in."
              @disconnected = true
              @doReconnect = false
              @disconnect()
      @conn.ondisconnected = =>
        console.log "Disconnected from the network..."
        @disconnect()
        @reconnect()

  chatByID: (id)->
    _.find @chats, {Id: id}
  fetchMatches: ->
    @matches.invoke('getpublicgamelist').then (ms)=>
      @liveMatches = ms

angular.module('webleagueApp').factory 'Network', ($rootScope, $timeout, Auth, safeApply) ->
  service = new NetworkService $rootScope, $timeout, safeApply
  Auth.getLoginStatus (currentUser, currentToken, currentServer)->
    service.token = currentToken
    service.server = currentServer
    service.connect()
  window.service = service
