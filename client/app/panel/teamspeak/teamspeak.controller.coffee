'use strict'

angular.module 'webleagueApp'
.controller 'TeamspeakCtrl', ($scope, Auth) ->
  $scope.page =
    title: 'Teamspeak',
    subtitle: 'How to connect to teamspeak'

  $scope.auth = Auth
