app = angular.module 'app', [
  # components
  'home'
  'error'
  # shared
  'navigation'
  'api'
  # libs
  'ngCompass'
  'ui.bootstrap'
]      

app.config (ngCompassProvider) ->
  ngCompassProvider.addRoutes
    home:
      route: '/'
      label: 'Home'
      template: '<home continents="$resolve.continents"
                    countries="$resolve.countries"
                    cities="$resolve.cities" 
                    one-city="$resolve.oneCity"></home>'
      resolve:
        continents: (Continent) -> Continent.many().get().data
        countries: (Country) -> Country.many().get().data
        cities: (City) -> City.many().get().data
        oneCity: (City) -> City.one(1).get().data
    error:
      route: '/error/:code'
      label: 'Error'
      template: '<error code="$resolve.code"></error>'
      resolve: 
        code: ($route) -> $route.current.params.code
    '404':
      redirectTo: '/error/404'
      default: true
