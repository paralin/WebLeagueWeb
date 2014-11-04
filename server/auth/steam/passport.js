var passport = require('passport');
var SteamStrategy = require('passport-steam').Strategy;
var Steam = require('steam-webapi');
var request = require('request');

var steam;
exports.setup = function (User, config) {
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
          user.profile.name = profile.personaname;
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
            newUser.profile.rating = 1200;
            newUser.profile.vouched = false;
            newUser.authItems = ['chat', 'startGames', 'matches'];
            newUser.save(function(err){
              if(err)
                throw err;
              return done(null, newUser);
            });
          });
        }
      })
    });
  }));
};
