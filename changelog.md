Roots Changelog
---------------

Beginning with version `2.0.0`, we will be maintaining a changelog to show what changes have been implemented each release. We hope that this will help roots users to stay informed about the updates being made and avoid breakage when a major or minor version bump occurs.

### 2.0.0 
(released xx/xx/2013)

- new app.coffee format, no longer uses `exports`, see [this example](https://github.com/jenius/roots/blob/master/templates/new/default/app.coffee)
- in all templates, `yield` has been changed to `content`, see [visionmedia/jade#153](https://github.com/visionmedia/jade/issues/1053)
- you can now use custom templates with roots. See [`roots template` docs](http://roots.cx/docs/man.html#TEMPLATE) for details
- compile speed incresed significantly for non-ignored files
- roots version number printed in app.coffee file on generation
- static files now symlinked when running `watch`, increases dev speed
- `order` function added for easy ordering of dynamic content
- `roots js` command changed to `roots pkg`, option to use [cdnjs](https://github.com/jenius/cli-js) added
- github pages deployer added, just run `roots deploy --gh-pages`
- `roots update` command removed, use npm instead
- update all dependencies to the latest version
- readme file significantly cleaned up, documentation on roots.cx revised and expanded

