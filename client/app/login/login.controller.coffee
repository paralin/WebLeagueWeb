'use strict'

angular.module 'webleagueApp'
.controller 'LoginCtrl', ($scope, Network) ->
  Network.disconnect()
  $scope.steamSignin = ->
    window.location.href = "/auth/steam"
