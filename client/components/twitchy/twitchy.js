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
    emotes: ["ANELE","ArgieB8","ArsonNoSexy","AsianGlow","AtGL","AtIvy","AtWW","AthenaPMS","BCWarrior","BORT","BabyRage","BatChest","BibleThump","BigBrother","BionicBunion","BlargNaut","BloodTrail","BrainSlug","BrokeBack","BuddhaBar","CorgiDerp","CougarHunt","DAESuppy","DBstyle","DansGame","DatHass","DatSheffy","DogFace","EagleEye","EleGiggle","EvilFetus","FPSMarksman","FUNgineer","FailFish","FrankerZ","FreakinStinkin","Fsociety","FunRun","FuzzyOtterOO","GasJoker","GingerPower","GrammarKing","HassanChop","HelloFriend","HeyGuys","HeyyyLulu","HotPokket","HumbleLife","ItsBoshyTime","JKanStyle","Jebaited","JonCarnage","KAPOW","KZskull","Kappa","Keepo","KevinTurtle","Kippa","Kreygasm","MVGame","Mau5","MechaSupes","MrDestructoid","MrRobot","NightBat","NinjaTroll","NoNoSpot","NotAtk","OMGScoots","OSbeaver","OSbury","OSdeo","OSfrog","OSkomodo","OSrob","OSsloth","OneHand","OpieOP","OptimizePrime","PJHarley","PJSalt","PMSTwin","PRChase","PanicVis","PazPazowitz","PeoplesChamp","PermaSmug","PicoMause","PipeHype","PogChamp","Poooound","PraiseIt","PunchTrees","RaccAttack","RalpherZ","RedCoat","ResidentSleeper","RitzMitz","RuleFive","SMOrc","SMSkull","SSSsss","ShazBotstix","Shazam","ShibeZ","SoBayed","SoonerLater","SriHead","StoneLightning","StrawBeary","SuperVinlin","SwiftRage","TF2John","TTours","TheKing","TheRinger","TheTarFu","TheThing","ThunBeast","TinyFace","TooSpicy","TriHard","UleetBackup","UnSane","UncleNox","Volcania","WTRuck","WholeWheat","WinWaker","WutFace","YouWHY","_4Head","adbc","admiralDream","admiralFood","admiralGame","admiralGasm","admiralHYPE","admiralHappy","admiralHug","admiralKappe","admiralKristin","admiralS4","admiralSexy","admiralW","apollosc","beststudio","dadAm","dadAwful","dadChamp","dadFlame","dadHi","dadPeppers","dadPuck","dadSkyl","dadSlark","dadWerk","dadXD","deExcite","deIlluminati","deShade","emgHat","fearDoto","fearFreeToFeed","fearFreeToPlay","fearGASM","forsen30","forsenAbort","forsenBM","forsenBanned","forsenBeast","forsenBoys","forsenDDK","forsenGasm","forsenKappa","forsenKev","forsenMoney","forsenODO","forsenOP","forsenPlugdj","forsenRP","forsenSS","forsenSambool","forsenSleeper","forsenSnus","forsenSwag","forsenTriple","forsenW","forsenWOW","forsenWot","hlspwn","isfrog","lirikAppa","lirikB","lirikC","lirikCHAMP","lirikCLENCH","lirikCRASH","lirikD","lirikF","lirikFAT","lirikGOTY","lirikGasm","lirikH","lirikHYPE","lirikHug","lirikL","lirikLEWD","lirikM","lirikMEOW","lirikMLG","lirikNICE","lirikNOT","lirikO","lirikPOOP","lirikREKT","lirikRIP","lirikTEN","lirikTRASH","lirikThump","lirikW","lirikWc","mcaT","meanderBigPlays","meanderChamp","meanderNevaEva","meanderRage","meanderStrat","meanderSunMeander","monkeysFace","monkeysFlame","monkeysGotem","monkeysPat","monkeysPeel","monkeysStorm","noScope420","numan","panicBasket","rtzFail","rtzGodDAMN","rtzPotato","rtzSmooth","rtzSun","rtzW","sajDance","sajHype","sajKingB","sajMonkey","sajNoBoots","sajPee","sajRNG","sajSalt","shazamicon","singsingDoge","singsingKawaii","singsingMimimi","singsingPLD","singsingSaiyan","singsingStayinthetrees","singsingWat","skrffz","smlr","sonyaDragon","sonyaEvil","sonyaFail","sonyaGasm","sonyaGift","sonyaKnight","sonyaLove","sonyaMute","sonyaOP","sonyaOrange","sonyaPower","sonyaTaco","sonyaThump","sumailKappa","sumailRight","sumailSwag","sumailWrong","supsonl","supsonr","synd4Giggle","syndAl","syndEleHead","syndErwin","syndFeedereN","syndMagnet","syndRageMilk","syndSilly","tbBaconBiscuit","tbChickenBiscuit","tbQuesarito","tbSausageBiscuit","tbSpicy","tbSriracha","tranceh","trumpBear","trumpChicken","trumpChow","trumpCookie","trumpCrab","trumpDepends","trumpGive","trumpKappa","trumpMusic","trumpPrison","trumpRope","trumpSci","trumpStats","trumpTSM","trumpThump","trumpUp","trumpValue","trumpW","trumpWhat","vcat","wagaBoom","wagaChamp","wagaCrit","wagaDoubt","wagaFish","wagaGasm","wagaMunch","wagaRage","wagaRawr","wagaRosh","wagaSilence","wagaTa","wagaThump","walterw","wps"],
    emotesWidths: [28,28,18,24,28,28,28,28,29,19,28,18,36,24,30,21,41,30,28,28,28,21,28,21,25,28,24,22,18,28,29,20,24,22,40,19,28,27,26,28,21,28,19,28,28,28,28,28,18,21,21,20,28,28,25,27,21,24,19,24,28,28,39,28,28,19,23,28,22,28,28,28,28,28,28,28,20,21,22,28,36,23,28,28,18,28,28,22,28,23,21,28,24,28,33,19,28,28,20,32,24,24,24,28,28,24,23,28,20,20,23,21,22,28,28,20,25,28,26,19,23,24,17,28,28,27,28,20,30,28,28,20,23,28,28,28,28,28,28,28,28,28,28,28,28,60,60,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,60,25,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,60,28,60,28,28,22,28,28,28,28,28,28,28,48,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,31,36,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,45,45,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,30,28,28,28,28,28,28,28,28,28,28,28,28,28,60,22],
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
        var reg = new RegExp(emotx, 'g');
        text = text.replace(reg, "<span class='emoteContainer' style=margin-right:"+(prov.emotesWidths[i]+4)+"px !important'><i data-hint=\""+emotx+"\" class=\"twitch "+emot+" hint\"/></span>");
        i++;
      });

      return $sce.trustAsHtml(text);
    };
  }]);
})(angular);
