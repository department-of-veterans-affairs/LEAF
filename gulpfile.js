/*
* * * * * ==============================
* * * * * ==============================
* * * * * ==============================
* * * * * ==============================
========================================
========================================
========================================
----------------------------------------
USWDS SASS GULPFILE
----------------------------------------
*/

const autoprefixer = require("autoprefixer");
const csso = require("postcss-csso");
const gulp = require("gulp");
const pkg = require("./node_modules/uswds/package.json");
const postcss = require("gulp-postcss");
const replace = require("gulp-replace");
const sass = require("gulp-sass");
const sourcemaps = require("gulp-sourcemaps");
const uswds = require("./node_modules/uswds-gulp/config/uswds");
const concat = require('gulp-concat');
sass.compiler = require("sass");


/*
----------------------------------------
PATHS
----------------------------------------
- All paths are relative to the
  project root
- Don't use a trailing `/` for path
  names
----------------------------------------
*/

// Project Sass source directory
const PROJECT_SASS_SRC = "./libs/sass";

// Compiled CSS destination
const CSS_DEST = "./libs/css";

// font destination
const FONT_DEST = "./libs/css/fonts";

/*
----------------------------------------
TASKS
----------------------------------------
*/

gulp.task("icons", () => {
  return gulp.src('node_modules/@fortawesome/fontawesome-free/webfonts/*')
  .pipe(gulp.dest(`${FONT_DEST}/fontawesome`));
});

gulp.task("build-sass", function(done) {
  var plugins = [
    // Autoprefix
    autoprefixer({
      cascade: false,
      grid: true
    }),
    // Minify
    csso({ forceMediaMerge: false })
  ];
  return (
    gulp
      .src([`${PROJECT_SASS_SRC}/styles.scss`])
      .pipe(sourcemaps.init({ largeFile: true }))
      .pipe(
        sass.sync({
          includePaths: [
            `${PROJECT_SASS_SRC}`,
            `${uswds}/scss`,
          ]
        })
      )
      .pipe(postcss(plugins))
      .pipe(sourcemaps.write("."))
      .pipe(concat('leaf.css')) // added to make all files roll into one big CSS
      .pipe(gulp.dest(`${CSS_DEST}`))
  );
});

gulp.task(
  "init",
  gulp.series(
    "icons",
    "build-sass",
  )
);

gulp.task("watch-sass", function() {
  gulp.watch(`${PROJECT_SASS_SRC}/**/*.scss`, gulp.series("build-sass"));
});

gulp.task("watch", gulp.series("build-sass", "watch-sass"));

gulp.task("default", gulp.series("watch"));
