'use strict'

class NetworkService
  disconnected: true
  doReconnect: true
  reconnTimeout: null
  attempts: 0
  status: "Disconnected from the server."

  chats: []

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
        @conn = new XSockets.WebSocket(@server, ['auth', 'chat'])
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
          for cbn, cb of cbs
            do (cbn, cb) ->
              cont[cbn] = (arg)->
                console.log cbn
                safeApply scope, -> 
                  cb.call serv, arg
        @auth = @conn.controller 'auth'
        @auth.onopen = (ci)=>
          @auth.invoke('authwithtoken', {token:@token}).then (success)=>
            if success
              @chat.invoke('joinorcreate', {Name: "main"})
              @chat.invoke('joinorcreate', {Name: "developers"})
            else
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

angular.module('webleagueApp').factory 'Network', ($rootScope, $timeout, Auth, safeApply) ->
  service = new NetworkService $rootScope, $timeout, safeApply
  Auth.getLoginStatus (currentUser, currentToken, currentServer)->
    service.token = currentToken
    service.server = currentServer
    service.connect()
  window.service = service
