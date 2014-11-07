'use strict'

angular.module 'webleagueApp'
.controller 'VouchCtrl', ($scope, Profile, $state, $http, $filter) ->
  $scope.profiles = Profile.listUnvouched()
  $scope.searchText = ""
  $scope.searchFilter = (value) ->
    value.profile.name.indexOf($scope.searchText) isnt -1
  $scope.vouch = (profile)->
    $http.post('/api/profiles/vouch/'+profile._id)
      .success (data, status, headers)->
        $scope.profiles = Profile.listUnvouched()
        window.aswal = swal
          title: "Vouched"
          text: "You have vouched the player."
          type: "success"
          showCancelButton: false
          confirmButtonText: "OK"
      .error (data, status, headers)->
        window.aswal = swal
          title: "Problem Vouching"
          text: "There was a problem vouching that user."
          type: "error"
          showCancelButton: false
          confirmButtonColor: "#DD6B55"
          confirmButtonText: "Ok"
