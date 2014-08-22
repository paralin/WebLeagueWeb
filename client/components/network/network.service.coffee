'use strict'

class NetworkService
  disconnected: true
  status: "Disconnected from the server."
  constructor: (@scope, @interval, @q)->
  connect: ->
    console.log "connecting"
    @status = "Connecting to the server..."

angular.module('webleagueApp').factory 'Network', ($rootScope, $interval, $q) ->
  service = new NetworkService $rootScope, $interval, $q
  service.connect()
  service
