angular.module('gamEvolve.model.games', [])


.factory 'currentGame', (GameVersionUpdatedEvent, WillChangeLocalVersionEvent) ->

  version: null
  setVersion: (newVersion) ->
    @version = newVersion
    GameVersionUpdatedEvent.send(newVersion)
  info: null
  creator: null
  localVersion: _.uniqueId("v")
  windowId: RW.makeGuid() # Used to identify windows across drag and drop
  standardLibrary: null
  hasUnpublishedChanges: false

  statusMessage: ""

  reset: -> 
    @info = null
    @version = null
    @creator = null
    @localVersion = _.uniqueId("v")
    @hasUnpublishedChanges = false

  updateLocalVersion: -> 
    # Give an opportunity to change the game code before it is updated
    WillChangeLocalVersionEvent.send()
    @localVersion = _.uniqueId("v")

  setHasUnpublishedChanges: -> @hasUnpublishedChanges = true
  clearHasUnpublishedChanges: -> @hasUnpublishedChanges = false

  setStatusMessage: (message) -> @statusMessage = message

.factory 'games', ($http, $q, $location, loggedUser, currentGame, gameConverter, gameHistory, gameTime, undo, overlay, GameVersionPublishedEvent, NewGameLoadingEvent) ->

  games = {}
  games.saveInfo = ->
    $http.post('/api/games', currentGame.info)
      .then (savedGame) ->
        currentGame.info = savedGame.data
        currentGame.version.gameId = currentGame.info.id
        $http.get("/api/users?id=#{currentGame.info.ownerId}")
      .then (creator) ->
        currentGame.creator = creator.data.username

  games.updateInfo = ->
    $http.put('/api/games', currentGame.info)
    
  games.saveVersion = ->
    delete currentGame.version.id # Make sure a new 'game-version' entity is created
    $http.post('/api/game-versions', gameConverter.convertGameVersionToEmbeddedJson(currentGame.version))
      .then((savedGameVersion) -> currentGame.setVersion(gameConverter.convertGameVersionFromEmbeddedJson(savedGameVersion.data)))
      .then(-> GameVersionPublishedEvent.send())

  games.clearGameData = -> 
    # Clear the current game data
    # TODO: have each service detect this event rather than hard coding it here?
    NewGameLoadingEvent.send()
    overlay.makeNotification()
    currentGame.reset()
    gameHistory.reset()
    gameTime.reset()
    undo.reset()

  games.publishCurrent = ->
    games.updateInfo().then(games.saveVersion)

  games.forkCurrent = ->
    delete currentGame.info.id # Removing the game ID will make the server provide a new one
    games.saveInfo().then ->
      $location.path("/game/#{currentGame.version.gameId}/edit")
      games.saveVersion()

  games.deleteCurrent = ->
    $http.delete("/api/games/#{currentGame.version.gameId}").then(currentGame.reset)

  games.loadAll = ->
    gamesQuery = $http.get('/api/games')
    usersQuery = $http.get("/api/users") #?{fields={id: 1, username: 1}
    fillGamesList = ([gamesResult, usersResult]) -> 
      for game in gamesResult.data
        id: game.id
        name: game.name
        author: _.findWhere(usersResult.data, { id: game.ownerId }).username
    # This promise will be returned
    $q.all([gamesQuery, usersQuery]).then(fillGamesList, -> alert("Can't load games"))

  # Load the game content and the creator info, then put it all into currentGame
  games.load = (game) ->
    games.clearGameData()

    query = '{"gameId":"' + game.id + '","$sort":{"versionNumber":-1},"$limit":1}'
    getVersion = $http.get("/api/game-versions?#{query}")
    getCreator = $http.get("/api/users?id=#{game.ownerId}")
    getStandardLibrary = $http.get("/assets/standardLibrary.json")
    updateCurrentGame = ([version, creator, standardLibrary]) ->
      currentGame.info = game

      gameCode = gameConverter.convertGameVersionFromEmbeddedJson(version.data[0])
      gameConverter.bringGameUpToDate(gameCode)
      currentGame.setVersion(gameCode)

      currentGame.standardLibrary = standardLibrary.data
      currentGame.updateLocalVersion()
      currentGame.creator = creator.data.username
    onError = (error) -> 
      console.error("Error loading game", error) 
      window.alert("Error loading game")
    onDone = -> overlay.clearNotification()
    $q.all([getVersion, getCreator, getStandardLibrary]).then(updateCurrentGame, onError).finally(onDone)

  games.loadFromId = (gameId) ->
    $http.get("/api/games/#{gameId}")
      .success(games.load)
      .error (error) ->
        console.log error
        window.alert "Hmmm, that game doesn't seem to exist"
        $location.path("/")

  return games
