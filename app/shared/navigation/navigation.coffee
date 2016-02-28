navigation = angular.module 'navigation', []

navigation.constant 'NavbarItems', [
  routeName: 'home'
  label: 'Home'
,  
  routeName: 'error'
  label: 'Error 404'
  params: {code: 404}
,
  routeName: 'error'
  label: 'Error 500'
  params: {code: 500}
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