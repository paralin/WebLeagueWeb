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
      console.log next
      $location.path "/login" if next.authenticate and not loggedIn
      $location.path "/panel" if loggedIn and next.name is "login"
