###*
# Angular-Resource-Manager
# @namespace kdResourceManager
###
kdResourceManager = angular.module 'kdResourceManager', []

###*
# Keeps state and promise of a Resource or ResourceCollection instance
# @memberOf kdResourceManager
# @namespace ResourceLoader
###    
class ResourceLoader
  ###*
  # enumerates available states
  # @var {Object} STATES
  # @static
  # @memberOf ResourceLoader
  ###
  @STATES:
    LOADING: 'LOADING' 
    LOADED: 'LOADED'
    REJECTED: 'REJECTED'
    
  ###*
  # configuration object
  # @var {ResourceManagerConfiguation} conf 
  # @memberOf Resource
  # @memberOf ResourceCollection
  ###

  ###*
  # Name of resource
  # @var {String} resource
  # @memberOf Resource
  # @memberOf ResourceCollection
  ###
  
  ###*
  # is set when resource is beeing used in context of a relationship
  # @var {Resource} baseResource
  # @memberOf Resource
  # @memberOf ResourceCollection
  ###
  
  ###*
  # respresents current state
  # @var {String} state
  # @memberOf Resource
  # @memberOf ResourceCollection
  ###
 
  ###*
  # keeps arrays of callback functions
  # each array is bound to state
  # the callbacks will be called according to their index
  # @var {Object} callbacks
  # @memberOf Resource
  # @memberOf ResourceCollection
  ###
  
  ###*
  # Holds response data
  # @var {Object|Array} data
  # @memberOf Resource
  # @memberOf ResourceCollection
  ###
  
  ###*
  # contains errors
  # @var {Object} errors
  # @memberOf Resource
  # @memberOf ResourceCollection
  ###
  
  ###*
  # creates several callbacks to copy response-data into current instance
  ###
  constructor: ->
    @callbacks =
      LOADING: []
      LOADED: []
      REJECTED: []
    # error handling
    @errors = {}
    @onLoading ->
      delete @errors[key] for key of @errors
    @onRejected (response) ->
      angular.extend(@errors, response.data)

  ###*
  # removes related resource from current context
  # @return {Resource}
  ###
  asBase: ->
    @baseResource = undefined
    return @
 
  ###*
  # overrides state and
  # calls all callbacks bound to the new state
  # @param {ResourceLoader.STATES} state
  # @param {Array} arguments Callback arguments 
  # @return {ResourceLoader}
  ###
  setState: (@state, args) ->
    if @conf.debug
      console.log @state, args
    for cb in @callbacks[@state]
      cb.apply(@, args) 
    return @
  
  ###*
  # bind callback to a state
  # @param {Function} cb
  # @return {ResourceLoader}
  ###
  bindCallback: (state, cb) ->
    @callbacks[state].push(cb)
    return @
  
  ###*
  # binds callback to LOADING state
  # @param {Function} cb
  # @return {ResourceLoader}
  ###
  onLoading: (cb) ->
    @bindCallback(ResourceLoader.STATES.LOADING, cb)

  ###*
  # binds callback to LOADED state
  # @param {Function} cb
  # @return {ResourceLoader}
  ###
  onLoaded: (cb) ->
    @bindCallback(ResourceLoader.STATES.LOADED, cb)

  ###*
  # binds callback to REJECTED state
  # @param {Function} cb
  # @return {ResourceLoader}
  ###
  onRejected: (cb) ->
    @bindCallback(ResourceLoader.STATES.REJECTED, cb)

  ###*
  # indicates whether client is waiting for server response
  # @return {Boolean}
  ###
  isWaiting: ->
    @state is ResourceLoader.STATES.LOADING
  
  ###*
  # indicates whether resource or collection is beeing loading
  # @return {Boolean}
  ###
  isLoading: ->
    @state is ResourceLoader.STATES.LOADING
  
  ###*
  # indicates whether resource or collection has been loaded
  # @return {Boolean}
  ###
  isLoaded: ->
    @state is ResourceLoader.STATES.LOADED
  
  ###*
  # Performs get request 
  # @return {ResourceLoader}
  # @param {String} url
  # @param {Object} params
  ###  
  makeGetRequest: (url, params) ->
    # notify that we are about to start request
    @setState(ResourceLoader.STATES.LOADING, [url, params])
    promise = @conf.$http
      method: 'GET'
      url: url
      params: params
    promise.then (response) =>
      @setState(ResourceLoader.STATES.LOADED, [response])
    promise.catch (response) =>
      @setState(ResourceLoader.STATES.REJECTED, [response])
    return @ 

