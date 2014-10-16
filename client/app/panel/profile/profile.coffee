'use strict'

angular.module 'webleagueApp'
.config ($stateProvider) ->
  $stateProvider.state 'panel.profileme',
    url: '/profile'
    templateUrl: 'app/panel/profile/profile.html'
    controller: 'ProfileCtrl'
    authenticate: true
  $stateProvider.state 'panel.profile',
    url: '/profile/:id'
    templateUrl: 'app/panel/profile/profile.html'
    controller: 'ProfileCtrl'
    authenticate: true
