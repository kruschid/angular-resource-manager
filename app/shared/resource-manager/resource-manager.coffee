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
    CLEANED: 'CLEANED'
    LOADING: 'LOADING' 
    LOADED: 'LOADED'
    SAVING: 'SAVING'
    SAVED: 'SAVED'
    REMOVING: 'REMOVING'
    REMOVED: 'REMOVED'
    REJECTED: 'REJECTED'
  
  ###*
  # indicates wether resoure or colelction was already rendered in template
  # @var {Booelean} rendered
  # @memberOf Resource
  # @memberOf ResourceCollection
  ###
    
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
      CLEANED: []
      LOADING: []
      LOADED: []
      SAVING: []
      SAVED: []
      REMOVING: []
      REMOVED: []
      REJECTED: []
    # error handling
    @errors = {}
    @onLoading ->
      delete @errors[key] for key of @errors
    @onRejected (response) ->
      angular.extend(@errors, response.data)
 
  ###*
  # overrides state and
  # calls all callbacks bound to the new state
  # @param {ResourceLoader.STATES} state
  # @param {Array} arguments Callback arguments 
  # @return {ResourceLoader}
  ###
  setState: (@state, args) ->
    if @conf.debug
      console.log @resource, @, @state, args
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
  # binds callback to CLEANED state
  # @return {ResourceLoader}
  ###
  onCleaned: (cb) ->
    @bindCallback(ResourceLoader.STATES.CLEANED, cb)
  
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
  # binds callback to SAVING state
  # @param {Function} cb
  # @return {ResourceLoader}
  ###
  onSaving: (cb) ->
    @bindCallback(ResourceLoader.STATES.SAVING, cb)

  ###*
  # binds callback to SAVED state
  # @param {Function} cb
  # @return {ResourceLoader}
  ###
  onSaved: (cb) ->
    @bindCallback(ResourceLoader.STATES.SAVED, cb)

  ###*
  # binds callback to REMOVING state
  # @param {Function} cb
  # @return {ResourceLoader}
  ###
  onRemoving: (cb) ->
    @bindCallback(ResourceLoader.STATES.REMOVING, cb)

  ###*
  # binds callback to REMOVED state
  # @param {Function} cb
  # @return {ResourceLoader}
  ###
  onRemoved: (cb) ->
    @bindCallback(ResourceLoader.STATES.REMOVED, cb)

  ###*
  # binds callback to REJECTED state
  # @param {Function} cb
  # @return {ResourceLoader}
  ###
  onRejected: (cb) ->
    @bindCallback(ResourceLoader.STATES.REJECTED, cb)
  
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
  # indicates whether resource or collection is beeing loading
  # @return {Boolean}
  ###
  isSaving: ->
    @state is ResourceLoader.STATES.SAVING
  
  ###*
  # indicates whether resource or collection has been loaded
  # @return {Boolean}
  ###
  isSaved: ->
    @state is ResourceLoader.STATES.SAVED
    
  ###*
  # indicates whether resource or collection is beeing removing
  # @return {Boolean}
  ###
  isRemoving: ->
    @state is ResourceLoader.STATES.REMOVING
  
  ###*
  # indicates whether resource or collection has been removed
  # @return {Boolean}
  ###
  isRemoved: ->
    @state is ResourceLoader.STATES.REMOVED
  
  ###*
  # indicates wether resource or collection has been clened
  # @return {Boolean}
  ###
  isCleaned: ->
    @state is ResourceLoader.STATES.CLEANED
  
  ###*
  # indicates whether client is waiting for server response
  # @return {Boolean}
  ###
  isWaiting: ->
    @state in [
      ResourceLoader.STATES.LOADING
      ResourceLoader.STATES.SAVING
      ResourceLoader.STATES.REMOVING
    ]
    
  ###*
  # sets base ressource and returns current instance
  # @return {Resource}
  ###
  setBase: (@baseResource) ->
    return @
    
  ###*
  # Performs post request
  # @return {ResourceLoader}
  # @param {Object} config Object describing the request to be made
  # @param {String} config.method
  # @param {String} config.url
  # @param {Object} [config.params]
  # @param {Object} [config.data]
  ###
  makeRequest: (config) ->
    # maps methods to states
    beforeRequestMap =
      GET: ResourceLoader.STATES.LOADING
      POST: ResourceLoader.STATES.SAVING
      PUT: ResourceLoader.STATES.SAVING
      DELETE: ResourceLoader.STATES.REMOVING
    # on response
    afterResponseMap =
      GET: ResourceLoader.STATES.LOADED
      POST: ResourceLoader.STATES.SAVED
      PUT: ResourceLoader.STATES.SAVED
      DELETE: ResourceLoader.STATES.REMOVED
    # performs request
    @setState(beforeRequestMap[config.method], arguments)
    promise = @conf.$http(config)
    promise.then (response) =>
      @setState(afterResponseMap[config.method], [response])
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
    @subResources = {}
    @onLoaded (response) ->
      # clean data object
      @clean(false)
      # fill data object with response data
      angular.extend(@data, response.data)
    @onSaved (response) ->
      # clean data object
      @clean(false)
      @id = response.data.id
      # fill data object with response data
      angular.extend(@data, response.data)
      
  ###*
  # builds url for current resource (no relation included)
  # @return {String} url without trailing slashes
  ###
  getUrl: ->
    [@conf.baseUrl, @resource, @id].join('/').replace(/\/+$/, '')
  
  ###*
  # builds full url of current resource with relations
  # @return {String} url without trailing slashes
  ###
  getFullUrl: ->
    if @baseResource?
      [@baseResource.getFullUrl(), @resource, @id].join('/').replace(/\/+$/, '')
    else
      @getUrl()
      
  ###*
  # loads resource
  # @param {Object} params
  # @return {Resource}
  ###
  get: (params) ->
    @makeRequest
      method: 'GET' 
      url: @getFullUrl()
      params: params

  ###*
  # saves current resource
  # @return {Resource}
  ###
  save: ->
    if @id
      method = 'PUT'
    else
      method = 'POST'
    @makeRequest
      method: method 
      url: @getFullUrl()
      data: @data
      
  ###*
  # removes current resource
  # @return {Resource}
  ###
  remove: ->
    @makeRequest
      method: 'DELETE'
      url: @getFullUrl()

  ###*
  # returns resource manager for related resource
  # @return {ResourceManager} returns resource manager for related resource
  ###
  rel: (resourceName) ->
    if not @subResources[resourceName]
      @subResources[resourceName] = new ResourceCollection(@conf, resourceName, @)  
    return @subResources[resourceName]
 
  ###*
  # returns new instance with same id but with reseted  data and baseResource
  # @return {Resource}
  ###
  orphan: ->
    new Resource(@conf, @resource, @id)
  
  ###*
  # deletes all data an resets state
  # @param {Boolean} setState changes state to CLEANED if true 
  # @return {Resource}
  ###
  clean: (setState = true) ->
    delete @data[key] for key of @data
    if setState
      @setState(ResourceLoader.STATES.CLEANED)
    return @
  
  ###*
  # cleans data and id
  # @return {Resource}
  ###
  bare: ->
    @clean(false)
    delete @id
    return @   
  
  ###*
  # overwrites/sets properties
  # @param {Object} properties
  # @return {Resource}
  ###
  patch: (properties) ->
    angular.extend(@data, properties)
    return @
    
  ###*
  # overwrites/sets properties
  # @param {Object} properties
  # @return {Resource}
  ###
  set: (properties) ->
    @clean(false)
    angular.extend(@data, properties)
    return @
  
  ###*
  # checks if current ressource has related objects in a collection
  # @param {ResourceCollection} collection
  # @param {String} foreignKey 
  # @return {Boolean}
  ###
  hasRelative: (collection, foreignKey) ->
    for resource in collection.data
      if @id is resource[foreignKey]
        return true
    return false 
  
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
      # stop if response body is ot an array
      return if not Array.isArray(response.data)
      @clean(false)
      # wrap each resource inside a Resource instance
      for resource, i in response.data
        r = new Resource(@conf, @resource, resource.id, @baseResource)
        r.data = resource
        r.state = ResourceLoader.STATES.LOADED
        @data[i] = r

  ###*
  # requests and returns one resource
  # @param {Number|String} id Request parameters for query string
  # @return {Resource} Description
  ###
  one: (id) ->
    new Resource(@conf, @resource, id, @baseResource)

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
      [@baseResource.getFullUrl(), @resource].join('/')
    else
      @getUrl()
 
  ###*
  # loads resource
  # @param {Object} params Parameters added to search string
  # @return {Resource}
  ###
  get: (params) ->
    @makeRequest
      method: 'GET'
      url: @getFullUrl()
      params: params

  ###*
  # loads resouce if data is empty
  # @return {Resource}
  ###
  tget: (params) ->
    if !@rendered
      @rendered = true
      @get(params)
    return @
 
  ###*
  # deletes all data an resets state
  # @param {Boolean} setState changes state to CLEANED if true 
  # @return {ResourceCollection}
  ###
  clean: (setState=true)  ->
    @data.splice(0, @data.length) # remove all objects from array
    if setState
      @setState(ResourceLoader.STATES.CLEANED)
    return @
    
  ###*
  # returns new instance with same id but with reseted  data and baseResource
  # @return {ResourceCollection}
  ###
  asBase: ->
    new ResourceCollection(@conf, @resource)

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
      ResourceCollection.bind(undefined, conf, resource, baseResource)

# ###*
# #
# # @memberOf kdResourceManager
# # @namespace ResourceManager
# ###
# class ResourceManager
#   ###*
#   # contrcutor method
#   # @param {ResourceManagerConfiguation} conf
#   # @param {String} resource Name of resource
#   # @param {Resource} baseResource When this resource is beeing used in context of a relationship 
#   ###
#   constructor: (@conf, @resource, @baseResource) ->
    
#   ###*
#   # requests and returns collection of resources
#   # @return {ResourceCollection}
#   ###
#   many: ->
#     new ResourceCollection(@conf, @resource, @baseResource)
