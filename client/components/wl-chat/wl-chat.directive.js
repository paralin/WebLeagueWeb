'use strict';
angular.module('webleagueApp').directive('wlChat', function($state, Auth, $timeout, Network) {
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
        element = $(".msg-container");
        if(element.length == 0) return;
        element = element[0];
        if (element.scrollTop > element.scrollHeight - (element.offsetHeight+30)){
          $timeout(function(){
            element = $(".msg-container")[0];
            element.scrollTop = element.scrollHeight+element.offsetHeight+50;
          }, 10, false);
        }
      }, true);
      scope.setSelectedMember = function(member){
        scope.selectedMember = member;
      };
      scope.viewProfile = function(member){
        $state.go("panel.profile", {id: member.UID});
      };
      scope.canChallenge = function(member){
        return member != null && member.SteamID !== Auth.currentUser.steam.steamid && _.contains(Auth.currentUser.authItems, "startGames");
      };
      scope.isMe = function(member){
        return member != null && member.SteamID === Auth.currentUser.steam.steamid;
      };
      scope.sendChallenge = function(member){
        scope.sendchallenge({member: member});
      };
      scope.steamProfile = function(member){
        window.open('http://steamcommunity.com/profiles/'+member.SteamID,'_blank');
      };
      scope.openDirectMessage = function(member){
        Network.chat.invoke("joinorcreate", {Name: member.SteamID, OneToOne: true});
      };
      scope.memberRole = function(member){
        switch(member.MemberType)
        {
          case 1:
            return "Moderator";
          case 2:
            return "Admin";
        }
        return "";
      };
      scope.values = function(members) {
        return _.values(members);
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
