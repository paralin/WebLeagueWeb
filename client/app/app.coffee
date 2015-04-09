'use strict'

ignoreNext = true
angular.module 'webleagueApp', [
  'ngResource'
  'ngSanitize'
  'ui.router'
  'ui.bootstrap'
  'ng-polymer-elements'
  'AutoFontSize'
  'pascalprecht.translate'
  'ng-context-menu'
  'vs-repeat'
]
.config ($stateProvider, $urlRouterProvider, $locationProvider, $httpProvider, $translateProvider, $tooltipProvider) ->
  $urlRouterProvider.otherwise '/panel/chat'

  $locationProvider.html5Mode true
  $httpProvider.interceptors.push 'authInterceptor'

  for id, trans of window.translations
    $translateProvider.translations id, trans
  $translateProvider.preferredLanguage 'en'

  $tooltipProvider.options
    appendToBody: true

.factory 'authInterceptor', ($rootScope, $q, $location) ->
  # Add authorization token to headers
  request: (config) ->
    config.headers = config.headers or {}
    config

  # Intercept 401s and redirect you to login
  responseError: (response) ->
    if response.status is 401
      console.log "intercepted #{response.status} -> login"
      $location.path '/login'
    $q.reject response

.run ($rootScope, $location, Auth) ->
  # Redirect to login if route requires auth and you're not logged in
  $rootScope.$on '$stateChangeStart', (event, next) ->
    console.log "Route -> #{next.name}"
    ignoreNext = false if next.name is "panel.chat"
    Auth.getLoginStatus (user, token) ->
      loggedIn = user?
      if next.authenticate
        if !loggedIn
          $location.path "/login"
        else if !user.vouch?
          $location.path "/novouch" if next.name isnt "novouch"
        else if next.name is "login" || next.name is "novouch"
          $location.path "/panel/chat"
          console.log "redirected, #{JSON.stringify user} #{JSON.stringify next}"
        else if ignoreNext
          event.preventDefault()
          ignoreNext = false
  $rootScope.openLink = (url)->
    win = window.open(url, '_blank')
    win.focus()
  $rootScope.GameMode =
    NONE: 0
    AP: 1
    CM: 2
    RD: 3
    SD: 4
    AR: 5
    INTRO: 6
    HW: 7
    REVERSE_CM: 8
    XMAS: 9
    TUTORIAL: 10
    MO: 11
    LP: 12
    POOL1: 13
    FH: 14
    CUSTOM: 15
    CD: 16
    BD: 17
    ABILITY_DRAFT: 18
    EVENT: 19
    ARDM: 20
    SOLOMID: 21
    ALLDRAFT: 22
  $rootScope.GameModeK = _.invert $rootScope.GameMode
  $rootScope.GameModeN =
    #0: "None"
    1: "All Pick"
    2: "Captains Mode"
    3: "Ranked Draft"
    4: "Single Draft"
    5: "All Random"
    #6: "Intro"
    #7: "Halloween"
    8: "Reverse Captains"
    #9: "Xmas"
    #10: "Tutorial"
    11: "Mid Only"
    #12: "Low Priority"
    #13: "Pool1"
    #14: "FH"
    #15: "Custom Games"
    16: "Captains Draft"
    #17: "Balanced Draft"
    18: "Ability Draft"
    #19: "TI4 Event"
    20: "Deathmatch"
    #21: "Solo Mid"
    22: "All Draft"
  $rootScope.GameModeNK = _.invert $rootScope.MatchTypeN
  $rootScope.MatchType =
    STARTGAME: 0
    CAPTAINS: 1
  $rootScope.MatchTypeK = _.invert $rootScope.MatchType
  $rootScope.MatchTypeNS =
    0: "S"
    1: "C"
  $rootScope.SetupStatus =
    QUEUE: 0
    QUEUEHOST: 1
    INIT: 2
    WAIT: 3
    DONE: 4
  $rootScope.SetupStatusK = _.invert $rootScope.SetupStatus
  $rootScope.SetupStatusN =
    0: "Waiting for an available bot..."
    1: "Waiting for an available host.."
    2: "Bot is setting up the lobby..."
    3: "Waiting for players to join..."
    4: "Waiting for match to finalize..."
    5: "Fetching match results..."
  $rootScope.CaptainStatusN =
    0: "Dire captain picking..."
    1: "Radiant captain picking..."
  $rootScope.MatchStateN =
    0: "Initializing match..."
    1: "Waiting for players to load..."
    2: "Players are selecting heros..."
    3: "Strategy time!"
    4: "Pre-game in progress."
    5: "Game in progress."
    6: "Post-game, waiting for match result..."
    7: "All players disconnecting..."
    8: "Showcasing teams ???"
    9: "Last game state!! IDK"
  $rootScope.SoundsURL =
    0: "/assets/sounds/match_ready.wav"
    1: "/assets/sounds/ganked_sml_01.mp3"
    2: "/assets/sounds/ui_button_click_01.wav"
    3: "/assets/sounds/ui_findmatch_join_01.wav"
    4: "/assets/sounds/ui_findmatch_quit_01.wav"
    5: "/assets/sounds/ui_findmatch_search_01.wav"
  $rootScope.SoundsName =
    0: "Match Ready"
    1: "Stunned"
    2: "Button Click"
    3: "Find Match"
    4: "Stop Find Match"
    5: "Find Match (Search)"
  $rootScope.SoundsInstances = {}
  for id, url of $rootScope.SoundsURL
    $rootScope.SoundsInstances[id] = new buzz.sound url
  $rootScope.DefaultSettings =
    language: "en"
  ###
  # Sound Options (Default)
  # type: 0 for sound, 1 for text
  ###
  $rootScope.SoundOptions =
    gameHosted:
      name: "Game Hosted"
      type: 1
      text: "New game hosted!"
      volume: 100
      sound: 0
    challenge:
      name: "Challenge Received"
      type: 0
      sound: 1
      volume: 100
      text: "Challenge received!"
    gameCanceled:
      name: "Game Canceled"
      type: 0
      sound: 4
      volume: 100
      text: "Game canceled!"
    buttonPress:
      name: "General Button Press"
      type: 0
      sound: 2
      volume: 100
      text: "Why would you make this text to speech?"
    lobbyReady:
      name: "Lobby Ready"
      type: 0
      sound: 3
      volume: 100
      text: "Lobby ready!"
    gameJoin:
      name: "Joined Game"
      type: 0
      sound: 3
      volume: 100
      text: "Joined game!"
  $rootScope.fillSettings = (user)->
    user.settings = {} if !user.settings?
    user.settings.language = "en" if !user.settings.language?
    user.settings.sounds = {} if !user.settings.sounds?
    user.settings.soundMuted = false if !user.settings.soundMuted?
    soundIds = _.keys $rootScope.SoundOptions
    for soundid in soundIds
      continue if user.settings.sounds[soundid]?
      user.settings.sounds[soundid] = $rootScope.SoundOptions[soundid]
  $rootScope.playSound = (name)->
    Auth.getLoginStatus (user)->
      if user?
        return if user.settings.soundMuted
        option = user.settings.sounds[name]
        console.log option
        return if !option?
        if option.type is 0
          inst = $rootScope.SoundsInstances[option.sound]
          return if !inst?
          inst.setVolume option.volume
          inst.play()
        else
          if !window.speechSynthesis?
            console.log "!! speech synthesis not available in this browser !!"
            return
          msg = new SpeechSynthesisUtterance(option.text)
          msg.volume = option.volume/100
          window.speechSynthesis.speak(msg)
