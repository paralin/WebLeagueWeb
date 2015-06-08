'use strict'

angular.module('webleagueApp').factory 'Result', ($resource) ->
  $resource '/api/results/', {},
    list:
      method: 'GET'
      cache: false
      isArray: true
