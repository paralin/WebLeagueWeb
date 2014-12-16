'use strict'

angular.module 'webleagueApp'
.controller 'ProfileCtrl', ($scope, Profile, $stateParams, $location, $state, Auth, $http) ->
  $scope.auth = Auth
  processProfile = (profile)->
    $scope.profile = profile
  processError = (resp)->
    swal "Not Found", "Can't find the player you requested.", "error"
    $state.go "panel.chat"
  if $stateParams.id? && $stateParams.id isnt ""
    Profile.get {id: $stateParams.id}, processProfile, processError
  else
    Profile.me processProfile
  $scope.devouch = ->
    return if !Auth.inRole('vouch')
    $http.post('/api/vouches/delete/'+$scope.profile._id)
      .success ->
        state.go "panel.leaderboard"
        swal
          title: "Player Unvouched"
          text: "The player has been unvouched!"
          type: "success"
      .error ->
        swal
          title: "Can't Unvouch Player"
          text: "There was a problem unvouching the player."
          type: "error"
