'use strict'

angular.module 'webleagueApp'
.controller 'ChatCtrl', ($scope, Network, $rootScope) ->
  $scope.sendChallenge = (member)->
    Network.matches.do.startchallenge member.SteamID, $rootScope.GameMode.CM
