'use strict';
(function(angular){

  /* global sanitizeText: false */

  /**
   * @ngdoc filter
   * @name twitchy
   * @kind function
   *
   * @description
   * Finds twitch emotes in text input and turns them into css icons.
   *
   * Extendable with paralin/twitch-chat-emoticon-sprites, generate the sprites you want and specify the extra emotes to detect.
   *
   * @param {string} text Input text.
   * @returns {string} Html-linkified text.
   *
   * @usage <span ng-bind-html="twitch_expression | twitchy"></span>
   */
  var module = angular.module('twitchy', ['ngSanitize']);
  var prov = {
    emotes: ["ANELE","ArgieB8","ArsonNoSexy","AsianGlow","AtGL","AtIvy","AtWW","AthenaPMS","BCWarrior","BORT","BabyRage","BatChest","BibleThump","BigBrother","BionicBunion","BlargNaut","BloodTrail","BrainSlug","BrokeBack","BuddhaBar","CorgiDerp","CougarHunt","DAESuppy","DBstyle","DansGame","DatHass","DatSheffy","DogFace","EagleEye","EleGiggle","EvilFetus","FPSMarksman","FUNgineer","FailFish","FrankerZ","FreakinStinkin","Fsociety","FunRun","FuzzyOtterOO","GasJoker","GingerPower","GrammarKing","HassanChop","HelloFriend","HeyGuys","HotPokket","HumbleLife","ItsBoshyTime","JKanStyle","Jebaited","JonCarnage","KAPOW","KZskull","Kappa","Keepo","KevinTurtle","Kippa","Kreygasm","MVGame","Mau5","MechaSupes","MrDestructoid","MrRobot","NightBat","NinjaTroll","NoNoSpot","NotAtk","OMGScoots","OSbeaver","OSbury","OSdeo","OSfrog","OSkomodo","OSrob","OSsloth","OneHand","OpieOP","OptimizePrime","PJHarley","PJSalt","PMSTwin","PRChase","PanicVis","PazPazowitz","PeoplesChamp","PermaSmug","PicoMause","PipeHype","PogChamp","Poooound","PraiseIt","PunchTrees","RaccAttack","RalpherZ","RedCoat","ResidentSleeper","RitzMitz","RuleFive","SMOrc","SMSkull","SSSsss","ShazBotstix","Shazam","ShibeZ","SoBayed","SoonerLater","SriHead","StoneLightning","StrawBeary","SuperVinlin","SwiftRage","TF2John","TTours","TheKing","TheRinger","TheTarFu","TheThing","ThunBeast","TinyFace","TooSpicy","TriHard","UleetBackup","UnSane","UncleNox","Volcania","WTRuck","WholeWheat","WinWaker","WutFace","YouWHY","deExcite","deIlluminati","deShade","mcaT","noScope420","panicBasket","shazamicon","smiley-1","smiley-10","smiley-11","smiley-12","smiley-13","smiley-14","smiley-15","smiley-2","smiley-3","smiley-4","smiley-5","smiley-6","smiley-7","smiley-8","smiley-9","tbBaconBiscuit","tbChickenBiscuit","tbQuesarito","tbSausageBiscuit","tbSpicy","tbSriracha"],
    addEmotes: function(emots){
      emots.forEach(function(emo){
        if(prov.emotes.indexOf(emo)==-1) prov.emotes.push(emo);
      });
    }
  };

  module.factory("twitchyConfig", function() {
    return prov;
  });

  module.filter('twitchy', ['$sanitize', function($sanitize) {
    return function(text, target) {
      if (!text) return text;
      text = $sanitize(text);

      prov.emotes.forEach(function(emot){
        var reg = new RegExp(emot, 'g');
        text = text.replace(reg, "<span class='emoteContainer'><i class=\"twitch "+emot+"\"/></span>");
      });

      return text;
    };
  }]);
})(angular);
