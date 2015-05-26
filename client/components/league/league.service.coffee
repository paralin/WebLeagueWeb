'use strict'

angular.module('webleagueApp').factory 'League', ($resource) ->
  $resource '/api/leagues/', {},
    list:
      method: 'GET'
      isArray: true
      cache: false
