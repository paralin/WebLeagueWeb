'use strict'

angular.module 'webleagueApp'
.config ($stateProvider) ->
  $stateProvider.state 'panel.leaderboard',
    url: '/leaderboard'
    templateUrl: 'app/panel/leaderboard/leaderboard.html'
    controller: 'LeaderboardCtrl'
