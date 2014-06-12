angular.module('gamEvolve.game.assets', [
  'ui.bootstrap'
  'omr.angularFileDnD'
  'xeditable'
])
.controller 'AssetsCtrl', ($scope, currentGame, editorContext) ->
  # Get the actions object from the currentGame service, and keep it updated
  $scope.assets = null
  $scope.fileName = ""
  $scope.file = null

  # Transform assets to array so we can loop over it easier
  copyFromGameToScope = -> 
    if currentGame.version?
      $scope.assets = ({ name: name, data: data } for name, data of currentGame.getCurrentCircuitData().assets)

  # Bring currentGame into scope so we can watch it 
  $scope.currentGame = currentGame
  $scope.$watch("currentGame.localVersion", copyFromGameToScope, true)
  $scope.$watch((-> editorContext.currentCircuitMeta), copyFromGameToScope)

  # Transform assets back to object so we can loop over it easier
  copyFromScopeToGame = -> 
    if $scope.assets == null then return 

    assetsAsObject = _.object(([asset.name, asset.data] for asset in $scope.assets))
    if _.isEqual(assetsAsObject, currentGame.version.assets) then return 

    currentGame.getCurrentCircuitData().assets = assetsAsObject
    currentGame.updateLocalVersion()
  $scope.$watch("assets", copyFromScopeToGame, true)

  $scope.remove = (index) -> 
    if window.confirm("Are you sure you want to delete this asset?")
      $scope.assets.splice(index, 1)

  $scope.$watch "file", ->
    if $scope.fileName is "" then return 

    $scope.assets.push({ name: $scope.fileName, data: $scope.file })
    # Reset this so that the same filename dragged twice in a row will be taken into account
    $scope.fileName = ""  
    $scope.file = null
