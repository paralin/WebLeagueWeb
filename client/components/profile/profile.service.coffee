'use strict'

angular.module('webleagueApp').factory 'Profile', ($resource) ->
  $resource '/api/profiles/:id', {id: '@id'},
    get:
      method: 'GET'
      cache: false
      isArray: false
    list:
      method: 'GET'
      cache: false
      isArray: true
    listLeader:
      method: 'GET'
      cache: false
      isArray: true
      params:
        id: "leader"
    me:
      method: 'GET'
      cache: false
      isArray: false
      params:
        id: "me"
