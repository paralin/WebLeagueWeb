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

  $scope.shortId = (game)-> game.Id.substring(0, 4)

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
  $scope.dismissResult = ->
    Network.activeResult = null
  $scope.ratingDelta = (res, plyr)->
    return if !res.MatchCounted
    return res.RatingRadiant if plyr.Team == 0
    return res.RatingDire if plyr.Team == 1
    return 0
  $scope.notMe = (member)->
    member.SteamID isnt Auth.currentUser.steam.steamid
  $scope.pickPlayer = (event)->
    Network.matches.pickPlayer event.detail.SID
    $rootScope.playSound "buttonPress"
  $scope.startChallenge = (member, typ, lid)->
    Network.matches.startChallenge
      ChallengedSID: member.SteamID
      League: lid
      MatchType: typ
  $scope.cancelChallenge = ->
    Network.matches.cancelChallenge()
  $scope.kickPlayer = (event)->
    Network.matches.kickPlayer event.detail.SID
    $rootScope.playSound "kicked"
  $scope.toggleSoundMuted = ->
    Auth.currentUser.settings.soundMuted = !Auth.currentUser.settings.soundMuted
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
            Network.matches.challengeResponse true
            $rootScope.playSound "buttonPress"
        , ->
          safeApply $scope, ->
            Network.matches.challengeResponse false
            $rootScope.playSound "buttonPress"
        )
    else if window.aswal?
      window.aswal()
      window.aswal = null
  $scope.canStartGames = ->
    if Auth.currentUser? && !Network.activeMatch? && Auth.currentUser.authItems?
      'startGames' in Auth.currentUser.authItems and 'spectateOnly' not in Auth.currentUser.authItems and "challengeOnly" not in Auth.currentUser.authItems
    else
      false
  $scope.humanizeChatName = (name)->
    Humanize.titleCase name
  $scope.isInGame = (game)->
    if !game?
      return Network.activeMatch?
    return false if !Auth.currentUser? or !Network.activeMatch?
    (_.findIndex game.Players, {SID: Auth.currentUser.steam.steamid}) != -1
  $scope.canJoinGame = (game)->
    !$scope.inAnyGame() and game.Info.Status is 0 and Auth.currentUser? and Auth.currentUser.authItems? and "spectateOnly" not in Auth.currentUser.authItems and ("challengeOnly" not in Auth.currentUser.authItems or game.Info.MatchType == 1)
  $scope.canObsGame = (game)->
    !$scope.inAnyGame() and game.Info.Status < 3
  $scope.canLeaveGame = ()->
    if !game?
      return false if !Network.activeMatch?
      player = (_.findWhere Network.activeMatch.Players, {SID: Auth.currentUser.steam.steamid})
      return false if !player?
      return (player.Team is 2 and Network.activeMatch.Info.Status <= 2) or (Network.activeMatch.Info.Status is 0)
  $scope.deleteGame = (game)->
    swal
      title: "Are you sure?"
      text: "You are about to close an in-progress game. This will shutdown any bots used and kick out all of the players. No results will be recorded."
      type: "error"
      timer: 5000
      showCancelButton: true
      confirmButtonColor: "#DD6B55"
      confirmButtonText: "Close it"
    , (conf)->
      Network.admin.killMatch(game.Id) if conf
  $scope.resultGame = (game, res)->
    swal
      title: "Are you sure?"
      text: "You are about to result an in-progress game. The game will usually end and result itself."
      type: "error"
      timer: 5000
      showCancelButton: true
      confirmButtonColor: "#DD6B55"
      confirmButtonText: "Result it"
    , (conf)->
      Network.admin.resultMatch(game.Id, res) if conf
  $scope.isAdmin = ->
    Auth.currentUser? and Auth.currentUser.authItems? and "admin" in Auth.currentUser.authItems
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
    Network.matches.joinMatch game.Id, false
  $scope.joinGameSpec = (game)->
    $rootScope.playSound "gameJoin"
    Network.matches.joinMatch game.Id, true
  $scope.gameFilter = (game)->
    true #game.Info.Status==0 || (Network.activeMatch? && Network.activeMatch.Id is game.Id)
  $scope.$on 'destroy', ->
    for cl in clr
      cl()
    clr.length = 0
