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
  $scope.addWins = ->
    swal
      title: "Add/Remove Wins"
      text: "Enter a number wins change"
      type: "input"
      showCancelButton: true
      closeOnConfirm: false
      animation: 'slide-from-top'
    , (val)->
      rating = parseInt val
      if rating isnt rating
        swal
          title: "Not a Number"
          type: "error"
          text: "You didn't enter a number."
        return
      rating = Math.floor rating
      swal {
        title: 'Are you sure?'
        text: 'Are you sure you want to add '+val+' wins?'
        type: 'warning'
        showCancelButton: true
        confirmButtonColor: '#DD6B55'
        confirmButtonText: 'Yes, do it!'
      }, ->
        return
  $scope.addLosses = ->
    swal
      title: "Add/Remove Losses"
      text: "Enter a number losses change"
      type: "input"
      showCancelButton: true
      closeOnConfirm: false
      animation: 'slide-from-top'
    , (val)->
      rating = parseInt val
      if rating isnt rating
        swal
          title: "Not a Number"
          type: "error"
          text: "You didn't enter a number."
        return
      rating = Math.floor rating
      swal {
        title: 'Are you sure?'
        text: 'Are you sure you want to add '+val+' losses?'
        type: 'warning'
        showCancelButton: true
        confirmButtonColor: '#DD6B55'
        confirmButtonText: 'Yes, do it!'
      }, ->
        return
  $scope.addRating = ->
    swal
      title: "Add/Remove Rating"
      text: "Enter a number rating change"
      type: "input"
      showCancelButton: true
      closeOnConfirm: false
      animation: 'slide-from-top'
    , (val)->
      rating = parseInt val
      if rating isnt rating
        swal
          title: "Not a Number"
          type: "error"
          text: "You didn't enter a number."
        return
      rating = Math.floor rating
      swal {
        title: 'Are you sure?'
        text: 'Are you sure you want to add '+val+' rating?'
        type: 'warning'
        showCancelButton: true
        confirmButtonColor: '#DD6B55'
        confirmButtonText: 'Yes, do it!'
      }, ->
        return


  $scope.devouch = ->
    return if !Auth.inRole('vouch')
    $http.post('/api/vouches/delete/'+$scope.profile.steam.steamid)
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
