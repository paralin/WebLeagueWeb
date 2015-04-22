'use strict'

angular.module 'webleagueApp'
.controller 'LeaderboardCtrl', ($scope, Profile, $state) ->
  $scope.profiles = Profile.listLeader()
  $scope.goToProfile = (profile)->
    $state.go "panel.profile",
      id: profile._id
  $scope.ratingPrizeValue = (idx)->
    window.prizepool.rating[idx] || ""
  $scope.gamesPrizeValue = (idx)->
    window.prizepool.gamesPlayed[idx] || ""
