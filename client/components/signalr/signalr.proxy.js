/*!
 * ASP.NET SignalR JavaScript Library v2.2.0
 * http://signalr.net/
 *
 * Copyright Microsoft Open Technologies, Inc. All rights reserved.
 * Licensed under the Apache 2.0
 * https://github.com/SignalR/SignalR/blob/master/LICENSE.md
 *
 */

/// <reference path="..\..\SignalR.Client.JS\Scripts\jquery-1.6.4.js" />
/// <reference path="jquery.signalR.js" />
(function ($, window, undefined) {
    /// <param name="$" type="jQuery" />
    "use strict";

    if (typeof ($.signalR) !== "function") {
        throw new Error("SignalR: SignalR is not loaded. Please ensure jquery.signalR-x.js is referenced before ~/signalr/js.");
    }

    var signalR = $.signalR;

    function makeProxyCallback(hub, callback) {
        return function () {
            // Call the client hub method
            callback.apply(hub, $.makeArray(arguments));
        };
    }

    function registerHubProxies(instance, shouldSubscribe) {
        var key, hub, memberKey, memberValue, subscriptionMethod;

        for (key in instance) {
            if (instance.hasOwnProperty(key)) {
                hub = instance[key];

                if (!(hub.hubName)) {
                    // Not a client hub
                    continue;
                }

                if (shouldSubscribe) {
                    // We want to subscribe to the hub events
                    subscriptionMethod = hub.on;
                } else {
                    // We want to unsubscribe from the hub events
                    subscriptionMethod = hub.off;
                }

                // Loop through all members on the hub and find client hub functions to subscribe/unsubscribe
                for (memberKey in hub.client) {
                    if (hub.client.hasOwnProperty(memberKey)) {
                        memberValue = hub.client[memberKey];

                        if (!$.isFunction(memberValue)) {
                            // Not a client hub function
                            continue;
                        }

                        subscriptionMethod.call(hub, memberKey, makeProxyCallback(hub, memberValue));
                    }
                }
            }
        }
    }

    $.hubConnection.prototype.createHubProxies = function () {
        var proxies = {};
        this.starting(function () {
            // Register the hub proxies as subscribed
            // (instance, shouldSubscribe)
            registerHubProxies(proxies, true);

            this._registerSubscribedHubs();
        }).disconnected(function () {
            // Unsubscribe all hub proxies when we "disconnect".  This is to ensure that we do not re-add functional call backs.
            // (instance, shouldSubscribe)
            registerHubProxies(proxies, false);
        });

        proxies['admin'] = this.createHubProxy('admin'); 
        proxies['admin'].client = { };
        proxies['admin'].server = {
            changeResult: function (id, result) {
                return proxies['admin'].invoke.apply(proxies['admin'], $.merge(["ChangeResult"], $.makeArray(arguments)));
             },

            getGameList: function () {
                return proxies['admin'].invoke.apply(proxies['admin'], $.merge(["GetGameList"], $.makeArray(arguments)));
             },

            killMatch: function (id) {
                return proxies['admin'].invoke.apply(proxies['admin'], $.merge(["KillMatch"], $.makeArray(arguments)));
             },

            recalculateMatch: function (id) {
                return proxies['admin'].invoke.apply(proxies['admin'], $.merge(["RecalculateMatch"], $.makeArray(arguments)));
             },

            resultMatch: function (id, result) {
                return proxies['admin'].invoke.apply(proxies['admin'], $.merge(["ResultMatch"], $.makeArray(arguments)));
             }
        };

        proxies['chat'] = this.createHubProxy('chat'); 
        proxies['chat'].client = { };
        proxies['chat'].server = {
            memberListSnapshot: function () {
                return proxies['chat'].invoke.apply(proxies['chat'], $.merge(["MemberListSnapshot"], $.makeArray(arguments)));
             },

            sendMessage: function (channel, text) {
                return proxies['chat'].invoke.apply(proxies['chat'], $.merge(["SendMessage"], $.makeArray(arguments)));
             }
        };

        proxies['matches'] = this.createHubProxy('matches'); 
        proxies['matches'].client = { };
        proxies['matches'].server = {
            cancelChallenge: function () {
                return proxies['matches'].invoke.apply(proxies['matches'], $.merge(["CancelChallenge"], $.makeArray(arguments)));
             },

            challengeResponse: function (accept) {
                return proxies['matches'].invoke.apply(proxies['matches'], $.merge(["ChallengeResponse"], $.makeArray(arguments)));
             },

            createMatch: function (options) {
                return proxies['matches'].invoke.apply(proxies['matches'], $.merge(["CreateMatch"], $.makeArray(arguments)));
             },

            finalizeMatch: function () {
                return proxies['matches'].invoke.apply(proxies['matches'], $.merge(["FinalizeMatch"], $.makeArray(arguments)));
             },

            getAvailableGameList: function () {
                return proxies['matches'].invoke.apply(proxies['matches'], $.merge(["GetAvailableGameList"], $.makeArray(arguments)));
             },

            joinMatch: function (id, spec) {
                return proxies['matches'].invoke.apply(proxies['matches'], $.merge(["JoinMatch"], $.makeArray(arguments)));
             },

            kickPlayer: function (steamid) {
                return proxies['matches'].invoke.apply(proxies['matches'], $.merge(["KickPlayer"], $.makeArray(arguments)));
             },

            leaveMatch: function () {
                return proxies['matches'].invoke.apply(proxies['matches'], $.merge(["LeaveMatch"], $.makeArray(arguments)));
             },

            pickPlayer: function (steamid) {
                return proxies['matches'].invoke.apply(proxies['matches'], $.merge(["PickPlayer"], $.makeArray(arguments)));
             },

            startChallenge: function (target) {
                return proxies['matches'].invoke.apply(proxies['matches'], $.merge(["StartChallenge"], $.makeArray(arguments)));
             },

            startMatch: function () {
                return proxies['matches'].invoke.apply(proxies['matches'], $.merge(["StartMatch"], $.makeArray(arguments)));
             }
        };

        proxies['webLeagueHub'] = this.createHubProxy('webLeagueHub'); 
        proxies['webLeagueHub'].client = { };
        proxies['webLeagueHub'].server = {
        };

        return proxies;
    };

    signalR.hub = $.hubConnection("/signalr", { useDefaultPath: false });
    $.extend(signalR, signalR.hub.createHubProxies());

}(window.jQuery, window));
