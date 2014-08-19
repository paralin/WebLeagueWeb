'use strict'

angular.module 'webleagueApp'
.config ($stateProvider) ->
  $stateProvider.state 'panel',
    authenticate: true
    url: '/panel'
    templateUrl: 'app/panel/panel.html'
    controller: 'PanelCtrl'
