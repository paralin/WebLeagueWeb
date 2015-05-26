'use strict'
angular.module('webleagueApp').controller 'NavCtrl', ($scope, Auth, LeagueStore) ->
  $scope.oneAtATime = false
  $scope.status =
    isFirstOpen: true
    isSecondOpen: true
  $scope.leagueStore = LeagueStore
  $scope.leagues = (leagues)->
    res = []
    lids = Auth.currentUser.leagues
    for lid in lids
      league = leagues[lid]
      res.push league if league?
    res

  return
