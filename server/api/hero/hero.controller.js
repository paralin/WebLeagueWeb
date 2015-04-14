'use strict';

var Hero = require('./hero.model');
var request = require('request');
var Humanize = require('humanize-plus');

exports.show = function(req, res){
  Hero.findOne({_id: parseInt(req.params.id)}, function(err, hero)
  {
    if(err)
    {
      console.log("error looking up hero "+req.params.id+" "+err);
    }else if(hero)
    {
      res.json(hero.toObject());
    }else
    {
      res.send("not found", 404);
    }
  });
};

exports.fetchHeros = function()
{
  request("https://api.steampowered.com/IEconDOTA2_570/GetHeroes/v0001/?key="+process.env.STEAM_API, function(error, response, body)
  {
    if(!error && response.statusCode == 200)
    {
      var data = JSON.parse(body);
      if(data.result && data.result.heroes && data.result.heroes.length > 10)
      {
        Hero.remove({}, function(err){
          if(err)
          {
            console.log("error removing hero database, "+err);
            return;
          }
          data.result.heroes.forEach(function(hero){
            hero["fullName"] = Humanize.titleCase(hero.name.replace("npc_dota_hero_", "").replace("_", " "));
            var tHero = new Hero({_id: hero.id, name: hero.name, fullName: hero.fullName});
            tHero.save(function(err)
            {
              if(err)
              {
                console.log("error updating hero "+hero.id+", "+err);
              }
            });
          });
          console.log("updated "+data.result.heroes.length+" heros' information");
        });
      }
    }
  });
};
