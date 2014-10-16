'use strict'

angular.module 'webleagueApp'
.controller 'LeaderboardCtrl', ($scope, Profile, $state) ->
  $scope.profiles = Profile.list()
  $scope.goToProfile = (profile)->
    state.go "panel.profile",
      id: profile._id
