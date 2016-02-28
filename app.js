/* global __dirname */
// app.js
var feathers = require('feathers');
var memory = require('feathers-memory');
var bodyParser = require('body-parser');
var npmConf = require('./package.json');
var fixtures = require('./test/fixtures.js');

// A Feathers app is the same as an Express app
var app = feathers();

app.use(feathers.static(__dirname + '/' + npmConf.gcsj.dest.public));
// Add REST API support
app.configure(feathers.rest());
// Configure Socket.io real-time APIs
app.configure(feathers.socketio());
// Parse HTTP JSON bodies
app.use(bodyParser.json());
// Register the todo service
app.use('/api/v1/continents', memory({store:fixtures.continents}));
app.use('/api/v1/countries', memory({store:fixtures.countries}));
app.use('/api/v1/cities', memory({store:fixtures.cities}));
// Start the server
app.listen(3000);