'use strict'

angular.module('webleagueApp').factory 'User', ($resource) ->
  $resource '/api/users/status', {},
    get:
      method: 'GET'
