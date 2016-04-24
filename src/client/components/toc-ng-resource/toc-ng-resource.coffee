###*
# TOC
# @namespace tocNgResource
###
toc = angular.module 'tocNgResource', [
  'ngResource'
]

###*
# Chapter API
# @memberOf toc
# @namespace Chapter
# @return {$resource}
###
toc.factory 'Chapter', ($resource) -> 
  paramDefaults =
    chapterId: '@id'
  actions = 
    update:
      method: 'PUT'
      url: '/chapters/:chapterId'
    querySubChapters:
      method: 'GET'
      url: '/chapters/:chapterId/subchapters'
      isArray: true
    createSubChapter:
      method: 'POST'
      url: '/chapters/:chapterId/subchapters'
    queryByCrossReferenceSource:
      method: 'GET'
      url: '/cross-reference/:crossReferenceId/source'
      isArray: true
    queryByCrossReferenceTarget:
      method: 'GET'
      url: '/cross-reference/:crossReferenceId/target'
      isArray: true
  return $resource('/chapters/:chapterId', paramDefaults, actions)

###*
# Resource State Machine
# @memberOf tocNgResource
# @namespace ResourceStateMachine
###
class ResourceStateMachine
  constructor: ->
    @loading = @deleting = @saving = 0
  
  startLoading: -> @loading++
  finishLoading: -> @loading--
  isLoading: -> @loading > 0
  
  startDeleting: -> @deleting++
  finishDeleting: -> @deleting--
  isDeleting: -> @deleting > 0
  
  startSaving: -> @saving++
  finishSaving: -> @saving--
  isSaving: -> @saving > 0

###*
# Chapter CRUD Controller
# @memberOf tocNgResource
# @namespace ChapterCtrl
# @extends ResourceStateMachine
###
class ChapterCtrl extends ResourceStateMachine
  # Annotation für Dependency Injection
  ChapterCtrl.$inject = ['Chapter']
  
  constructor: (@chapterService) ->
    super()
    @getChapters()
    
  getChapters: ->
    @startLoading()
    promise = @chapterService.query().$promise
    promise.then (chapters) =>
      @chapters = chapters
    promise.finally =>
      @finishLoading()
     
  delete: (chapter) ->
    @startDeleting()
    promise = chapter.$delete()
    promise.then =>
      @getChapters()
    promise.finally =>
      @finishDeleting() 
      
  create: (chapter) ->
    @startSaving()
    promise = new @chapterService(chapter).$save()
    promise.then =>
      @getChapters()
    promise.finally =>
      @finishSaving()
      
  update: (chapter) ->
    @startSaving()
    promise = chapter.$update()
    promise.finally =>
      @finishSaving()

###*
# Beispiel: Ressource auslesen
# @memberOf tocNgResource
# @namespace readNgResource
###
toc.component 'readNgResource',
  templateUrl: 'toc-ng-resource/read.html'
  controllerAs: 'vm'
  controller: ChapterCtrl

###*
# Beispiel: Ressource entfernen
# @memberOf tocNgResource
# @namespace deleteNgResource
###
toc.component 'deleteNgResource',
  templateUrl: 'toc-ng-resource/delete.html'
  controllerAs: 'vm'
  controller: ChapterCtrl

###*
# Beispiel: Ressource erstellen
# @memberOf tocNgResource
# @namespace createNgResource
###
toc.component 'createNgResource',
  templateUrl: 'toc-ng-resource/create.html'
  controllerAs: 'vm'
  controller: ChapterCtrl

###*
# Beispiel: Ressource aktualisieren
# @memberOf tocNgResource
# @namespace updateNgResource
###
toc.component 'updateNgResource',
  templateUrl: 'toc-ng-resource/update.html'
  controllerAs: 'vm'
  controller: ChapterCtrl

###*
# Chapter controller for 1:n relations
# @memberOf tocNgResource
# @namespace Chapter1NCtrl
###
class Chapter1NCtrl extends ResourceStateMachine
  Chapter1NCtrl.$inject = ['Chapter']
  
  constructor: (@ChapterService) ->
    super()
    @getChapters()
  
  getChapters: ->
    @startLoading()
    promise = @ChapterService.querySubChapters(chapterId:0).$promise
    promise.then (chapters) =>
      @chapters = chapters
      @getSubChapters(chapter) for chapter in chapters
    promise.finally =>
      @finishLoading()
    
  getSubChapters: (chapter) ->
    @startLoading()
    cb = (subChapters) ->
      @children = subChapters
    promise = @ChapterService.querySubChapters(chapterId:chapter.id).$promise
    promise.then(cb.bind(chapter))
    promise.finally =>
      @finishLoading()

  createSubChapter: (chapter, subChapter) ->
    @startSaving()
    promise = new @ChapterService(subChapter).$createSubChapter(chapterId:chapter.id)
    promise.then =>
      @getSubChapters(chapter)
    promise.finally =>
      @finishSaving()

