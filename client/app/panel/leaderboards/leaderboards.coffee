'use strict'

angular.module 'webleagueApp'
.config ($stateProvider, $urlRouterProvider) ->
  $stateProvider.state 'panel.leaderboards',
    url: '/leaderboards'
    templateUrl: 'app/panel/leaderboards/leaderboards.html'
    controller: 'LeaderboardsCtrl'
    authenticate: true
