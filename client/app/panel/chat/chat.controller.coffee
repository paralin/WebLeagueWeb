'use strict'

angular.module 'webleagueApp'
.controller 'ChatCtrl', ($scope, challenge) ->
  $scope.sendChallenge = (member)->
    challenge.challenged = member
    console.log challenge
    $("#createChallenge")[0].toggle()
