angular.module('ng-polymer-elements').constant '$ngPolymerMappings',
  wlChat:
    ngModel: primitive: 'chat'
    ngSendchat: event: 'sendchat'
    ngMembersarr: primitive: 'membersArr'
  liveMatches:
    ngMatchTypes: primitive: 'modes'
    ngModel: primitive: 'matches'
    ngGameModes: primitive: 'gmodes'
  matchResult: ngModel: primitive: 'result'
  pendingChallenge:
    ngCanceledChallenge: event: 'cancel-challenge'
  matchGame:
    ngModel: primitive: 'match'
    ngGameModes: primitive: 'gametypes'
    ngMatchTypes: primitive: 'modes'
    ngInGame: primitive: 'inGame'
    ngPressedJoin: event: 'pressed-join'
    ngPressedJoinSpec: event: 'pressed-join-spec'
    ngPickedPlayer: event: 'picked-player'
    ngKickedPlayer: event: 'kicked-player'
    ngSetupStatusn: primitive: 'setupstatusn'
    ngCanJoin: primitive: 'canJoin'
    ngCaptainStatusn: primitive: 'captainstatusn'
    ngSteamid: primitive: 'steamid'
    ngMatchStates: primitive: 'matchstatesn'
  paperDropdownMenu: ngLabel: primitive: 'label'
  coreMenu: ngModel: primitive: 'selected'
  paperInput:
    ngLabel: primitive: 'label'
    ngError: primitive: 'error'
    ngModel: primitive: 'value'
    ngCommittedModel: primitive: 'committedValue'
  paperToastFa:
    ngOpened: primitive: 'opened'
    ngText: primitive: 'text'
  paperActionDialog:
    ngHeading: primitive: 'heading'
    ngOpened: primitive: 'opened'
  paperDialog:
    ngHeading: primitive: 'heading'
    ngOpened: primitive: 'opened'
