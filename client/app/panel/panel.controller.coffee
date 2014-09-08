'use strict'

PNotify.desktop.permission()
angular.module 'webleagueApp'
.controller 'PanelCtrl', ($scope, Auth, Network) ->
  $scope.auth = Auth
  $scope.network = Network
  $scope.selected = 0
  $scope.chats = Network.chats
  $scope.liveMatches = Network.liveMatches
  $scope.games = Network.availableGames
  # Is currently controlling a game
  $scope.showRightCont = ->
    Network.liveMatches.length>0||$scope.games.length>0||$scope.canStartGames()||$scope.isAdminOfGame()
  $scope.isAdminOfGame = ->
    false
  $scope.canStartGames = ->
    if Auth.currentUser?
      _.contains Auth.currentUser.authItems, 'startGames'
    else
      false
  $scope.showJoinDialog = ->
    bootbox.prompt "What is the chat name?", (cb)->
      return if !cb? || cb is ""
      Network.chat.invoke("joinorcreate", {Name: cb}).then (err)->
        if err?
          new PNotify
            title: "Join Error"
            text: err
            type: "error"
            desktop:
              desktop: true
          return
    return
  $scope.leaveCurrentChat = (cb)->
    chat = $scope.chats[$scope.selected]
    return if !chat?
    if chat.Leavable
      Network.chat.invoke "leave", {Id: chat.Id}
    else
      bootbox.alert "You can't leave this chat."
  $scope.sendChat = (event)->
    msg = event.detail.message
    console.log "sending #{msg}"
    Network.chat.invoke("sendmessage", {Channel: service.chats[$scope.selected].Id, Text: msg})
  $scope.$watch 'chats', (newValue, oldValue)->
    $scope.selected = newValue.length-1 if $scope.selected > newValue.length
      
