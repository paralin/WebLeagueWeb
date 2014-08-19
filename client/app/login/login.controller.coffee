'use strict'

angular.module 'webleagueApp'
.controller 'LoginCtrl', ($scope) ->
  $scope.steamSignin = ->
    window.location.href = "/auth/steam"
