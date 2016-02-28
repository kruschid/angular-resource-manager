# API
The Module `api` module generates angular services for the client server interaction in our application. It depends on the module `kdResurceManager` wich helps us to interact with the servers ReST-API.
 
    ###*
    # API Description
    # @namespace api
    ###
    api = angular.module 'api', [
      'kdResourceManager'
    ]

## Configuration
It is well known as a good practise to assign a version number to your API. Luckily `kdResourceManager` allows us to set a base url through the method `setBaseUrl` so each requested url contains the passed string `/api/v1` as a prefix. `setDebug` turns log messages on if the value `true` is passed to that method.

    ###*
    # Sets base-url
    # @memberOf api
    # @namespace setBaseUrl
    ###
    api.config (kdResourceManagerProvider) ->
      kdResourceManagerProvider.setBaseUrl('/api/v1')
      .setDebug(true)

## Services
We define now several services to have a comfortable method to interact with the the ReST-API. The services `Continent`, `Country` and `City` depend on the `kdResourceManager` service. For exaple throug passing the string `continents` to this service we are able to interact with the API-endpoint `/api/v1/continents`. In this case `kdResourceManger` returns a `ResourceManager` instance wich allows us to perform several requests to that endpoint. There `ResourceManager` provides `Resource` and `ResourceCollection` instances wich handle the servers responses.     

    ###*
    # Continents-API
    # @memberOf api
    # @namespace Continent
    # @return {ResourceManager} Instance of ResourceManager
    ###
    api.factory 'Continent', (kdResourceManager) ->
      kdResourceManager('continents')

    ###*
    # Country-API
    # @memberOf api
    # @namespace Country
    # @return {ResourceManager} Instance of ResourceManager
    ###
    api.factory 'Country', (kdResourceManager) ->
      kdResourceManager('countries')
  
    ###*
    # City-API
    # @memberOf api
    # @namespace City
    # @return {ResourceManager} Instance of ResourceManager
    ###  
    api.factory 'City', (kdResourceManager) ->
      kdResourceManager('cities')