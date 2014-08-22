'use strict'

angular.module('webleagueApp').factory 'Auth', ($location, $rootScope, $http, User, $interval, $q) ->
  service =
    currentPromise: null
    currentUser: null
    currentToken: null
    user: User
    getLoginStatus: (cb)->
      if @currentPromise?
        @currentPromise.then =>
          cb(@currentUser, @currentToken)
      else
        cb(@currentUser, @currentToken)
    logout: ->
      $http.get '/auth/logout'
      service.update()
    update: ->
      deferred = $q.defer()
      @currentPromise = deferred.promise
      data = User.get =>
        if data.isAuthed
          @currentUser = data.user
          @currentToken = data.token
        else
          @currentUser = null
          @currentToken = null
        @currentPromise = null
        deferred.resolve()
      @currentPromise
  $interval =>
    service.update()
  , 30000
  service.update()
  service
