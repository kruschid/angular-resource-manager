chai.should()

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
    user = new User().one(1)
    user.conf.baseUrl = '/api/v1'
    url = user.getUrl()
    url.should.be.equal('/api/v1/users/1')
  
  it 'should generate url in context of a relationship', ->
    group = new User().one(1).rel('groups').one(3)
    url = group.getFullUrl()
    url.should.be.equal('/users/1/groups/3')
  
  it 'should fetch single resource', ->
    backend.expectGET('/users/1').respond -> [200]
    user = new User().one(1).get()
    backend.flush()
  
  it 'should fetch one related resource', ->
    backend.expectGET('/users/5/groups/1').respond -> [200]
    usersGroups = new User().one(5).rel('groups').one(1).get()
    backend.flush()
  
  it 'orphan() should create a new instance without a baseresource', ->
    usersGroups = new User().one(5).rel('groups').one(1)
    orphan = usersGroups.orphan()
    usersGroups.should.be.not.equal(orphan)
    backend.expectGET('/groups/1').respond -> [200]
    orphan.get()
    backend.flush()
   
  it 'should store data in same object over several requests', ->
    backend.expectGET('/users/1').respond -> [200, {id:1}]
    user = new User().one(1).get()
    data = user.data
    backend.flush()
    data.id.should.be.equal(1)
    data.name = 'Hans'
    backend.expectGET('/users/1').respond -> [200, {id:1}]
    user.get()
    data.name.should.be.equal('Hans')
    backend.flush()
    should.not.exist(data.name)
    data.id.should.be.equal(1)
  
  it 'should create a new resource', ->
    backend.expectPOST('/users', {name:'Chiquinho'}).respond ->
      [200, {id:1, name:'Chiquinho'}]
    user = new User().one()
    user.data.name = 'Chiquinho'
    user.save()
    backend.flush()
    user.id.should.be.equal(1)
    user.data.id.should.be.equal(1)
    
  it 'should update a resource', ->
    backend.expectPUT('/users/1', {name:'Peixinho'}).respond ->
      [200, {id:1, name:'Peixinho'}]
    user = new User().one(1)
    user.data.name = 'Peixinho'
    user.save()
    backend.flush()
    user.data.name.should.be.equal('Peixinho')
    
  it 'should delete a resource', ->
    backend.expectDELETE('/users/1').respond -> [200]
    user = new User().one(1)
    user.remove()
    backend.flush()

  it 'hasRelative should check if resource has a relative in a collection', ->
    user1 = new User().one(1)
    user2 = new User().one(2)
    user1friends = user1.rel('friends')
    user1friends.data = [
      {friendId: 2, userId:1}
      {friendId: 3, userId:1}
    ]
    # user2 is friend of user1
    user2.hasRelative(user1friends, 'friendId').should.be.true
    # user1 is no friend of himself
    user1.hasRelative(user1friends, 'friendId').should.be.false
    
  it 'bare() should clean data and id', ->
    user = new User().one(1)
    user.data = 
      name: 'Erdogan'
      country: 'Turkey'
    bare = user.bare()
    should.not.exist(user.id)
    should.not.exist(user.data.name)
    should.not.exist(user.data.country)
    
  it 'clean() should clean data'
  it 'base() should set a new base resource'
  it 'patch() should replace certain properties'
  it 'set() should replace all properties'
  it 'copy() should return a copy of a resource'