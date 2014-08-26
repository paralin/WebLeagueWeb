'use strict'

class NetworkService
  disconnected: true
  doReconnect: true
  reconnTimeout: null
  attempts: 0
  status: "Disconnected from the server."
  constructor: (@scope, @timeout, @server, @token)->
  disconnect: ->
    if @conn?
      if @cont
        @cont.close()
      @conn.disconnect()
    if @reconnTimeout?
      @timeout.cancel(@reconnTimeout)
      @reconnTimeout = null
    #@status = "Disconnected from the server."
    @disconnected = true
  reconnect: ->
    if @doReconnect
      if !@reconnTimeout?
        console.log "Scheduling reconnect"
        @timeout =>
          @disconnected = true
          @status = "Reconnecting in 3 seconds, attempt ##{@attempts}..."
        @reconnTimeout = @timeout(=>
          @reconnTimeout = null 
          @connect()
        , 3000)
    else
      console.log "Not reconnecting."
  connect: ->
    @attempts += 1
    @disconnect()
    if !@server?
      console.log "No server info yet."
      @status = "Waiting for server info..."
    else
      @status = "Connecting to the network..."
      if !@conn?
        @conn = new XSockets.WebSocket(@server, ['auth', 'chat'], {token: @token})
        @conn.onconnected = =>
          @timeout =>
            @disconnected = false
            @status = "Connected to the network."
            @attempts = 0
            @chat = @conn.controller 'chat'
            @auth = @conn.controller 'auth'
            @auth.onopen = (ci)=>
              @auth.invoke('authwithtoken', {token:@token}).then (success)=>
                if success
                  @chat.invoke('sendmessage', {text: "Testing 123"})
                else
                  @status = "Authentication failed. Try signing out and back in."
                  @disconnected = true
                  @doReconnect = false
                  @disconnect()
        @conn.ondisconnected = =>
          console.log "socket disconnected"
          @disconnect()
          @reconnect()
      else
        @conn.reconnect()

angular.module('webleagueApp').factory 'Network', ($rootScope, $timeout, Auth) ->
  service = new NetworkService $rootScope, $timeout
  Auth.getLoginStatus (currentUser, currentToken, currentServer)->
    service.token = currentToken
    service.server = currentServer
    service.connect()
  window.service = service
