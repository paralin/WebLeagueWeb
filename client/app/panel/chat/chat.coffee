'use strict'

angular.module 'webleagueApp'
.config ($stateProvider) ->
  $stateProvider.state 'panel.chat',
    url: '/chat'
    templateUrl: 'app/panel/chat/chat.html'
    controller: 'ChatCtrl'
    authenticate: true
