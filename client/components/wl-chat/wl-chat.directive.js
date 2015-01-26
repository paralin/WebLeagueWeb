'use strict';
angular.module('webleagueApp').directive('wlChat', function($state, Auth, $timeout) {
  return {
    templateUrl: '/components/wl-chat/wl-chat.html',
    scope: {
      chat: '=',
      sendchat: '&',
      sendchallenge: '&'
    },
    link: function(scope, element, attrs){
      scope.$watch('chat', function(newChat, oldChat){
        //Check if we need to scroll down
        element = $(".msg-container")[0];
        if (element.scrollTop > element.scrollHeight - 400)
          $timeout(function(){ element.scrollTop = element.scrollHeight+500; }, 100, false);
        console.log("scrollTop: "+element.scrollTop+" scrollHeight: "+element.scrollHeight);
      }, true);
      scope.setSelectedMember = function(member){
        scope.selectedMember = member;
        console.log(member);
      };
      scope.viewProfile = function(member){
        $state.go("panel.profile", {id: member.UID});
      };
      scope.canChallenge = function(member){
        return member != null && member.SteamID !== Auth.currentUser.steam.steamid && _.contains(Auth.currentUser.authItems, "startGames");
      };
      scope.sendChallenge = function(member){
        scope.sendchallenge({member: member});
      };
      scope.steamProfile = function(member){
        window.open('http://steamcommunity.com/profiles/'+member.SteamID,'_blank');
      };
      element.bind("keypress", function(event) {
        if(event.which === 13) {
          var msg = scope.chatInput;
          scope.chatInput = "";
          if(msg.length > 0){
            scope.$apply(function() {
              console.log(msg);
              scope.sendchat({message: msg});
            });
          }
        }
      });
    }
  };
});
