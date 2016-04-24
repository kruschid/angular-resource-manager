feathers = require('feathers')
memory = require('feathers-memory')
bodyParser = require('body-parser')
conf = require('../../conf/gulp.json')
fixtures = require('../../conf/fixtures.coffee')

# A Feathers app is the same as an Express app
app = feathers()

app.use(feathers.static(conf.views.dest))
# Add REST API support
app.configure(feathers.rest())
# Parse HTTP JSON bodies
app.use(bodyParser.json())

# services
chapters = memory
  store:fixtures.chapters
  startId: Object.keys(fixtures.chapters).length+1
users = memory
  store:fixtures.users
  startId: Object.keys(fixtures.users).length+1
groups = memory
  store: fixtures.groups
  startId: Object.keys(fixtures.groups).length+1
groupsUsers = memory
  store: fixtures.groupsUsers
  startId: Object.keys(fixtures.groupsUsers).length+1

#
# Chapters API
# 
app.use('/chapters', chapters)
app.use('/chapters/:chapterId/subchapters', 
  find: (params, callback) ->
    chapters.find(query:parentId:parseInt(params.chapterId))
    .then (sc) ->
      callback(null, sc)
  create: (chapter, params, callback) ->
    chapter.parentId = parseInt(params.chapterId)
    chapters.create(chapter).then ->
      callback(null, chapter)
)

#
# Users & Groups API
#
app.use('/users', users)
app.use('/users/:userId/groups', 
  find: (params, callback) ->
    groupsUsers.find(query:userId:parseInt(params.userId))
    .then (groupsUsers) ->
      groupIds = groupsUsers.map((ug)->ug.groupId)
      groups.find(query:groupId:$in:groupIds).then (groupsResult) ->
        callback(null, groupsResult)
) 
app.use('/users/:userId/groups-users', 
  find: (params, callback) ->
    groupsUsers.find(query:userId:parseInt(params.userId))
    .then (gu) ->
      callback(null, gu)
) 
app.use('/groups-users', groupsUsers)
app.use('/groups-users/:groupsUsersId/groups', 
  find: (params, callback) ->
    groups.find(query:groupsUsersId:parseInt(params.groupsUsersId))
    .then (g) ->
      callback(null,g)
) 
app.use('/groups', groups)
app.use('/users/:userId/groups-users', 
  find: (params, callback) ->
    groupsUsers.find(query:userId:parseInt(params.userId))
    .then (gu) ->
      callback(null, gu)
)

# Start the server
app.listen(3000)