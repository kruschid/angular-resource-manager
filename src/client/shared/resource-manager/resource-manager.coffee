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
    SAVING: 'SAVING'
    SAVED: 'SAVED'
    REMOVING: 'REMOVING'
    REMOVED: 'REMOVED'
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
  # @var {Resource} base
  # @memberOf Resource
  # @memberOf ResourceCollection
  ###
  
  ###*
  # is set when resource is beeing used in context of a relationship
  # @var {Resource} base
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
  # holds current promise object
  # @var {Promise} promise
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
      console.log @resource, @state, args, @
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
  # indicates wether client has received server response
  # @return {Boolean}
  ###
  isResolved: ->
    @state in [
      ResourceLoader.STATES.LOADED
      ResourceLoader.STATES.SAVED
      ResourceLoader.STATES.REMOVED
    ]
    
  ###*
  # sets base ressource and returns current instance
  # @return {Resource}
  ###
  setBase: (@base) ->
    return @
    
  ###*
  # returns new instance with same id but with reseted data and base
  # @return {Resource}
  ###
  orphan: ->
    @base = undefined
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
    @promise = @conf.$http(config)
    @promise.then (response) =>
      @setState(afterResponseMap[config.method], [response])
    @promise.catch (response) =>
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
  # maps ResourceCollection instances of subresources
  # @var {Object<String,ResourceCollection>} subs
  # @memberOf Resource
  ###
  
  ###*
  # initializes config  
  # @param {ResourceManagerConfiguation} conf
  # @param {String} resource Name of resource
  # @param {Number|String} id Id of resource
  # @param {Resource} [baseResourse] The base-resource when using resource in context of a relation
  ###
  constructor: (@conf, @resource, @id, @base) ->
    super()
    @data = {}
    @subs = {}
    @onLoaded (response) ->
      # clean data object
      @clean()
      # fill data object with response data
      angular.extend(@data, response.data)
    @onSaved (response) ->
      # clean data object
      @clean()
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
    if @base?
      [@base.getFullUrl(), @resource, @id].join('/').replace(/\/+$/, '')
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
    if not @subs[resourceName]
      @subs[resourceName] = new ResourceCollection(@conf, resourceName, @)  
    return @subs[resourceName]
 
  ###*
  # deletes all data an resets state
  # @param {Boolean} setState changes state to CLEANED if true 
  # @return {Resource}
  ###
  clean: (setState) ->
    delete @data[key] for key of @data
    @subs = []
    return @
  
  ###*
  # cleans data and id
  # @return {Resource}
  ###
  bare: ->
    @clean()
    delete @id
    delete @state
    return @   
  
  ###*
  # overwrites certain properties
  # @param {Object} properties
  # @return {Resource}
  ###
  patch: (properties) ->
    angular.extend(@data, properties)
    return @
    
  ###*
  # replaces properties or wohle resource incl id 
  # @param {Resource|Object} object
  # @return {Resource}
  ###
  set: (object) ->
    if object instanceof Resource
      @setResource(object)
    else
      @setProperties(object)
    
  
  ###*
  # overwrites/sets properties
  # @param {Object} properties
  # @return {Resource}
  ###
  setProperties: (properties) ->
    @clean()
    angular.extend(@data, properties)
    return @
  
  ###*
  # replaces data,id by the data,id of passed resource
  # @param {Resource} resource
  # @return {Resource}
  ###
  setResource: (resource) ->
    @id = resource.id
    @state = resource.state
    @setProperties(resource.data)
    return @
    
  
  ###*
  # checks if current ressource has related objects in a collection
  # @param {ResourceCollection} collection
  # @param {String} foreignKey 
  # @return {Boolean}
  ###
  hasRelative: (collection, foreignKey) ->
    for resource in collection.data
      if @id is resource.data[foreignKey]
        return true
    return false
    
  ###*
  # check if resource is in a collection 
  # @param {ResourceCollection} collection
  # @return {Boolean}
  ###
  isIn: (collection) ->
    for resource in collection.data
      if @id is resource.id
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
  # @param {Resource} base When this resource is beeing used in context of a relationship 
  ###
  constructor: (@conf, @resource, @base) ->
    # we let the base class handle the responses
    super()
    # handle reponse
    @data = []
    @onLoaded (response) ->
      # stop if response body is ot an array
      return if not Array.isArray(response.data)
      @clean()
      # wrap each resource inside a Resource instance
      for resource, i in response.data
        r = new Resource(@conf, @resource, resource.id, @base)
        r.data = resource
        r.state = ResourceLoader.STATES.LOADED
        @data[i] = r

  ###*
  # requests and returns one resource
  # @param {Number|String} id Request parameters for query string
  # @return {Resource} Description
  ###
  one: (id) ->
    new Resource(@conf, @resource, id, @base)

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
    if @base?
      [@base.getFullUrl(), @resource].join('/')
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
  # loads resouce only if no response available
  # @return {Resource}
  ###
  tget: (params) ->
    if !@isWaiting() && !@isResolved()
      @get(params)
    return @
 
  ###*
  # deletes all data an resets state
  # @param {Boolean} setState changes state to CLEANED if true 
  # @return {ResourceCollection}
  ###
  clean: (setState=true)  ->
    @data.splice(0, @data.length) # remove all objects from array
    return @
   
  ###*
  # returns one resource matches search criteria
  # @return {Resource}
  ###
  find: (s) ->
    r = @filter(s)
    if r.length
      r[0]
    else
      undefined
  
  ###*
  # returns resources matches search criteria
  # @return {Array<Resource>}
  ###
  filter: (s) ->
    @data.filter (resource) ->
      f = 0
      for key, value of s
        f++ if resource.data[key] is value
      return (f is Object.keys(s).length)   

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
  # @return {Function} Function that takes resourceName:String and base:Resource as arguments and returns ResourceManager instance
  ###
  $get: ($rootScope, $http) -> 
    conf =
      baseUrl: @baseUrl
      debug: @debug
      $http: $http
    (resource, base) -> 
      ResourceCollection.bind(undefined, conf, resource, base)