"use strict"

# -- DEPENDENCIES --------------------------------------------------------------
gulp          = require "gulp"
cjsx          = require "gulp-cjsx"
concat        = require "gulp-concat"
connect       = require "gulp-connect"
header        = require "gulp-header"
gutil         = require "gulp-util"
uglify        = require "gulp-uglify"
pkg           = require "./package.json"

# -- BROWSERIFY ----------------------------------------------------------------
browserify    = require "browserify"
source        = require "vinyl-source-stream"
bundler       = browserify "./dashboard/app.cjsx", extensions: [".cjsx", ".coffee"]
bundler.transform require "coffee-reactify"

path =
  dist          :   "./dist"
  source        : [ "components/**/*.cjsx"
                    "dashboard/**/*.cjsx"
                    "dashboard/**/*.coffee"]
  dependencies  : [ "node_modules/react/dist/react-with-addons.js"
                    "node_modules/hamsa/dist/hamsa.js"]

# -- BANNER --------------------------------------------------------------------
banner = [
  "/**"
  " * <%= pkg.name %> - <%= pkg.description %>"
  " * @version v<%= pkg.version %>"
  " * @link    <%= pkg.homepage %>"
  " * @author  <%= pkg.author.name %> (<%= pkg.author.site %>)"
  " * @license <%= pkg.license %>"
  " */"
  ""
].join("\n")

# -- TASKS ---------------------------------------------------------------------
gulp.task "server", ->
  connect.server
    port      : 3000
    livereload: true
    root      : path.dist
gulp.task "source", ->
  bundler.bundle()
    .on "error", gutil.log.bind gutil, "Browserify Error"
    .pipe source "#{pkg.name}.js"
    # .pipe uglify mangle: true
    .pipe header banner, pkg: pkg
    .pipe gulp.dest "#{path.dist}/assets/js"
    .pipe connect.reload()

gulp.task "dependencies", ->
  gulp.src path.dependencies
    .pipe concat "#{pkg.name}.dependencies.js"
    # .pipe uglify mangle: true
    .pipe header banner, pkg: pkg
    .pipe gulp.dest "#{path.dist}/assets/js"

gulp.task "init", ["source", "dependencies"]

gulp.task "default", ->
  gulp.run ["server", "init"]
  gulp.watch path.source, ["source"]
