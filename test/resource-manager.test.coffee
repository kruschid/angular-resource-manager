describe 'ResourceLoader', ->
  backend = resourceLoader = undefined
  # set up module
  beforeEach(module('kdResourceManager'))
  # setup dependencies
  beforeEach inject ($httpBackend, kdResourceManager) ->
    backend = $httpBackend
    resourceLoader = kdResourceManager().one() # ResourceLoader is in Resource included since it is its baseclass 
  # check for outstanding requests
  afterEach ->
    backend.verifyNoOutstandingExpectation()
    backend.verifyNoOutstandingRequest()
  
  it 'should make GET request with parameters', ->
    backend.expectGET('/test?foo=bar&marinheiro=so').respond -> 
      [200]
    resourceLoader.makeGetRequest '/test',
      foo: 'bar'
      marinheiro: 'so'
    backend.flush()
  
  it 'should set LOADING & LOADED states correctly', ->
    backend.expectGET('/').respond -> [200]
    resourceLoader.makeGetRequest('/')
    expect(resourceLoader.isLoading()).toBe(true)
    expect(resourceLoader.isLoaded()).toBe(false)
    backend.flush()
    expect(resourceLoader.isLoading()).toBe(false)
    expect(resourceLoader.isLoaded()).toBe(true)
  
  it 'should call LOADING & LOADED callbacks correctly', ->
    backend.expectGET('/').respond -> [200]
    loadingCb = jasmine.createSpy('loadingCb')
    loadedCb = jasmine.createSpy('loadedCb')
    resourceLoader.onLoading(loadingCb)
                  .onLoaded(loadedCb)
    expect(loadingCb).not.toHaveBeenCalled()
    resourceLoader.makeGetRequest('/')
    expect(loadingCb).toHaveBeenCalled()
    expect(loadedCb).not.toHaveBeenCalled()
    backend.flush()
    expect(loadedCb).toHaveBeenCalled()
  
  it 'should provide isWaiting method', ->
    backend.expectGET('/').respond -> [200]
    resourceLoader.makeGetRequest('/')
    expect(resourceLoader.isWaiting()).toBe(true)
    backend.flush()
    expect(resourceLoader.isWaiting()).toBe(false)
  
  it 'should call REJECTED callbacks correctly', ->
    backend.expectGET('/').respond -> [404]
    rejectedCb = jasmine.createSpy('rejectedCb')
    resourceLoader.onRejected(rejectedCb).makeGetRequest('/')
    expect(rejectedCb).not.toHaveBeenCalled()
    backend.flush()
    expect(rejectedCb).toHaveBeenCalled()

  it 'should store errors in error object over several requests', ->
    backend.expectGET('/').respond -> 
      [400, {email:'required'}]
    resourceLoader.makeGetRequest('/')
    backend.flush()
    errors = resourceLoader.errors
    expect(errors.email).toEqual('required')
    backend.expectGET('/').respond -> 
      [400, {name:'required'}]
    resourceLoader.makeGetRequest('/')
    expect(errors.email).toBeUndefined()
    backend.flush()
    expect(errors.name).toEqual('required')

describe 'Resource', ->
  backend = User = undefined
  # set up module
  beforeEach(module('kdResourceManager'))
  # setup dependencies
  beforeEach inject ($httpBackend, kdResourceManager) ->
    backend = $httpBackend
    User = kdResourceManager('users')
  
  afterEach ->
    backend.verifyNoOutstandingExpectation()
    backend.verifyNoOutstandingRequest()
  
  it 'should generate GET-url with base-url', ->
    user = User.one(1)
    user.conf.baseUrl = '/api/v1'
    url = user.getUrl()
    expect(url).toEqual('/api/v1/users/1')
  
  it 'should generate GET-url in context of a relationship', ->
    group = User.one(1).rel('groups').one(3)
    url = group.getFullUrl()
    expect(url).toEqual('/users/1/groups/3')
  
  it 'should fetch single resource', ->
    backend.expectGET('/users/1').respond -> [200]
    user = User.one(1).get()
    backend.flush()
  
  it 'should fetch one related resource', ->
    backend.expectGET('/users/5/groups/1').respond -> [200]
    usersGroups = User.one(5).rel('groups').one(1).get()
    backend.flush()
  
  it 'should be able to remove relations from context', ->
    backend.expectGET('/groups/1').respond -> [200]
    usersGroups = User.one(5).rel('groups').one(1).asBase().get()
    backend.flush()
  
  it 'should store resources in same object over several requests', ->
    backend.expectGET('/users/1').respond -> [200, {id:1}]
    user = User.one(1).get()
    data = user.data
    backend.flush()
    expect(data.id).toEqual(1)
    data.name = 'Hans'
    backend.expectGET('/users/1').respond -> [200, {id:1}]
    user.get()
    expect(data.name).toEqual('Hans')
    backend.flush()
    expect(data.name).toBeUndefined()
    expect(data.id).toEqual(1)

describe 'ResourceCollection', ->
  backend = User = undefined
  # set up module
  beforeEach(module('kdResourceManager'))
  # setup dependencies
  beforeEach inject ($httpBackend, kdResourceManager) ->
    backend = $httpBackend
    User = kdResourceManager('users')
 
  it 'should fetch many resources', ->
    backend.expectGET('/users').respond -> [200, [{id:1},{id:2},{id:3}]]
    user = User.many().get()
    backend.flush()
    expect(user.data.length).toEqual(3)
    
  it 'should fetch list of related resources', ->
    backend.expectGET('/users/1/users-groups').respond -> [200, [{id:1},{id:2},{id:3}]]
    user = User.one(1).rel('users-groups').many().get()
    backend.flush()
    expect(user.data.length).toEqual(3)
  
  it 'should be able to remove relations from context', ->
    backend.expectGET('/users-groups').respond -> [200, []]
    user = User.one(1).rel('users-groups').many().asBase().get()
    backend.flush()

  it 'should be able to handle non array responses', ->
    backend.expectGET('/users').respond -> [200, undefined]
    user = User.many().get()
    backend.flush()
    
  it 'should store resources in same object over several requests', ->
    backend.expectGET('/users').respond -> [200, [1,2,3]]
    users = User.many().get()
    data = users.data
    backend.flush()
    expect(data.length).toBe(3)
    data.push(4)
    data.push(5)
    backend.expectGET('/users').respond -> [200, [1,2,3,4]]
    users.get()
    expect(data.length).toBe(5)
    backend.flush()
    expect(data.length).toBe(4)