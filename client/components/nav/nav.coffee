'use strict'
angular.module('webleagueApp').controller 'NavCtrl', ($scope, Auth, LeagueStore) ->
  $scope.oneAtATime = false
  $scope.status =
    isNavOpen: true

  $scope.canVouch = ->
    Auth.currentUser? and Auth.currentUser.authItems? and "vouch" in Auth.currentUser.authItems

  $scope.leagueStore = LeagueStore
  $scope.leagues = (leagues)->
    res = []
    lids = Auth.currentUser.leagues
    for lid in lids
      league = leagues[lid]
      res.push league if league?
    res

  LeagueStore.getLeagues (leagues)->
    for league in leagues
      $scope.status[league+"Open"] = false

  return
