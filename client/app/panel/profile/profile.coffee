'use strict'

angular.module 'webleagueApp'
.config ($stateProvider) ->
  $stateProvider.state 'panel.profile',
    url: '/profile'
    templateUrl: 'app/panel/profile/profile.html'
    controller: 'ProfileCtrl'
