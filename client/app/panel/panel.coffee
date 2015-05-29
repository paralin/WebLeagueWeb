'use strict'

angular.module 'webleagueApp'
.config ($stateProvider, $urlRouterProvider) ->
  $urlRouterProvider.when '/panel', '/panel/leaderboards'
  $stateProvider.state 'panel',
    authenticate: true
    url: '/panel'
    templateUrl: 'app/panel/panel.html'
    controller: 'PanelCtrl'
