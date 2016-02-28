exports.config = {
  framework: 'jasmine',
  seleniumAddress: 'http://localhost:4444/wd/hub',
  specs: [
    '../bower_components/angular-mocks/angular-mocks.js',
    '../app/shared/resource-manager/resource-manager.js',
    'resource-manager-spec.coffee'
  ]
};