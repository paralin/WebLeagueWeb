'use strict'

angular.module 'webleagueApp'
.config ($stateProvider, $urlRouterProvider) ->
  $urlRouterProvider.when '/panel/league',  '/panel/dashboard'
  $urlRouterProvider.when '/panel/league/', '/panel/dashboard'
  $stateProvider.state 'panel.league',
    url: '/league/:id'
    templateUrl: 'app/panel/league/league.html'
    controller: 'LeagueCtrl'
    authenticate: true
