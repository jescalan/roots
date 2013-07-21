Roots Changelog
---------------

Beginning with version `2.0.0`, we will be maintaining a changelog to show what changes have been implemented each release. We hope that this will help roots users to stay informed about the updates being made and avoid breakage when a major or minor version bump occurs.

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

