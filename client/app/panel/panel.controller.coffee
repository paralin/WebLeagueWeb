'use strict'

angular.module 'webleagueApp'
.controller 'PanelCtrl', ($scope, Auth, Network) ->
  $scope.auth = Auth
  $scope.network = Network
  $scope.selected = 0
  $scope.chats = Network.chats
  ###
  $scope.chats = [
    {
      id: "35123523--325-23235235"
      title: "Main Chat"
      messages: [{
        member: "quantum"
        msg: "This is the main chat!"
      }],
      members: {
        quantum: {
          Name: "Quantum"
          SteamID: "531252835812358"
        }
      }
    }
    {
      title: "PM: Dendi"
      messages: [{
        member: "quantum"
        msg: "Hey, what's up dendi!"
      }
      {
        member: "dendi"
        msg: "привет я круто"
      }],
      members: {
        dendi: {
          name: "Na`Vi Dendi"
        }
        quantum: {
          name: "Quantum"
        }
      }
    }
  ]
  ###
