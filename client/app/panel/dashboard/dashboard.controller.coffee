'use strict'

angular.module 'webleagueApp'
.controller 'DashboardCtrl', ($scope, Network, $rootScope, $stateParams, $http) ->
  $scope.page =
    title: 'Dashboard',
    subtitle: 'Your home page'
