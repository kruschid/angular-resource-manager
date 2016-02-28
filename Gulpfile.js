/* global __dirname */
var gulp = require('gulp'),
    $ = require('gulp-load-plugins')(),
    del = require('del'),
    browserSync = require('browser-sync').create(),
    KarmaServer = require('karma').Server,
    ngdoc = require('dgeni-packages/ngdoc'),
    conf = require('./package.json').gcsj;

gulp.task('clean', function(cb){
  return del(conf.dest.public + '**/*', cb);
}); // clean

gulp.task('install', ['clean'], function(){
  return gulp.src(['bower.json', 'package.json'])
              .pipe($.install());
}); // install

gulp.task('copyLib', ['install'], function(){
  return gulp.src(conf.libs)
             .pipe($.sourcemaps.init())
             .pipe($.concat('libs.js'))
             .pipe($.sourcemaps.write())
             .pipe(gulp.dest(conf.dest.js));
}); // copyLib

gulp.task('copyFonts', ['install'], function(){
  return gulp.src(conf.fonts)
             .pipe(gulp.dest(conf.dest.fonts));
}); // copyFonts

gulp.task('copy', ['install'], $.sequence(['copyLib', 'copyFonts']));

gulp.task('views', function(cb){
  gulp.src(conf.src.views)
  .pipe($.plumber())
  .pipe($.jade({pretty: true}))
  .pipe($.concat('temp'))
  .pipe($.intercept(function(file){
    conf.views = file.contents.toString();
    var params = {locals: conf, cache: false, pretty: true};
    gulp.src(conf.src.mainView)
    .pipe($.plumber())
    .pipe($.jade(params))
    .pipe(gulp.dest(conf.dest.public))
    .on('finish', cb);
  })) // intercept
}); // jade

gulp.task('sass', function(){
  return gulp.src(conf.src.sass)
             .pipe($.plumber())
             .pipe($.sass())
             .pipe(gulp.dest(conf.dest.css))
}); // sass

gulp.task('coffee', function(){
  return gulp.src(conf.src.coffee)
             .pipe($.plumber())
             .pipe($.sourcemaps.init())
             .pipe($.coffee())
             .pipe($.concat('components.js'))
             .pipe($.sourcemaps.write())
             .pipe(gulp.dest(conf.dest.js))
}); // coffee

gulp.task('build', ['copy'], $.sequence(['views', 'coffee', 'sass']));

gulp.task('run', function(){
  gulp.src('./').pipe( $.shell(conf.run) );
}); // run

gulp.task('watch', ['build', 'run'], function(cb){
  gulp.watch(conf.src.sass, ['sass']);
  gulp.watch(conf.src.views, ['views']);
  gulp.watch(conf.src.mainView, ['views']);
  gulp.watch(conf.src.coffee, ['coffee']); 
  // use browsersync as proxy/live-reload-server
  browserSync.init(conf.browserSync);
  gulp.watch(conf.dest.public+'/**/*').on('change', browserSync.reload);
}); // watch

gulp.task('test', ['e2e', 'unit']);

gulp.task('e2e', function(){
  var protractorParams = {
    configFile: conf.testConf.protractor,
    debug: false,
    autoStartStopServer: true
  };
  gulp.src(__dirname)
      .pipe($.angularProtractor(protractorParams))
      .on('error', function(e){})
      .on('end', function(e){});
});

gulp.task('unit', function(cb){
  var karmaConf = {
    configFile: __dirname + '/' + conf.testConf.karma,
    singleRun: true
  };
  new KarmaServer(karmaConf, cb).start();
});

gulp.task('unitWatch', function(cb){
  var karmaConf = {
    configFile: __dirname + '/' + conf.testConf.karma,
    // singleRun: true
  };
  new KarmaServer(karmaConf, cb).start();
});
 
gulp.task('docs', function () {
  return gulp.src(['docs/**/*.ngdoc'])
    .pipe($.dgeni({packages: [ngdoc]}))
    .pipe(gulp.dest('build/docs'));
});