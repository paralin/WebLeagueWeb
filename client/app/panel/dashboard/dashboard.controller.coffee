'use strict'

angular.module 'webleagueApp'
.controller 'DashboardCtrl', ($scope, Network, $rootScope, $stateParams, $http, Auth, LeagueStore) ->
  $scope.leagues = LeagueStore.leagues
  $scope.page =
    title: 'Dashboard',
    subtitle: 'Your home page'

  $scope.getRecord = (leagueid)->
    league = LeagueStore.leagues[leagueid]
    return "Unknown" if !league?
    leagueprof = Auth.currentUser.profile.leagues[leagueid+":"+league.CurrentSeason]
    return "No record" if !leagueprof?
    "#{leagueprof.wins}/#{leagueprof.losses} - #{leagueprof.rating}"
