'use strict'

angular.module 'webleagueApp'
.controller 'VouchCtrl', ($scope, Profile, $state, $http) ->
  $scope.profiles = Profile.listUnvouched()
  $scope.vouch = (profile)->
    $http.post('/api/profile/vouch/'+profile._id)
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
