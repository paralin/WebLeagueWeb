'use strict'

#
# * SteamID Converter by xPaw
# *
# * Website: http://xpaw.ru
# * GitHub: https://github.com/xPaw/SteamID
# 
SteamID = (input) ->
  if typeof input isnt "undefined"
    if @IsCommunityID(input) isnt null
      return @SetCommunityID(input)
    else if @IsSteam2(input) isnt null
      return @SetSteam2(input)
    else
      return @SetAccountID(input)
  this

SteamID:: =
  AccountID: 0
  IsCommunityID: (CommunityID) ->
    return null  if typeof CommunityID isnt "string"
    CommunityID.match /^7656119([0-9]{10})$/

  IsSteam2: (SteamID) ->
    return null  if typeof SteamID isnt "string"
    SteamID.match /^STEAM_[0-5]:([0-1]):([0-9]+)$/

  SetAccountID: (AccountID) ->
    if typeof AccountID is "number"
      @AccountID = AccountID
    else if typeof AccountID is "string" and not isNaN(AccountID)
      @AccountID = parseInt(AccountID, 10)
    else
      
      #throw new Error( 'Input must be string or number' );
      return false
    this

  SetCommunityID: (CommunityID) ->
    CommunityID = @IsCommunityID(CommunityID)
    
    #throw new Error( 'Input is not a valid CommunityID' );
    return false  if CommunityID is null
    
    # TODO: What the fuck is going on below this line, terrible
    CommunityID = CommunityID[0].substring(7)
    ID = CommunityID % 2
    CommunityID = (CommunityID - ID - 7960265728) / 2
    @AccountID = (CommunityID << 1) | ID
    this

  SetSteam2: (SteamID) ->
    SteamID = @IsSteam2(SteamID)
    
    #throw new Error( 'Input is not a valid SteamID' );
    return false  if SteamID is null
    @AccountID = (SteamID[2] << 1) | SteamID[1]
    this

  GetCommunityID: ->
    "7656119" + (7960265728 + @AccountID)

  GetSteam2: ->
    "STEAM_0:" + (@AccountID & 1) + ":" + (@AccountID >> 1)

  GetSteam3: ->
    "[U:1:" + @AccountID + "]"

  GetAccountID: ->
    @AccountID


angular.module('webleagueApp').factory 'SteamID', ->
  window.steamid = SteamID
