chai.should()

describe 'ResourceLoader', ->
  backend = resourceLoader = undefined
  # set up module
  beforeEach(module('kdResourceManager'))
  # setup dependencies
  beforeEach inject ($httpBackend, kdResourceManager) ->
    backend = $httpBackend
    resourceLoader = new (kdResourceManager())().one() # ResourceLoader is in Resource included since it is its baseclass 
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
    resourceLoader.isLoading().should.be.true
    resourceLoader.isLoaded().should.to.be.false
    backend.flush()
    resourceLoader.isLoading().should.to.be.false
    resourceLoader.isLoaded().should.be.true

  it 'should set SAVING & SAVED states correctly for POST requests', ->
    backend.expectPOST('/').respond -> [200, {id:1}]
    resourceLoader.makeRequest
      method: 'POST'
      url: '/'
    resourceLoader.isSaving().should.be.true
    resourceLoader.isSaved().should.be.false
    backend.flush()
    resourceLoader.isSaving().should.be.false
    resourceLoader.isSaved().should.be.true
    
  it 'should set SAVING & SAVED states correctly for PUT requests', ->
    backend.expectPUT('/').respond -> [200, {id:1}]
    resourceLoader.makeRequest
      method: 'PUT'
      url: '/'
    resourceLoader.isSaving().should.be.true
    resourceLoader.isSaved().should.be.false
    backend.flush()
    resourceLoader.isSaving().should.be.false
    resourceLoader.isSaved().should.be.true
    
  it 'should set REMOVING & REMOVED states correctly for DELETE requests', ->
    backend.expectDELETE('/').respond -> [200]
    resourceLoader.makeRequest
      method: 'DELETE'
      url: '/'
    resourceLoader.isRemoving().should.be.true
    resourceLoader.isRemoved().should.be.false
    backend.flush()
    resourceLoader.isRemoving().should.be.false
    resourceLoader.isRemoved().should.be.true
  
  it 'should call LOADING & LOADED callbacks correctly for GET requests', ->
    backend.expectGET('/').respond -> [200]
    loadingCb = sinon.spy()
    loadedCb = sinon.spy()
    resourceLoader.onLoading(loadingCb)
                  .onLoaded(loadedCb)
    loadingCb.called.should.be.false
    resourceLoader.makeRequest
      method: 'GET'
      url: '/'
    loadingCb.calledOnce.should.be.true
    loadedCb.called.should.be.false
    backend.flush()
    loadedCb.calledOnce.should.be.true

  it 'should call SAVING & SAVED callbacks correctly for POST requests', ->
    backend.expectPOST('/').respond -> [200, {id:1}]
    savingCb = sinon.spy()
    savedCb = sinon.spy()
    resourceLoader.onSaving(savingCb)
                  .onSaved(savedCb)
    savingCb.called.should.be.false
    resourceLoader.makeRequest
      method: 'POST'
      url: '/'
    savingCb.calledOnce.should.be.true
    savedCb.called.should.be.false
    backend.flush()
    savingCb.calledOnce.should.be.true
    savedCb.called.should.be.true
  
  it 'should call SAVING & SAVED callbacks for PUT requests', ->
    backend.expectPUT('/').respond -> [200, {id:1}]
    savingCb = sinon.spy()
    savedCb = sinon.spy()
    resourceLoader.onSaving(savingCb)
                  .onSaved(savedCb)
    savingCb.called.should.be.false
    resourceLoader.makeRequest
      method: 'PUT'
      url: '/'
    savingCb.called.should.be.true
    savedCb.called.should.be.false
    backend.flush()
    savedCb.called.should.be.true
    
  it 'should call REMOVING & REMOVED callbacks for DELETE requests', ->
    backend.expectDELETE('/').respond -> [200]
    removingCb = sinon.spy()
    removedCb = sinon.spy()
    resourceLoader.onRemoving(removingCb)
                  .onRemoved(removedCb)
    removingCb.called.should.be.false
    resourceLoader.makeRequest
      method: 'DELETE'
      url: '/'
    removingCb.called.should.be.true
    removedCb.called.should.be.false
    backend.flush()
    removedCb.called.should.be.true
    
  it 'should call REJECTED callbacks correctly', ->
    backend.expectGET('/').respond -> [404]
    rejectedCb = sinon.spy()
    resourceLoader.onRejected(rejectedCb).makeRequest
      method: 'GET'
      url: '/'
    rejectedCb.called.should.be.false
    backend.flush()
    rejectedCb.called.should.be.true

  it 'isWaiting method should be working for GET-requests', ->
    backend.expectGET('/').respond -> [200]
    resourceLoader.makeRequest
      method: 'GET'
      url: '/'
    resourceLoader.isWaiting().should.be.true
    backend.flush()
    resourceLoader.isWaiting().should.be.false
  
  it 'isWaiting method should be working for POST-requests', ->
    backend.expectPOST('/').respond -> [200, {id:1}]
    resourceLoader.makeRequest
      method: 'POST'
      url: '/'
    resourceLoader.isWaiting().should.be.true
    backend.flush()
    resourceLoader.isWaiting().should.be.false
    
  it 'isWaiting method should be working for PUT-requests', ->
    backend.expectPUT('/').respond -> [200, {id:1}]
    resourceLoader.makeRequest
      method: 'PUT'
      url: '/'
    resourceLoader.isWaiting().should.be.true
    backend.flush()
    resourceLoader.isWaiting().should.be.false
    
  it 'isWaiting method should be working for DELETE-requests', ->
    backend.expectDELETE('/').respond -> [200]
    resourceLoader.makeRequest
      method: 'DELETE'
      url: '/'
    resourceLoader.isWaiting().should.be.true
    backend.flush()
    resourceLoader.isWaiting().should.be.false

  it 'should store errors in same error object over several requests', ->
    backend.expectGET('/').respond -> 
      [400, {email:'required'}]
    resourceLoader.makeRequest
      method: 'GET'
      url: '/'
    backend.flush()
    errors = resourceLoader.errors
    errors.email.should.be.equal('required')
    backend.expectGET('/').respond -> 
      [400, {name:'required'}]
    resourceLoader.makeRequest
      method: 'GET'
      url: '/'
    should.not.exist(errors.email)
    backend.flush()
    errors.name.should.be.equal('required')

  it 'should provide a new promise object for each request'
  
  it 'isResolved() should indicate wether response was received'