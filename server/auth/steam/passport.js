var passport = require('passport');
var SteamStrategy = require('passport-steam').Strategy;
var Steam = require('steam-webapi');
var request = require('request');
var chance = new require('chance')();

var steam;
exports.setup = function (User, Vouch, config) {
  Steam.key = process.env.STEAM_API;
  Steam.ready(function(err){
    console.log("Steam web api ready.");
    steam = new Steam();
  });

  passport.serializeUser(function(user, done){
    done(null, user._id);
  });

  passport.deserializeUser(function(id, done){
    User.findById(id, function(err, user){
      done(err, user);
    });
  });

  passport.use(new SteamStrategy({
    returnURL: process.env.DOMAIN+'/auth/steam/return',
    realm: process.env.DOMAIN+'/',
    apiKey: process.env.STEAM_API,
    stateless: true
  },
  function(identifier, profile, done){
    var steamid = identifier.split('/');
    steamid = steamid[steamid.length-1];
    steam.getPlayerSummaries({steamids: steamid}, function(err, data){
      if(err)
        return done(err);
      profile = data.players[0];
      User.findOne({'steam.steamid': profile.steamid}, function(err, user){
        if(err)
          return done(err);
        if(user){
          user.steam = profile;
          if(user.vouch && user.vouch.name && user.vouch.name.length){
            user.profile.name = user.vouch.name;
          }else{
            user.profile.name = profile.personaname;
          }
          if(user.profile.wins == null)
            user.profile.wins = 0;
          if(user.profile.losses == null)
            user.profile.losses = 0;
          if(user.profile.abandons == null)
            user.profile.abandons = 0;
          user.tsonetimeid = null;
          user.save(function(error){
            if(error)
              throw error;
            return done(null, user);
          });
        }else{
          require('crypto').randomBytes(12, function(ex, buf){
            var newUser = new User();
            newUser._id = buf.toString('hex');
            newUser.steam = profile;
            newUser.profile.name = profile.personaname;
            newUser.authItems = ['chat', 'startGames', 'matches'];
            newUser.leagues = []
            newUser.vouch = null;
            newUser.tsonetimeid = null;

            //Find if they have a active vouch
            Vouch.findOne({"_id": profile.steamid}, function(err, vou){
              if(err)
                throw err;
              if (vou){
                delete vou["__v"];
                newUser.vouch = vou;
                if(newUser.vouch && newUser.vouch.name && newUser.vouch.name.length)
                  newUser.profile.name = newUser.vouch.name;
                Vouch.remove({_id: vou._id}, function(err, res){
                  if(err)
                    throw err;
                });
              }else if(process.env.AUTOVOUCH)
              {
                newUser.vouch = {
                  _id: newUser.steam.steamid,
                  name: newUser.steam.personaname,
                  teamname: null,
                  teamavatar: null,
                  avatar: null
                };
              }
              newUser.save(function(err){
                if(err)
                  throw err;
                return done(null, newUser);
              });
            });
          });
        }
      })
    });
  }));
};
