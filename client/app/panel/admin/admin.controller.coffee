'use strict'

angular.module 'webleagueApp'
.controller 'AdminCtrl', ($scope, Network, $rootScope) ->
  $scope.network = Network
  $scope.getOwner = (game)->
    _.findWhere game.Players, {SID: game.Info.Owner}
  $scope.getStatus = (game)->
    if !game.Setup?
      if game.Info.MatchType is 1
        return "Captains pregame..."
      return "Waiting for lobby start..."
    $rootScope.SetupStatusN[game.Setup.Details.Status]
  $scope.getPassword = (game)->
    if !game.Setup?
      return "N/A"
    return game.Setup.Details.Password
  $scope.deleteGame = (game)->
    swal
      title: "Are you sure?"
      text: "You are about to close an in-progress game. This will shutdown any bots used and kick out all of the players. No results will be recorded."
      type: "error"
      timer: 5000
      showCancelButton: true
      confirmButtonColor: "#DD6B55"
      confirmButtonText: "Close it"
    , ->
      #Accept
      Network.admin.do.killmatch game.Id
    , ->
      #Cancel
