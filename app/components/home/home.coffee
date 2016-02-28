###*
# Home-Module Description...
# @namespace home
###
home = angular.module 'home', []

###*
# Home-component description...
# @memberOf home
# @namespace home
# @param {Object} continents
# @param {Object} countries
# @param {Object} cities
###
home.component 'home',
  templateUrl: 'home/home.html'
  bindings:
    continents: '<'
    countries: '<'
    cities: '<'
    oneCity: '<'
  controllerAs: 'HomeCtrl'