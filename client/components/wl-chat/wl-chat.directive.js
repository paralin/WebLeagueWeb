'use strict';
angular.module('webleagueApp').directive('wlChat', function() {
    return {
        templateUrl: '/components/wl-chat/wl-chat.html',
        scope: {
            chat: '=',
            sendchat: '&'
        },
        link: function(scope, element, attrs){
            element.bind("keypress", function(event) {
                if(event.which === 13) {
                    var chatbox = element.find("#inputcont")[0];
                    var msg = chatbox.inputValue;
                    chatbox.inputValue = "";
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
