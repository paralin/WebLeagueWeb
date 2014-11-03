'use strict'

angular.module 'webleagueApp'
.config ($stateProvider) ->
  $stateProvider.state 'novouch',
    authenticate: true
    url: '/novouch'
    templateUrl: 'app/novouch/novouch.html'
    controller: 'NovouchCtrl'