###*
# Handles single resource
# @memberOf kdResourceManager
# @namespace Resource
# @extends ResourceLoader
###
class Resource extends ResourceLoader
  ###*
  # Id of current resource
  # @var {String|Number} id
  # @memberOf Resource
  ###
  
  ###*
  # initializes config  
  # @param {ResourceManagerConfiguation} conf
  # @param {String} resource Name of resource
  # @param {Number|String} id Id of resource
  # @param {Resource} [baseResourse] The base-resource when using resource in context of a relation
  ###
  constructor: (@conf, @resource, @id, @baseResource) ->
    super()
    # handle response
    @data = {}
    @onLoaded (response) ->
      delete @data[key] for key of @data
      angular.extend(@data, response.data)
      # # angular.extend breaks the reference
      # @data[key] = response.data[key] for key of response.data
      
  ###*
  # builds url for current resource (no relation included)
  # @return {String}
  ###
  getUrl: ->
    [@conf.baseUrl, @resource, @id].join('/')
  
  ###*
  # builds full url of current resource with relations
  # @return {String}
  ###
  getFullUrl: ->
    if @baseResource?
      [@baseResource.getUrl(), @resource, @id].join('/')
    else
      @getUrl()
      
  ###*
  # loads resource
  # @return {Resource}
  ###
  get: (params) ->
    @makeGetRequest(@getFullUrl(), params)

  ###*
  # returns resource manager for related resource
  # @return {ResourceManager} returns resource manager for related resource
  ###
  rel: (subResource) ->
    new ResourceManager(@conf, subResource, @)
    
###*
# Handles resource-collections
# @memberOf kdResourceManager
# @namespace ResourceCollection
###
class ResourceCollection extends ResourceLoader  
  ###*
  # Constructor-Description
  # @param {ResourceManagerConfiguation} conf
  # @param {String} resource Name of resource
  # @param {Resource} baseResource When this resource is beeing used in context of a relationship 
  ###
  constructor: (@conf, @resource, @baseResource) ->
    # we let the base class handle the responses
    super()
    # handle reponse
    @data = []
    @onLoaded (response) ->
      # stop if response body is empty
      return if not response.data?.length
      @data.splice(0, @data.length) # remove all objects from array
      # wrap each resource inside a Resource instance
      for resource, i in response.data
        r = new Resource(@conf, @resource, resource.id, @baseResource)
        r.data = resource
        r.state = ResourceLoader.STATES.LOADED
        @data[i] = r
        
  ###*
  # builds url for current resource
  # @return {String}
  ###
  getUrl: ->
    [@conf.baseUrl, @resource].join('/')
  
  ###*
  # builds full url of current resource with relation in mind
  # @return {String}
  ###
  getFullUrl: ->
    if @baseResource?
      [@baseResource.getUrl(), @resource].join('/')
    else
      @getUrl()
 
  ###*
  # loads resource
  # @param {Object} params Parameters added to search string
  # @return {Resource}
  ###
  get: (params) ->
    @makeGetRequest(@getFullUrl(), params)

###*
#
# @memberOf kdResourceManager
# @namespace ResourceManager
###
class ResourceManager
  ###*
  # contrcutor method
  # @param {ResourceManagerConfiguation} conf
  # @param {String} resource Name of resource
  # @param {Resource} baseResource When this resource is beeing used in context of a relationship 
  ###
  constructor: (@conf, @resource, @baseResource) ->
    
  ###*
  # requests and returns collection of resources
  # @return {ResourceCollection}
  ###
  many: ->
    new ResourceCollection(@conf, @resource, @baseResource)
  
  ###*
  # requests and returns one resource
  # @param {Number|String} id Request parameters for query string
  # @return {Resource} Description
  ###
  one: (id) ->
    new Resource(@conf, @resource, id, @baseResource)

###*
# Provides init function for ResourceManager
# @memberOf kdResourceManager
# @namespace kdResourceManagerProvider
###
kdResourceManager.provider 'kdResourceManager', class ResourceManagerProvider
  ###*
  # @var {String} baseUrl
  ###
  baseUrl: undefined
  
  ###*
  # sets base url for all instances beeing provided
  # @param {String} baseUrl 
  # @return {ResourceManagerProvider}
  ###
  setBaseUrl: (@baseUrl) -> @
  
  ###*
  # turns debugmode on/of
  # @param {Boolean} debug 
  # @return {ResourceManagerProvider}
  ###
  setDebug: (@debug) -> @
  
  # returns a object wich creates new instances of ResourceController
  ###*
  # getter for ResourceManager instance
  # @param {$http} $http
  # @return {Function} Function that takes resourceName:String and baseResource:Resource as arguments and returns ResourceManager instance
  ###
  $get: ($rootScope, $http) -> 
    conf =
      baseUrl: @baseUrl
      debug: @debug
      $http: $http
    (resource, baseResource) -> 
      new ResourceManager(conf, resource, baseResource)