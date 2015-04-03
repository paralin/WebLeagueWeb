'use strict'

angular.module 'webleagueApp'
.controller 'ChatCtrl', ($scope, Network, $rootScope, $stateParams) ->
  chatName = $stateParams.name.toLowerCase()
  chat = _.findWhere Network.chats, {Name: chatName}
  if !chat?
    console.log "can't find chat, deferring tab update to later"
  else
    chatidx = _.indexOf Network.chats, chat
    $scope.panelTabs.selected = chatidx

  $scope.sendChallenge = (member)->
    Network.matches.do.startchallenge member.SteamID, $rootScope.GameMode.CM
