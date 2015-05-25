angular.module('webleagueApp')
.controller 'RightBarCtrl', ($scope, Network)->
  $scope.network = Network
  window.scope = $scope
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
