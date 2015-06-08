'use strict'

angular.module 'webleagueApp'
.controller 'TeamspeakCtrl', ($scope, Auth, $http) ->
  $scope.page =
    title: 'Teamspeak',
    subtitle: 'How to connect to teamspeak'

  $scope.revokeTokens = ->
    $http.post "/api/users/clearTsTokens"
      .success (data, status, headers, config)->
        swal
          title: "Revoked"
          type: "success"
          text: "Within 5 minutes all users associated with your account will be unauthed on Teamspeak."
      .error (data, status)->
        swal
          title: "Unable to Reset"
          text: "There was a problem (#{status}) with resetting your TS."
          type: "error"

  $scope.auth = Auth
