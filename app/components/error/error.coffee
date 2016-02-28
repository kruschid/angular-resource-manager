###*
# Error-Module description
# @namespace error
###
error = angular.module 'error', []

###*
# Error-Component description...
# @memberOf error
# @namespace error
# @param {Number} code
###
error.component 'error',
  templateUrl: 'error/error.html'
  bindings:
    code: '<'
  controllerAs: 'ErrorCtrl'