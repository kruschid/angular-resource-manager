app = angular.module 'app', [
  # components
  'tocNgResource'
  # 'tocResourceManager'
  # shared
  'navigation'
  # libs
  'ngCompass'
  'ui.bootstrap'
]      

app.config (ngCompassProvider) ->
  ngCompassProvider.addRoutes
    ngResource:
      route: '/ngresource'
      label: 'ngResource'
      templateUrl: 'toc-ng-resource/index.html'
    resourceManager:
      route: '/resource-manager'
      label: 'resource-manager'
      template: '<toc-resourcemanager></toc-resourcemanager>'