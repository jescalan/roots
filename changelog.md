Roots Changelog
---------------

Beginning with version `2.0.0`, we will be maintaining a changelog to show what changes have been implemented each release. We hope that this will help roots users to stay informed about the updates being made and avoid breakage when a major or minor version bump occurs.

### 2.1.0
(not yet released)
- huge internal rewrite, more modular, more coffeescript, better test coverage
- built-in compilers for [scss](http://sass-lang.com/), [less](http://lesscss.org/), [markdown](http://daringfireball.net/projects/markdown/), [mustache](http://mustache.github.io/mustache.5.html), [haml-coffee](https://github.com/netzpirat/haml-coffee), and [eco](https://github.com/sstephenson/eco).
- on compile, css is processed by [autoprefixer](https://github.com/ai/autoprefixer)
- layout language is no longer connected to view language. So you can compile a markdown view into a jade layout, for example
- livereload tag no longer necessary, this happens internally (whoo!)
- deep nested dynamic content has been implemented (see #230)
- upgrade on all dependencies to the latest versions
- **[BREAKING]** update to plugins, `compile` now takes three arguments, `file`, `options`, and `callback`. To fix, just add the `options` param on any plugin's `compile` function.

### 2.0.6
(released 09/25/2013)
- fix permissions error with roots custom templates

### 2.0.5
(released 08/15/2013)
- github pages deployer is now very reliable
- post.contents now available in locals for dynamic content
- reload spinner fixed so it shows up when you have scrolled down

### 2.0.4
(released 07/23/2013)
- patch to fix a bug in the github pages deployer

### 2.0.3
(released 07/18/2013)
- patch to fix the `deploy` command

### 2.0.2
(released 06/25/2013)
- patch to improve file addition and removal in the watch command

### 2.0.1
(released 06/24/2013)
- patch a bug in precompiled templates

### 2.0.0 
(released 06/24/2013)

- new app.coffee format, no longer uses `exports`, see [this example](https://github.com/jenius/roots/blob/master/templates/new/default/app.coffee)
- in all templates, `yield` has been changed to `content`, see [visionmedia/jade#153](https://github.com/visionmedia/jade/issues/1053)
- you can now use custom templates with roots. See [`roots template` docs](http://roots.cx/docs#templates) for details
- multipass compilation added, [see docs](http://roots.cx/docs#multipass)
- fixed a bug that indcreases compile speed significantly for non-ignored files and makes the compiler not bomb when you delete a file
- roots version number printed in app.coffee file on generation
- static files now symlinked when running `watch`, increases dev speed
- `sort` function added for easy ordering of dynamic content, [see docs](http://roots.cx/docs#dynamic)
- `roots js` command changed to `roots pkg`, option to use [cdnjs](https://github.com/jenius/cli-js) added
- github pages deployer added, use `roots deploy --gh-pages`
- `roots update` command removed, use npm instead
- all dependencies updated to the latest version
- readme file significantly cleaned up, documentation on roots.cx revised and expanded