###*
# Beispiel: 1:n Ressource auslesen
# @memberOf tocNgResource
# @namespace read1nNgResource
###
toc.component 'read1nNgResource',
  templateUrl: 'toc-ng-resource/read1n.html'
  controllerAs: 'vm'
  controller: Chapter1NCtrl

###*
# Beispiel: 1:n Ressource erstellen
# @memberOf tocNgResource
# @namespace create1nNgResource
###
toc.component 'create1nNgResource',
  templateUrl: 'toc-ng-resource/create1n.html'
  controllerAs: 'vm'
  controller: Chapter1NCtrl


###*
# Group API
# some methods were omitted because our service covers only a subset of usecases usually exists in n:m relations
# @memberOf toc
# @namespace Group
# @return {$resource}
###
toc.factory 'Group', ($resource) -> 
  actions =
    queryByGroupsUsers:
      method: 'GET'
      url: '/groupsUsers/:groupsUsersId/groups'
      isArray: true
  return $resource('/groups/:groupId', {}, actions)

###*
# GroupUser API
# some methods were omitted because our service covers only a subset of usecases usually exists in n:m relations
# @memberOf toc
# @namespace GroupUser
# @return {$resource}
###
toc.factory 'GroupUser', ($resource) ->
  defaultParams =
    groupsUsersId: '@id'
  actions =
    queryByUser:
      method: 'GET'
      url: '/users/:userId/groups-users'
      isArray: true
    queryByGroup:
      method: 'GET'
      url: '/group/:groupId/groups-users'
      isArray: true
  return $resource('/groups-users/:groupsUsersId', defaultParams, actions)

###*
# GroupUser API
# some methods were omitted because our service covers only a subset of usecases usually exists in n:m relations
# @memberOf toc
# @namespace GroupUser
# @return {$resource}
###
toc.factory 'User', ($resource) -> 
  return $resource('/users/:userId')

###*
# User/Group controller for m:n relations
# @memberOf tocNgResource
# @namespace UserGroupCtrl
###
class UserGroupCtrl extends ResourceStateMachine
  UserGroupCtrl.$inject = ['User', 'Group', 'GroupUser']
  constructor: (@UserService, @GroupService, @GroupUserService) ->
    super()
    @getAllGroups()
    @getUsers()
  
  getAllGroups: ->
    @startLoading()
    @groups = @GroupService.query()
    @groups.$promise.finally( @finishLoading.bind(@) )
    # selbes Resultat aber kürzer:
    # @groups.$promise.finally => @startLoading()
  
  #
  # Requesting in 4 steps
  #  
  # (1)
  getUsers: ->
    @startLoading()
    promise = @UserService.query().$promise
    promise.then( @getGroupsUsers.bind(@) )
    promise.finally( @finishLoading.bind(@) ) 
  # (2)
  getGroupsUsers: (users) ->
    @users = users
    for user in users 
      @startLoading()
      promise = @GroupUserService.queryByUser(userId:user.id).$promise
      promise.then( @getGroup.bind(@, user) )
      promise.finally( @finishLoading.bind(@) )
  # (3)
  getGroup: (user, groupsUsers) ->
    user.groups = []
    for groupUser in groupsUsers
      @startLoading()
      promise = @GroupService.get(groupId:groupUser.groupId).$promise
      promise.then( @assignGroup.bind(@, user) )
      promise.finally( @finishLoading.bind(@) )
  # (4)
  assignGroup: (user, group) ->
    user.groups.push(group)
  
  hasGroup: (user, group) ->
    return false if not user.groups
    for uGroup in user.groups
      if uGroup.id is group.id 
        return true 
    return false
  
  addGroup: (user, group) ->
    groupUser = 
      userId: user.id
      groupId: group.id
    @startSaving()
    promise = new @GroupUserService(groupUser).$save()
    promise.then( @getUsers.bind(@) )
    promise.finally( @finishSaving.bind(@) )
    
  #
  # Removing relation in 2 steps:
  #
  # (1)
  removeGroupUser: (group, user) ->
    @startDeleting()
    promise = @GroupUserService.queryByUser(userId: user.id).$promise
    promise.then( @removeGroupUser2.bind(@, group, user) )
    promise.finally( @finishDeleting.bind(@) )
  # (2)
  removeGroupUser2: (group, user, groupsUsers) ->
    for groupUser in groupsUsers
      if groupUser.groupId is group.id and groupUser.userId is user.id
        @startDeleting()
        promise = groupUser.$delete()
        promise.then( @getUsers.bind(@) )
        promise.finally( @finishDeleting.bind(@) )

###*
# Beispiel: m:n Ressource laden
# @memberOf tocNgResource
# @namespace readmnNgResource
###
toc.component 'manageMnNgResource',
  templateUrl: 'toc-ng-resource/managemn.html'
  controllerAs: 'vm'
  controller: UserGroupCtrl