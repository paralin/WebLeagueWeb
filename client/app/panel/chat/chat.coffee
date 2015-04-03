'use strict'

angular.module 'webleagueApp'
.config ($stateProvider, $urlRouterProvider) ->
  $urlRouterProvider.when '/panel/chat', '/panel/chat/main'
  $urlRouterProvider.when '/panel/chat/', '/panel/chat/main'
  $stateProvider.state 'panel.chat',
    url: '/chat/:name'
    templateUrl: 'app/panel/chat/chat.html'
    controller: 'ChatCtrl'
    authenticate: true
