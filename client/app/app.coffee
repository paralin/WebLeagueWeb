'use strict'

angular.module 'webleagueApp', [
  'ngResource',
  'ngSanitize',
  'ui.router',
  'ui.bootstrap',
  'ng-polymer-elements'
]
.config ($stateProvider, $urlRouterProvider, $locationProvider, $httpProvider) ->
  $urlRouterProvider
  .otherwise '/panel'

  $locationProvider.html5Mode true
  $httpProvider.interceptors.push 'authInterceptor'

.factory 'authInterceptor', ($rootScope, $q, $location) ->
  # Add authorization token to headers
  request: (config) ->
    config.headers = config.headers or {}
    config

  # Intercept 401s and redirect you to login
  responseError: (response) ->
    if response.status is 401
      $location.path '/login'
    $q.reject response

.run ($rootScope, $location, Auth) ->
  # Redirect to login if route requires auth and you're not logged in
  $rootScope.$on '$stateChangeStart', (event, next) ->
    Auth.getLoginStatus (user, token) ->
      loggedIn = user?
      $location.path "/login" if next.authenticate and not loggedIn
      $location.path "/panel" if loggedIn and next.name is "login"
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
    4: "Game is ready to begin."
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
