'use strict'

PNotify.desktop.permission()
angular.module 'webleagueApp'
.controller 'PanelCtrl', ($rootScope, $scope, Auth, Network, safeApply) ->
  clr = []
  $scope.auth = Auth
  console.log "$scope"
  window.scope = $scope
  $scope.network = Network
  $scope.selected = 0
  $scope.chats = Network.chats
  $scope.liveMatches = Network.liveMatches
  $scope.games = Network.availableGames
  $scope.chatMembers = []
  $scope.allMembers = []
  $scope.hasVoted = ->
    return false if !Network.activeResult? || !Network.activeResult.Votes?
    Network.activeResult.Votes[Auth.currentUser.steam.steamid]?
  $scope.regenMembersList = ->
    members = []
    for chat in Network.chats
      for id, member of chat.Members
        ex = _.find members, {ID: member.ID}
        members.push member if !ex?
    $scope.allMembers = members
  $scope.notMe = (member)->
    member.SteamID isnt Auth.currentUser.steam.steamid
  $scope.pickPlayer = (event)->
    console.log "Picking player #{event.detail.SID}"
    Network.matches.do.pickPlayer event.detail.SID
  updChatMembers = (members)->
    arr = $scope.chatMembers
    nMembers = _.keys members
    for mem in nMembers
      arr[arr.length] = mem if !_.contains(arr, mem)
    i=0
    for mem in arr
      arr.splice i, 1 if !_.contains(nMembers, mem)
      i+=1
  clr.push $scope.$watch "selected", (selected)->
    chat = $scope.chats[selected]
    if !chat?
      $scope.chatMembers.length = 0
    else
      updChatMembers chat.Members
  clr.push $rootScope.$on "chatMembersUpd", ->
    chat = $scope.chats[$scope.selected]
    if !chat?
      $scope.chatMembers.length = 0
    else
      updChatMembers chat.Members
    $scope.regenMembersList()
  clr.push $rootScope.$on "challengeSnapshot", ->
    challenge = Network.activeChallenge
    if challenge?
      if challenge.ChallengedSID is Auth.currentUser.steam.steamid
        window.aswal = swal(
          title: "Incoming challenge"
          text: "You have an incoming challenge from #{challenge.ChallengerName}!"
          type: "success"
          showCancelButton: true
          confirmButtonColor: "#A5DC86"
          confirmButtonText: "Accept"
          cancelButtonText: "Decline"
          cancelButtonColor: "#DD6B55"
        , ->
          safeApply $scope, ->
            Network.matches.do.respondchallenge true
        , ->
          safeApply $scope, ->
            Network.matches.do.respondchallenge false
        )
    else if window.aswal?
      window.aswal()
      window.aswal = null
  $scope.getMembersArr = (chat)->
    return [] if !chat?
    arr = $scope.chatMemberArrs[chat.Id]
    if !arr?
      arr = $scope.chatMemberArrs[chat.Id] = _.keys chat.Members
    else
    return arr
  $scope.confirmCreateMatch = ->
    nameInput = $("#matchNameInput")[0]
    name = nameInput.inputValue
    if name is ""
      $("#createMatch")[0].opened = true
      new PNotify
        title: "Name Needed"
        text: "Please enter a match name."
        type: "error"
      return
    drp = $("#gameModeInput")[0]
    sel = drp.selectedItem
    if !sel?
      $("#createMatch")[0].opened = true
      new PNotify
        title: "Game Mode Needed"
        text: "Please select a game mode."
        type: "error"
      return
    gm = parseInt $(drp.selectedItem).attr "value"
    console.log "Selected: #{$rootScope.GameModeN[gm]}"
    console.log "Mode ID is #{gm}"
    Network.matches.do.creatematch
      MatchType: 0
      Name: name
      GameMode: gm
  $scope.confirmCreateChallenge = ->
    drp = $("#cPlayerInput")[0]
    sel = drp.selectedItem
    if !sel?
      $("#createChallenge")[0].opened = true
      new PNotify
        title: "Player Needed"
        text: "Please select a player."
        type: "error"
      return
    sid = $(drp.selectedItem).attr "value"
    drp = $("#cgameModeInput")[0]
    sel = drp.selectedItem
    if !sel?
      $("#createChallenge")[0].opened = true
      new PNotify
        title: "Game Mode Needed"
        text: "Please select a game mode."
        type: "error"
      return
    gm = parseInt $(drp.selectedItem).attr "value"
    console.log "Selected: #{sid}"
    console.log "Selected game mode: #{gm}"
    Network.matches.do.startchallenge sid, gm
  $scope.dismissCreate = ->
    $("#createMatch")[0].opened = false
  $scope.dismissChallenge = ->
    $("#createChallenge")[0].opened = false
  # Is currently controlling a game
  $scope.createStartgame = ->
    $("#createMatch")[0].toggle()
    $("#matchNameInput")[0].inputValue = ""
  $scope.createChallenge = ->
    $("#createChallenge")[0].toggle()
  $scope.showRightCont = ->
    Network.liveMatches.length>0||$scope.games.length>0||$scope.canStartGames()||$scope.isAdminOfGame()||Network.activeResult?||Network.activeMatch?||Network.activeChallenge?
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
      swal("Can't Leave", "You can't leave this chat.", "error")
  $scope.isInGame = (game)->
    if !game?
      return Network.activeMatch?
    return false if !Auth.currentUser? or !Network.activeMatch?
    (_.findIndex game.Players, {SID: Auth.currentUser.steam.steamid}) != -1
  $scope.gameList = ->
    return $scope.games
  $scope.allAreReady = ->
    return false if !Network.activeMatch?
    for plyr in Network.activeMatch.Players
      return false if !plyr.Ready
    return true
  $scope.joinGame = (game)->
    Network.matches.do.joinmatch
      Id: game.Id
  $scope.gameFilter = (game)->
    game.Info.Status==0 || (Network.activeMatch? && Network.activeMatch.Id is game.Id)
  $scope.sendChat = (event)->
    msg = event.detail.message
    console.log "sending #{msg}"
    Network.chat.invoke("sendmessage", {Channel: service.chats[$scope.selected].Id, Text: msg})
  $scope.$on 'destroy', ->
    for cl in clr
      cl()
    clr.length = 0
