'use strict'

angular.module 'webleagueApp'
.controller 'PanelCtrl', ($rootScope, $scope, Auth, Network, safeApply, $state) ->
  clr = []

  meWithGame = (game)->
    _.findWhere game.Players, {SID: Auth.currentUser.steam.steamid}
  $scope.me = (game)->
    if !game?
      for game in Network.availableGames
        me = meWithGame(game)
        return me if me?
    else
      return meWithGame(game)
  $scope.inGame = (game)->
    $scope.me(game)?

  $scope.auth = Auth
  $scope.network = Network
  $scope.state = state = $state
  $scope.chats = Network.chats
  $scope.liveMatches = Network.liveMatches
  $scope.games = Network.availableGames
  $scope.inAnyGame = ->
    for game in $scope.games
      return true if $scope.inGame(game)
    false
  $scope.notMe = (member)->
    member.SteamID isnt Auth.currentUser.steam.steamid
  $scope.pickPlayer = (event)->
    Network.matches.do.pickPlayer event.detail.SID
    $rootScope.playSound "buttonPress"
  $scope.cancelChallenge = ->
    Network.matches.do.cancelChallenge()
  $scope.kickPlayer = (event)->
    Network.matches.do.kickPlayer event.detail.SID
    $rootScope.playSound "kicked"
  $scope.toggleSoundMuted = (mute)->
    Auth.currentUser.settings.soundMuted = mute
    Auth.saveSettings()
  playNewGame = _.debounce ->
    $rootScope.playSound "gameHosted"
  , 1000, {leading: true, trailing: false}
  clr.push $rootScope.$on "newGameHosted", (eve, match)->
    playNewGame() if match.Info.League in Auth.currentUser.vouch.leagues and !$scope.inAnyGame()
  clr.push $rootScope.$on "lobbyReady", ->
    $rootScope.playSound "lobbyReady"
  clr.push $rootScope.$on "kickedFromSG", ->
    $rootScope.playSound "kicked"
    swal
      title: "Kicked from Match"
      type: "error"
      text: "You have been kicked from the game by its owner."
  clr.push $rootScope.$on "challengeSnapshot", ->
    challenge = Network.activeChallenge
    if challenge?
      if challenge.ChallengedSID is Auth.currentUser.steam.steamid
        $rootScope.playSound "challenge"
        window.aswal = swal.close
        swal(
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
            $rootScope.playSound "buttonPress"
        , ->
          safeApply $scope, ->
            Network.matches.do.respondchallenge false
            $rootScope.playSound "buttonPress"
        )
    else if window.aswal?
      window.aswal()
      window.aswal = null
  $scope.sortedGameModes = ->
    _.keys($rootScope.GameModeN).map(Number)
  $scope.createStartgame = (mod)->
    Network.matches.do.creatematch
      GameMode: mod
  $scope.showRightCont = ->
    Network.liveMatches.length>0||$scope.games.length>0||$scope.canStartGames()||$scope.isAdminOfGame()||Network.activeResult?||Network.activeMatch?||Network.activeChallenge?
  $scope.isAdminOfGame = ->
    return false if !Auth.currentUser? or !Network.activeMatch?
    Network.activeMatch.Info.Owner is Auth.currentUser.steam.steamid
  $scope.canStartGames = ->
    if Auth.currentUser? && !Network.activeMatch? && Auth.currentUser.authItems?
      'startGames' in Auth.currentUser.authItems and 'spectateOnly' not in Auth.currentUser.authItems and "challengeOnly" not in Auth.currentUser.authItems
    else
      false
  $scope.showJoinDialog = ->
    swal {
      title: 'Open Chat'
      text: 'Enter the chat name.'
      type: 'input'
      showCancelButton: true
      animation: 'slide-from-top'
      inputPlaceholder: 'Write a chat'
    }, (inputValue) ->
      if inputValue == false
        return false
      if inputValue == ''
        swal.showInputError 'You need to write something!'
        return false
      $rootScope.playSound "buttonPress"
      Network.chat.invoke("joinorcreate", {Name: inputValue}).then (err)->
        if err?
          new PNotify
            title: "Join Error"
            text: err
            type: "error"
            desktop:
              desktop: true
          return
      return
    return
  $scope.humanizeChatName = (name)->
    Humanize.titleCase name
  $scope.isInGame = (game)->
    if !game?
      return Network.activeMatch?
    return false if !Auth.currentUser? or !Network.activeMatch?
    (_.findIndex game.Players, {SID: Auth.currentUser.steam.steamid}) != -1
  $scope.canJoinGame = (game)->
    Auth.currentUser? and Auth.currentUser.authItems? and "spectateOnly" not in Auth.currentUser.authItems and ("challengeOnly" not in Auth.currentUser.authItems or game.Info.MatchType == 1)
  $scope.canLeaveGame = ()->
    if !game?
      return false if !Network.activeMatch?
      player = (_.findWhere Network.activeMatch.Players, {SID: Auth.currentUser.steam.steamid})
      return false if !player?
      return (player.Team is 2 and Network.activeMatch.Info.Status <= 2) or (Network.activeMatch.Info.Status is 0)
  $scope.showTsInfoModal = ->
    $(".tsInfo")[0].open()
  $scope.gameList = ->
    return $scope.games
  $scope.allAreReady = ->
    return false if !Network.activeMatch?
    for plyr in Network.activeMatch.Players
      return false if !plyr.Ready and plyr.Team < 2
    return true
  $scope.joinGame = (game)->
    $rootScope.playSound "gameJoin"
    Network.matches.do.joinmatch
      Id: game.Id
      Spec: false
  $scope.joinGameSpec = (game)->
    $rootScope.playSound "gameJoin"
    Network.matches.do.joinmatch
      Id: game.Id
      Spec: true
  $scope.gameFilter = (game)->
    true #game.Info.Status==0 || (Network.activeMatch? && Network.activeMatch.Id is game.Id)
  $scope.$on 'destroy', ->
    for cl in clr
      cl()
    clr.length = 0
