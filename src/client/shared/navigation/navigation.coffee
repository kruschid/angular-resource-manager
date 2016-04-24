navigation = angular.module 'navigation', []

navigation.constant 'NavbarItems', [
  routeName: 'ngResource'
  label: 'ngResource'
,
  routeName: 'resourceManager'
  label: 'resurce-manager'
]

###*
# Description
# @memberOf navigation
# @namespace navbar
###   
navigation.component 'navbar',
  templateUrl: 'navigation/navbar.html'
  controllerAs: 'navbarCtrl'
  controller: class 
    constructor: (@NavbarItems) ->