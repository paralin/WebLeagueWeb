'use strict'

PNotify.desktop.permission()
angular.module 'webleagueApp'
.controller 'PanelCtrl', ($rootScope, $scope, Auth, Network) ->
  $scope.auth = Auth
  $scope.network = Network
  $scope.selected = 0
  $scope.chats = Network.chats
  $scope.liveMatches = Network.liveMatches
  $scope.games = Network.availableGames
  $scope.confirmCreateMatch = ->
    nameInput = $("#matchNameInput")[0]
    name = nameInput.inputValue
    if name is ""
      $("paper-dialog")[0].opened = true
      new PNotify
        title: "Name Needed"
        text: "Please enter a match name."
        type: "error"
      return
    drp = $("#gameModeInput")[0]
    sel = drp.selectedItem
    if !sel?
      $("paper-dialog")[0].opened = true
      new PNotify
        title: "Game Mode Needed"
        text: "Please select a game mode."
        type: "error"
      return
    gm = parseInt $(drp.selectedItem).attr "value"
    console.log "Selected: #{$rootScope.MatchTypeN[gm]}"
    Network.matches.do.creatematch
      MatchType: 0
      Name: name
      GameType: gm
    
  $scope.dismissCreate = ->
    $("paper-dialog")[0].opened = false
  # Is currently controlling a game
  $scope.createStartgame = ->
    #network.matches.do.creatematch({MatchType: 1, Name: 'test', GameType: 0})
    $("paper-dialog")[0].toggle()
    $("#matchNameInput")[0].inputValue = ""
  $scope.showRightCont = ->
    Network.liveMatches.length>0||$scope.games.length>0||$scope.canStartGames()||$scope.isAdminOfGame()
  $scope.isAdminOfGame = ->
    return false if !Auth.currentUser? or !Network.activeMatch?
    Network.activeMatch.Info.Owner is Auth.currentUser.steam.steamid
  $scope.canStartGames = ->
    if Auth.currentUser? && !Network.activeMatch?
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
      
