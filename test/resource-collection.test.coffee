chai.should()

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
    user = new User().get()
    backend.flush()
    user.data.length.should.be.equal(3)
    
  it 'should fetch list of related resources', ->
    backend.expectGET('/users/1/users-groups').respond -> [200, [{id:1},{id:2},{id:3}]]
    user = new User().one(1).rel('users-groups').get()
    backend.flush()
    user.data.length.should.be.equal(3)
  
  it 'should be able to remove relations from context', ->
    backend.expectGET('/users-groups').respond -> [200, []]
    user = new User().one(1).rel('users-groups').asBase().get()
    backend.flush()

  it 'should be able to handle non array responses', ->
    backend.expectGET('/users').respond -> [200, undefined]
    user = new User().get()
    backend.flush()
    
  it 'should store resources in same object over several requests', ->
    backend.expectGET('/users').respond -> [200, [1,2,3]]
    users = new User().get()
    data = users.data
    backend.flush()
    data.length.should.be.equal(3)
    data.push(4)
    data.push(5)
    backend.expectGET('/users').respond -> [200, [1,2,3,4]]
    users.get()
    data.length.should.be.equal(5)
    backend.flush()
    data.length.should.be.equal(4)

  it 'tget() should only called once per request'
  it 'rel() should return same objects for same subresources'
 