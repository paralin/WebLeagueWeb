'use strict'

angular.module 'webleagueApp'
.controller 'PanelCtrl', ($scope, Auth, Network) ->
  $scope.auth = Auth
  $scope.network = Network
  $scope.selected = 0
  $scope.chats = [
    {
      title: "Main Chat"
      messages: [{
        member: "quantum"
        msg: "This is the main chat!"
      }],
      members: {
        quantum: {
          name: "Quantum"
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
  $scope.$watch 'selected', (newVal, oldVal)->
    console.log oldVal+" => "+newVal
