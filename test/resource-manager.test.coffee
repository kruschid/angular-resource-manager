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
    resourceLoader.makeRequest 
      method: 'GET'
      url: '/test'
      params:
        foo: 'bar'
        marinheiro: 'so'
    backend.flush()
  
  it 'should set LOADING & LOADED states correctly for GET requests', ->
    backend.expectGET('/').respond -> [200]
    resourceLoader.makeRequest
      method: 'GET'
      url: '/'
    expect(resourceLoader.isLoading()).toBe(true)
    expect(resourceLoader.isLoaded()).toBe(false)
    backend.flush()
    expect(resourceLoader.isLoading()).toBe(false)
    expect(resourceLoader.isLoaded()).toBe(true)

  it 'should set SAVING & SAVED states correctly for POST requests', ->
    backend.expectPOST('/').respond -> [200, {id:1}]
    resourceLoader.makeRequest
      method: 'POST'
      url: '/'
    expect(resourceLoader.isSaving()).toBe(true)
    expect(resourceLoader.isSaved()).toBe(false)
    backend.flush()
    expect(resourceLoader.isSaving()).toBe(false)
    expect(resourceLoader.isSaved()).toBe(true)
    
  it 'should set SAVING & SAVED states correctly for PUT requests', ->
    backend.expectPUT('/').respond -> [200, {id:1}]
    resourceLoader.makeRequest
      method: 'PUT'
      url: '/'
    expect(resourceLoader.isSaving()).toBe(true)
    expect(resourceLoader.isSaved()).toBe(false)
    backend.flush()
    expect(resourceLoader.isSaving()).toBe(false)
    expect(resourceLoader.isSaved()).toBe(true)
    
  it 'should set REMOVING & REMOVED states correctly for DELETE requests', ->
    backend.expectDELETE('/').respond -> [200]
    resourceLoader.makeRequest
      method: 'DELETE'
      url: '/'
    expect(resourceLoader.isRemoving()).toBe(true)
    expect(resourceLoader.isRemoved()).toBe(false)
    backend.flush()
    expect(resourceLoader.isRemoving()).toBe(false)
    expect(resourceLoader.isRemoved()).toBe(true)
  
  it 'should call LOADING & LOADED callbacks correctly for GET requests', ->
    backend.expectGET('/').respond -> [200]
    loadingCb = jasmine.createSpy('loadingCb')
    loadedCb = jasmine.createSpy('loadedCb')
    resourceLoader.onLoading(loadingCb)
                  .onLoaded(loadedCb)
    expect(loadingCb).not.toHaveBeenCalled()
    resourceLoader.makeRequest
      method: 'GET'
      url: '/'
    expect(loadingCb).toHaveBeenCalled()
    expect(loadedCb).not.toHaveBeenCalled()
    backend.flush()
    expect(loadedCb).toHaveBeenCalled()

  it 'should call SAVING & SAVED callbacks correctly for POST requests', ->
    backend.expectPOST('/').respond -> [200, {id:1}]
    savingCb = jasmine.createSpy('savingCb')
    savedCb = jasmine.createSpy('savedCb')
    resourceLoader.onSaving(savingCb)
                  .onSaved(savedCb)
    expect(savingCb).not.toHaveBeenCalled()
    resourceLoader.makeRequest
      method: 'POST'
      url: '/'
    expect(savingCb).toHaveBeenCalled()
    expect(savedCb).not.toHaveBeenCalled()
    backend.flush()
    expect(savedCb).toHaveBeenCalled()
  
  it 'should call SAVING & SAVED callbacks for PUT requests', ->
    backend.expectPUT('/').respond -> [200, {id:1}]
    savingCb = jasmine.createSpy('savingCb')
    savedCb = jasmine.createSpy('savedCb')
    resourceLoader.onSaving(savingCb)
                  .onSaved(savedCb)
    expect(savingCb).not.toHaveBeenCalled()
    resourceLoader.makeRequest
      method: 'PUT'
      url: '/'
    expect(savingCb).toHaveBeenCalled()
    expect(savedCb).not.toHaveBeenCalled()
    backend.flush()
    expect(savedCb).toHaveBeenCalled()
    
  it 'should call REMOVING & REMOVED callbacks for DELETE requests', ->
    backend.expectDELETE('/').respond -> [200]
    removingCb = jasmine.createSpy('removingCb')
    removedCb = jasmine.createSpy('removedCb')
    resourceLoader.onRemoving(removingCb)
                  .onRemoved(removedCb)
    expect(removingCb).not.toHaveBeenCalled()
    resourceLoader.makeRequest
      method: 'DELETE'
      url: '/'
    expect(removingCb).toHaveBeenCalled()
    expect(removedCb).not.toHaveBeenCalled()
    backend.flush()
    expect(removedCb).toHaveBeenCalled()
    
  it 'should call REJECTED callbacks correctly', ->
    backend.expectGET('/').respond -> [404]
    rejectedCb = jasmine.createSpy('rejectedCb')
    resourceLoader.onRejected(rejectedCb).makeRequest
      method: 'GET'
      url: '/'
    expect(rejectedCb).not.toHaveBeenCalled()
    backend.flush()
    expect(rejectedCb).toHaveBeenCalled()

  it 'isWaiting method should be working for GET-requests', ->
    backend.expectGET('/').respond -> [200]
    resourceLoader.makeRequest
      method: 'GET'
      url: '/'
    expect(resourceLoader.isWaiting()).toBe(true)
    backend.flush()
    expect(resourceLoader.isWaiting()).toBe(false)
  
  it 'isWaiting method should be working for POST-requests', ->
    backend.expectPOST('/').respond -> [200, {id:1}]
    resourceLoader.makeRequest
      method: 'POST'
      url: '/'
    expect(resourceLoader.isWaiting()).toBe(true)
    backend.flush()
    expect(resourceLoader.isWaiting()).toBe(false)
    
  it 'isWaiting method should be working for PUT-requests', ->
    backend.expectPUT('/').respond -> [200, {id:1}]
    resourceLoader.makeRequest
      method: 'PUT'
      url: '/'
    expect(resourceLoader.isWaiting()).toBe(true)
    backend.flush()
    expect(resourceLoader.isWaiting()).toBe(false)
    
  it 'isWaiting method should be working for DELETE-requests', ->
    backend.expectDELETE('/').respond -> [200]
    resourceLoader.makeRequest
      method: 'DELETE'
      url: '/'
    expect(resourceLoader.isWaiting()).toBe(true)
    backend.flush()
    expect(resourceLoader.isWaiting()).toBe(false)

  it 'should store errors in same error object over several requests', ->
    backend.expectGET('/').respond -> 
      [400, {email:'required'}]
    resourceLoader.makeRequest
      method: 'GET'
      url: '/'
    backend.flush()
    errors = resourceLoader.errors
    expect(errors.email).toEqual('required')
    backend.expectGET('/').respond -> 
      [400, {name:'required'}]
    resourceLoader.makeRequest
      method: 'GET'
      url: '/'
    expect(errors.email).toBeUndefined()
    backend.flush()
    expect(errors.name).toEqual('required')

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
    user = User.get()
    backend.flush()
    expect(user.data.length).toEqual(3)
    
  it 'should fetch list of related resources', ->
    backend.expectGET('/users/1/users-groups').respond -> [200, [{id:1},{id:2},{id:3}]]
    user = User.one(1).rel('users-groups').get()
    backend.flush()
    expect(user.data.length).toEqual(3)
  
  it 'should be able to remove relations from context', ->
    backend.expectGET('/users-groups').respond -> [200, []]
    user = User.one(1).rel('users-groups').asBase().get()
    backend.flush()

  it 'should be able to handle non array responses', ->
    backend.expectGET('/users').respond -> [200, undefined]
    user = User.get()
    backend.flush()
    
  it 'should store resources in same object over several requests', ->
    backend.expectGET('/users').respond -> [200, [1,2,3]]
    users = User.get()
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
  
  it 'should generate url with base-url', ->
    user = User.one(1)
    user.conf.baseUrl = '/api/v1'
    url = user.getUrl()
    expect(url).toEqual('/api/v1/users/1')
  
  it 'should generate url in context of a relationship', ->
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
  
  it 'should remove relations from context', ->
    backend.expectGET('/groups/1').respond -> [200]
    usersGroups = User.one(5).rel('groups').one(1).asBase().get()
    backend.flush()
  
  it 'should store data in same object over several requests', ->
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
  
  it 'should create a new resource', ->
    backend.expectPOST('/users', {name:'Chiquinho'}).respond ->
      [200, {id:1, name:'Chiquinho'}]
    user = User.one()
    user.data.name = 'Chiquinho'
    user.save()
    backend.flush()
    expect(user.id).toEqual(1)
    expect(user.data.id).toEqual(1)
    
  it 'should update a resource', ->
    backend.expectPUT('/users/1', {name:'Peixinho'}).respond ->
      [200, {id:1, name:'Peixinho'}]
    user = User.one(1)
    user.data.name = 'Peixinho'
    user.save()
    backend.flush()
    expect(user.data.name).toEqual('Peixinho')
    
  it 'should delete a resource', ->
    backend.expectDELETE('/users/1').respond -> [200]
    user = User.one(1)
    user.remove()
    backend.flush()
  
  it 'should be able to clean its data container'
  it 'should allow to set a new base resource'
  it 'should allow to set resource as base resource'
  it 'should create a new instance when using asBase()'