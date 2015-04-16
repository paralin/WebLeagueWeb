'use strict'

angular.module 'webleagueApp'
.config ($stateProvider) ->
  $stateProvider.state 'panel.results',
    url: '/results'
    templateUrl: 'app/panel/results/results.html'
    controller: 'ResultsCtrl'
    authenticate: true
