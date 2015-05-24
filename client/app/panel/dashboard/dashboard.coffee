'use strict'

angular.module 'webleagueApp'
.config ($stateProvider, $urlRouterProvider) ->
  $stateProvider.state 'panel.dashboard',
    url: '/dashboard'
    templateUrl: 'app/panel/dashboard/dashboard.html'
    controller: 'DashboardCtrl'
    authenticate: true
