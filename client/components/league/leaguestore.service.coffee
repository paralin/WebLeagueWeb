'use strict'

angular.module('webleagueApp').factory 'LeagueStore', (League, $q, $rootScope) ->
  service =
    currentPromise: null
    leagues: {}
    getLeagues: (cb)->
      if @currentPromise?
        @currentPromise.then =>
          cb @leagues
      else
        cb @leagues
    refresh: ->
      return if @currentPromise?
      deferred = $q.defer()
      @currentPromise = deferred.promise
      data = League.list =>
        delete @leagues[member] for member in @leagues
        @leagues[l._id] = l for l in data
        console.log "Leagues refreshed, #{data.length} leagues."
        @currentPromise = null
        $rootScope.$broadcast('leaguesUpdate', @leagues)
        deferred.resolve()
      @currentPromise
  service.refresh()
  window.leagues = service
  service
