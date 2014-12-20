'use strict'

angular.module('webleagueApp').factory 'Vouch', ($resource) ->
  $resource '/api/vouches/list/', {},
    list:
      method: 'GET'
      cache: false
      isArray: true
