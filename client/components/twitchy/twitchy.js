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
    emotes: ["ANELE","AngelThump","ArgieB8","ArsonNoSexy","AsianGlow","AtGL","AtIvy","AtWW","AthenaPMS","BCWarrior","BORT","BabyRage","BaconEffect","BadAss","BasedGod","BatChest","BatKappa","BibleThump","BigBrother","BionicBunion","Blackappa","BlargNaut","BloodTrail","BrainSlug","BroBalt","BrokeBack","BuddhaBar","ButterSauce","CHAccepted","CandianRage","CiGrip","ConcernDoge","CorgiDerp","CougarHunt","CruW","DAESuppy","DBstyle","DOOMGuy","DansGame","DatHass","DatSauce","DatSheffy","DogFace","DogeWitIt","EagleEye","EleGiggle","EvilFetus","FPSMarksman","FUNgineer","FailFish","FapFapFap","FeelsBadMan","FeelsGoodMan","FireSpeed","FishMoley","ForeverAlone","FrankerZ","FreakinStinkin","Fsociety","FuckYea","FunRun","FuzzyOtterOO","GabeN","GasJoker","GingerPower","GrammarKing","HHydro","HailHelix","HassanChop","HelloFriend","HerbPerve","HeyGuys","HeyyyLulu","Hhhehehe","HotPokket","HumbleLife","ItsBoshyTime","JKanStyle","Jebaited","JonCarnage","KAPOW","KKona","KZskull","KaRappa","Kaged","Kappa","KappaPride","Keepo","KevinTurtle","Kippa","Kreygasm","MVGame","Mau5","MechaSupes","MrDestructoid","MrRobot","NaM","NightBat","NinjaTroll","NoNoSpot","NotAtk","OMGScoots","OSbeaver","OSbury","OSdeo","OSfrog","OSkomodo","OSrob","OSsloth","OhGod","OhMyGoodness","OhhhKee","OneHand","OpieOP","OptimizePrime","PJHarley","PJSalt","PMSTwin","PRChase","PancakeMix","PanicVis","PazPazowitz","PedoBear","PeoplesChamp","PermaSmug","Phines","PicoMause","PipeHype","PogChamp","PokerFace","PoleDoge","Poooound","PraiseIt","PunchTrees","RaccAttack","RageFace","RalpherZ","RarePepe","RebeccaBlack","RedCoat","ResidentSleeper","RitzMitz","RuleFive","SMOrc","SMSkull","SSSsss","SavageJerky","SexPanda","ShazBotstix","Shazam","ShibeZ","ShoopDaWhoop","SoBayed","SoSerious","SoonerLater","SriHead","SteamSale","StoneLightning","StrawBeary","SuchFraud","SuperVinlin","SwedSwag","SwiftRage","TF2John","TTours","TaxiBro","TheKing","TheRinger","TheTarFu","TheThing","ThunBeast","TinyFace","TooSpicy","TopHam","TriHard","TwaT","UleetBackup","UnSane","UncleNox","VaultBoy","VisLaud","Volcania","WTRuck","WatChuSay","WhatAYolk","WholeWheat","WinWaker","WutFace","YetiZ","YouWHY","_4Head","aPliS","adbc","admiralDream","admiralFood","admiralGame","admiralGasm","admiralHYPE","admiralHappy","admiralHug","admiralKappe","admiralKristin","admiralS4","admiralSexy","admiralW","apollosc","ariseHS","ariseSSJ","bUrself","beststudio","bttvAngry","bttvConfused","bttvCool","bttvGrin","bttvHappy","bttvHeart","bttvNice","bttvSad","bttvSleep","bttvSurprised","bttvTongue","bttvTwink","bttvUnsure","bttvWink","dadAm","dadAwful","dadChamp","dadFlame","dadHi","dadPeppers","dadPuck","dadSkyl","dadSlark","dadWerk","dadXD","dagerDendi","dagerFromDendi","dagerPudge","ddmBulbaPlz","ddmDemonDoto","ddmGASM","ddmGetDunked","ddmKpop","ddmLAMO","ddmOldManFear","deExcite","deIlluminati","emgHat","faceyA","faceyAce","faceyDBL","faceyDBR","faceyDance","faceyDdk","faceyFacey","faceyH","faceyHorse","faceyJZFB","faceyJuan","faceyKnife","faceyLord","faceyMaster","faceyN","faceyNade","faceyP","faceyR","faceyRIP","faceyTaz","faceyThoorin","faceyTop","faceyW","faceyWheel","fearDoto","fearFreeToFeed","fearFreeToPlay","fearGASM","forsen30","forsenAbort","forsenBM","forsenBanned","forsenBeast","forsenBoys","forsenDDK","forsenGasm","forsenKappa","forsenKev","forsenMoney","forsenODO","forsenOP","forsenPlugdj","forsenRP","forsenSS","forsenSambool","forsenSleeper","forsenSnus","forsenSwag","forsenTriple","forsenW","forsenWOW","forsenWot","gmgAlf","haHAA","hlspwn","iDog","iamsocal","isfrog","lirikAppa","lirikB","lirikC","lirikCHAMP","lirikCLENCH","lirikCRASH","lirikD","lirikF","lirikFAT","lirikFEELS","lirikGOTY","lirikGasm","lirikH","lirikHYPE","lirikHug","lirikL","lirikLEWD","lirikM","lirikMEOW","lirikMLG","lirikNICE","lirikNOT","lirikO","lirikPOOP","lirikREKT","lirikRIP","lirikTEN","lirikTRASH","lirikThump","lirikW","lirikWc","mcaT","meanderBigPlays","meanderChamp","meanderNevaEva","meanderRage","meanderStrat","meanderSunMeander","miniJulia","motnahP","numan","panicBasket","ppdBB","ppdDZ","ppdDead","ppdGLHF","ppdGS","ppdSalt","ppdTilting","ppdUSA","rStrike","rtzFail","rtzGodDAMN","rtzPotato","rtzSmooth","rtzSun","rtzW","sajDance","sajHype","sajKingB","sajMonkey","sajNoBoots","sajPee","sajRNG","sajSalt","shazamicon","singsingDoge","singsingKawaii","singsingMimimi","singsingPLD","singsingSaiyan","singsingStayinthetrees","singsingWat","skrffz","smlr","sosGame","sumailKappa","sumailRight","sumailSwag","sumailWrong","supsonl","supsonr","synd4Giggle","syndAl","syndEleHead","syndErwin","syndFeedereN","syndMagnet","syndRageMilk","syndSilly","tbBaconBiscuit","tranceh","trumpBear","trumpChicken","trumpChow","trumpCookie","trumpCrab","trumpDepends","trumpGive","trumpKappa","trumpMusic","trumpPrison","trumpRope","trumpSci","trumpStats","trumpTSM","trumpThump","trumpUp","trumpValue","trumpW","trumpWhat","universeEvilYang","universeFV","universeJacket","universeJafaVerse","universeJauismine","universePPDPeter","universeSimbaRTZ","universeSwoleFear","universeZaired","vcat","wagaBoom","wagaChamp","wagaCrit","wagaDoubt","wagaFish","wagaGasm","wagaMunch","wagaRage","wagaRawr","wagaRosh","wagaSilence","wagaTa","wagaThump","walterw","wps"],
    emotesWidths: [28,84,28,18,24,28,28,28,28,29,19,28,28,28,28,18,28,36,24,30,28,21,41,30,46,28,28,28,28,28,28,26,28,21,28,28,21,28,25,28,28,24,22,28,18,28,29,20,24,22,28,30,30,53,56,28,40,19,28,28,27,26,28,28,21,28,28,28,19,28,28,28,28,28,28,28,18,21,21,20,28,25,28,28,28,25,28,27,21,24,19,24,28,28,39,28,38,28,19,23,28,22,28,28,28,28,28,28,28,28,28,28,20,21,22,28,36,23,28,28,28,18,28,28,28,28,22,28,23,28,28,21,28,24,28,28,33,28,28,19,28,28,20,32,24,24,28,36,24,28,28,28,24,28,23,28,28,20,20,28,23,28,21,22,28,87,28,20,25,28,26,19,23,28,24,28,17,28,28,28,28,27,28,28,28,20,30,28,60,28,20,28,23,28,28,28,28,28,28,28,28,28,28,28,28,60,28,28,28,60,28,28,28,28,28,28,42,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,17,28,60,28,28,25,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,60,28,60,28,28,22,28,28,48,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,31,36,28,28,28,28,28,45,45,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,30,28,28,28,28,28,28,28,28,28,28,28,28,28,60,22],
    addEmotes: function(emots){
      emots.forEach(function(emo){
        if(prov.emotes.indexOf(emo)==-1) prov.emotes.push(emo);
      });
    }
  };

  module.factory("twitchyConfig", function() {
    return prov;
  });

  module.filter('twitchy', ['$sanitize', '$sce', function($sanitize, $sce) {
    return function(text, target) {
      if (!text) return text;
      text = $sanitize(text);

      var i = 0;
      prov.emotes.forEach(function(emot){
        var emotx = emot.replace("_", "");
        var reg = new RegExp("\\b"+emotx+"\\b", 'g');
        text = text.replace(reg, " <span class='emoteContainer' style=margin-right:"+(prov.emotesWidths[i]+4)+"px !important'><i data-hint=\""+emotx+"\" class=\"twitch "+emot+" hint\"/></span> ");
        i++;
      });

      return $sce.trustAsHtml(text);
    };
  }]);
})(angular);
