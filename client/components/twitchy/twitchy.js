'use strict';
(function(angular){

  var http;
  var log = function(msg){
    console.log("[Twitchy] "+msg);
  };

  var pendingResolves = [];
  var pendingResolvesImages = [];

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
  var module = angular.module('twitchy', ['ngSanitize', 'LocalStorageModule']);
  var prov = {
    emotes: {},
    emotesWidths: {}
  };
  window.prov = prov;

  var storageProvider;
  module.config(function(localStorageServiceProvider){
    localStorageServiceProvider.setPrefix("wltwitchy");
  });

  var saveEmotes = function(){
    storageProvider.set("emotes", prov.emotes);
  };

  var saveEmotesWidths = function(){
    storageProvider.set("emotesWidth", prov.emotesWidths);
  };

  var downloadGlobalEmoteData = function() {
    log("[1/3] Looking up global emote data...");
    http.get("https://www.twitchemotes.com/api_cache/v2/global.json")
      .then(function(response) {
        var data = response.data.emotes;
        log("Received "+Object.keys(data).length+" emotes.");
        for(var key in data) {
          prov.emotes[key] = data[key].image_id;
        }
        log("Processed emotes.");
        saveEmotes();
      }, function(response) {
        log("Unable to fetch, error: "+response.status+". Re-checking in 60 seconds.");
        setTimeout(downloadGlobalEmoteData, 60000);
      });
  };

  var downloadChannelEmoteData = function() {
    log("[2/3] Looking up subscriber emote data...");
    http.get("https://www.twitchemotes.com/api_cache/v2/subscriber.json")
      .then(function(response) {
        var i = 0;
        var data = response.data.channels;
        for(var chanid in data) {
          var chan = data[chanid];
          if(!chan.emotes) continue;
          for(var emoti in chan.emotes){
            var emot = chan.emotes[emoti];
            prov.emotes[emot.code] = emot.image_id;
            i++;
          }
        }
        log("Received "+i+" emotes.");
        saveEmotes();
      }, function(response) {
        log("Unable to fetch, error: "+response.status+". Re-checking in 60 seconds.");
        setTimeout(downloadChannelEmoteData, 60000);
      });
  };

  var downloadBttvEmoteData = function() {
    log("[3/3] Looking up bttv emote data...");
    http.get("https://api.betterttv.net/2/emotes/")
      .then(function(response) {
        var i = 0;
        var data = response.data.emotes;
        for(var emoti in data) {
          var emot = data[emoti];
          prov.emotes[emot.code] = emot.id;
          i++;
        }
        log("Received "+i+" emotes.");
        saveEmotes();
      }, function(response) {
        log("Unable to fetch, error: "+response.status+". Re-checking in 60 seconds.");
        setTimeout(downloadChannelEmoteData, 60000);
      });
  };

  module.run(function(localStorageService, $http){
    http = $http;
    storageProvider = localStorageService;
    log("Checking for existing data...");

    var emoteData = localStorageService.get("emotes");
    if(emoteData) {
      log("Using existing emote data, "+Object.keys(emoteData).length+" emotes.");
      prov.emotes = emoteData;
    }else{
      downloadGlobalEmoteData();
      downloadChannelEmoteData();
      downloadBttvEmoteData();
    }

    var emoteWidthData = localStorageService.get("emotesWidth");
    if(emoteWidthData) {
      log("Using existing emote width data, "+Object.keys(emoteWidthData).length+" emotes.");
      prov.emotesWidths = emoteWidthData;
    }else{
      log("No existing width data.");
    }

  });

  module.filter('twitchy', ['$sanitize', '$sce', function($sanitize, $sce) {
    return function(text, target) {
      if (!text) return text;
      text = $sanitize(text);

      // Iterate over words
      var words = text.split(' ');
      for(var emoti in words) {
        var emot = words[emoti];
        var emotid = prov.emotes[emot];
        if(emotid != null){
          var width = prov.emotesWidths[emot];
          var imgurl;
          if(_.isString(emotid)) imgurl = "http://cdn.betterttv.net/emote/"+emotid+"/1x";
          else imgurl = "http://static-cdn.jtvnw.net/emoticons/v1/"+emotid+"/1.0";
          if(width == 0 || !width){
            width = 30;
            var emotnxi = emot;
            if(pendingResolves.indexOf(emot) == -1){
              pendingResolves.push(emotnxi);
              var img = new Image();
              pendingResolvesImages.push(img);
              img.src = imgurl;
              img.onload = function() {
                prov.emotesWidths[emotnxi] = img.width;
                log("Resolved width for "+emotnxi+": "+img.width);
                saveEmotesWidths();
                var idx = pendingResolves.indexOf(emotnxi);
                if(idx != -1){
                  pendingResolves.splice(idx, 1);
                  pendingResolvesImages.splice(idx, 1);
                }
              };
            }
          }
          var reg = new RegExp("\\b"+emot+"\\b", 'g');
          text = text.replace(reg, " <span class='emoteContainer' style='margin-right:"+(width+4)+"px !important'><i data-hint=\""+emot+"\" class=\"twitch hint\" style=\"width:"+width+"px;background:url("+imgurl+") no-repeat;\"/></span> ");
        }
      }

      return $sce.trustAsHtml(text);
    };
  }]);
})(angular);
