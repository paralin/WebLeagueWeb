'use strict'

angular.module 'webleagueApp'
.config ($stateProvider, $urlRouterProvider) ->
  $stateProvider.state 'panel.teamspeak',
    url: '/teamspeak'
    templateUrl: 'app/panel/teamspeak/teamspeak.html'
    controller: 'TeamspeakCtrl'
    authenticate: true
