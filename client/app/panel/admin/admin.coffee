'use strict'

angular.module 'webleagueApp'
.config ($stateProvider) ->
  $stateProvider.state 'panel.admin',
    url: '/admin'
    templateUrl: 'app/panel/admin/admin.html'
    controller: 'AdminCtrl'
    authenticate: true
