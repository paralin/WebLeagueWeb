'use strict'

angular.module 'webleagueApp'
.controller 'ProfileCtrl', ($scope, Profile, $stateParams, $location, $state) ->
  processProfile = (profile)->
    $scope.profile = profile
  processError = (resp)->
    swal "Not Found", "Can't find the player you requested.", "error"
    $state.go "panel.chat"
  if $stateParams.id? && $stateParams.id isnt ""
    Profile.get {id: $stateParams.id}, processProfile, processError
  else
    Profile.me processProfile
