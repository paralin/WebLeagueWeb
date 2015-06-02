angular.module('webleagueApp')
.controller 'RightBarCtrl', ($scope, Network, Auth, $state, $stateParams, LeagueStore)->
  $scope.network = Network
  $scope.hasLeagues = -> Auth.currentUser? and Auth.currentUser.vouch? and Auth.currentUser.vouch.leagues? and Auth.currentUser.vouch.leagues.length > 0

  $scope.getMembers = (membs, notOffline)->
    res = []
    for id, memb of membs
      if notOffline
        res.push memb if memb.State > 0
      else
        res.push memb if memb.State is 0
    res
  $scope.stateClass =
    0: "offline"
    1: "busy"
    2: "online"

  $scope.leagueid = ->
    return null unless Auth.currentUser? and Auth.currentUser.vouch? and Auth.currentUser.vouch.leagues? and Auth.currentUser.vouch.leagues.length > 0
    return $stateParams.id if $state.is("panel.league") and $stateParams.id? and $stateParams.id in Auth.currentUser.vouch.leagues
    Auth.currentUser.vouch.leagues[0]

  $scope.league = ->
    id = $scope.leagueid()
    return {} if !id?
    LeagueStore.leagues[id]
