'use strict'

angular.module 'webleagueApp'
.controller 'PanelCtrl', ($scope,Auth) ->
  $scope.auth = Auth
