'use strict'

angular.module 'webleagueApp'
.controller 'SettingsCtrl', ($scope, $rootScope, Auth, $translate) ->
  Auth.getLoginStatus ->
    settings = $scope.settings = _.clone Auth.currentUser.settings
    $scope.languageids = []
    $scope.languages = {}
    $scope.settingsDirty = false
    window.scope = $scope
    i = 0
    for id, lng of window.translations
      if settings.language is id
        $scope.selectedLanguage = i
      $scope.languageids.push id
      $scope.languages[id] = lng.language
      i++
    $scope.revertSettings = ->
      i = 0
      for id, lng of window.translations
        if settings.language is id
          $scope.selectedLanguage = i
        i++
      $scope.settingsDirty = false
    $scope.saveSettings = ->
      Auth.currentUser.settings = settings
      for id, sound of settings.sounds
        sound.type = if sound.type then 1 else 0
      Auth.saveSettings()
      $scope.settingsDirty = false
    $scope.playSound = (id, volume)->
      $rootScope.SoundsInstances[id].stop()
      $rootScope.SoundsInstances[id].setVolume volume
      $rootScope.SoundsInstances[id].play()
      $scope.settingsDirty = true
    $scope.setSettingsDirty = ->
      $scope.settingsDirty = true
    $scope.playTts = (text, volume)->
      if !window.speechSynthesis?
        swal
          title: "Not Supported"
          text: "Your browser doesn't support text to speech. Use chrome!"
          type: "error"
        return
      msg = new SpeechSynthesisUtterance()
      msg.text = text
      msg.volume = volume/100
      msg.voice = voice = speechSynthesis.getVoices()[0]
      msg.voiceURI = voice.voiceURI
      msg.lang = "en-US"
      window.speechSynthesis.speak(msg)
    $scope.$watch "selectedLanguage", (lang)->
      return if $scope.languageids[lang] is settings.language
      settings.language = $scope.languageids[lang]
      $translate.use(settings.language)
      $scope.settingsDirty = true
