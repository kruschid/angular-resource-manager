/* global __dirname */
// app.js
var feathers = require('feathers');
var memory = require('feathers-memory');
var bodyParser = require('body-parser');
var conf = require('./conf/gulp.json');
var fixtures = require('./conf/fixtures.js');

// A Feathers app is the same as an Express app
var app = feathers();

app.use(feathers.static(conf.views.dest));
// Add REST API support
app.configure(feathers.rest());
// Configure Socket.io real-time APIs
app.configure(feathers.socketio());
// Parse HTTP JSON bodies
app.use(bodyParser.json());

// services
var continents = memory({store:fixtures.continents});
var countries =  memory({store:fixtures.countries});
var cities = memory({store:fixtures.cities});

// api
app.use('/api/v1/continents', continents);
app.use('/api/v1/countries', countries);
app.use('/api/v1/countries/:countryId/continent', {
  find: function(params, callback){
    countries.get(params.countryId).then(function(country){
      continents.find({id: country.continentId}).then(function(continents){
        callback(null, continents)
      });
    });
  } // find
}); // single resource; no continentId in url
app.use('/api/v1/countries/:countryId/cities',{
  find: function(params, callback){
    cities.find({countryId: params.countryId}).then(function(cities){
      callback(null, cities);
    });
  }
}); // many resources
app.use('/api/v1/cities', cities);
// Start the server
app.listen(3000);