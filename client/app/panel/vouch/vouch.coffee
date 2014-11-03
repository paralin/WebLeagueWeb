'use strict'

angular.module 'webleagueApp'
.config ($stateProvider) ->
  $stateProvider.state 'panel.vouch',
    url: '/vouch'
    templateUrl: 'app/panel/vouch/vouch.html'
    controller: 'VouchCtrl'
    authenticate: true
