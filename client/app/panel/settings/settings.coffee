'use strict'

angular.module 'webleagueApp'
.config ($stateProvider) ->
  $stateProvider.state 'panel.settings',
    url: '/settings'
    templateUrl: 'app/panel/settings/settings.html'
    controller: 'SettingsCtrl'
    authenticate: true
