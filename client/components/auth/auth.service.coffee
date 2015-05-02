'use strict'

angular.module('webleagueApp').factory 'Auth', ($location, $rootScope, $http, User, $interval, $q, $translate) ->
  service =
    currentPromise: null
    currentUser: null
    currentToken: null
    currentServer: null
    wasAuthed: false
    inRole: (name)->
      return false if !@currentUser?
      _.contains @currentUser.authItems, name
    user: User
    getLoginStatus: (cb)->
      if @currentPromise?
        @currentPromise.then =>
          cb(@currentUser, @currentToken, @currentServer)
      else
        cb(@currentUser, @currentToken, @currentServer)
    logout: ->
      $http.get '/auth/logout'
      service.update()
    update: ->
      deferred = $q.defer()
      @currentPromise = deferred.promise
      data = User.get =>
        if data.isAuthed
          @currentUser = data.user
          $rootScope.fillSettings @currentUser
          $translate.use @currentUser.settings.language
          @currentToken = data.token
          @currentServer = data.server
          $rootScope.$broadcast('buildIdUpdate', data.build_id)
        else
          @currentUser = null
          @currentToken = null
          @currentServer = null
        @currentPromise = null
        deferred.resolve()
        if data.isAuthed isnt service.wasAuthed
          service.wasAuthed = data.isAuthed
          $rootScope.$broadcast('authStatusChange')
      @currentPromise
    saveSettings: _.debounce ->
      $http.post "/api/users/saveSettings", @currentUser.settings
    , 1000
  $interval =>
    service.update()
  , 30000
  service.update()
  window.auth = service
  service
