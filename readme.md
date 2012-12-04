# Roots CLI

A light, super fast, and intuitive build system meant for rapid advanced front end development.

**NOTE:** This is still beta at the moment, and not prepared for mainstream use. If you still want to check it out, by all means feel free, but don't be surprised if a few little pieces aren't working properly. And get in touch too, ping me [on twitter](http://twitter.com/jescalan) and I'd be glad to help!

Installation
------------

Make sure you have [node.js](http://nodejs.org/) installed, then just run `npm install roots -g` and you'll be all set.

Usage
-----

Roots' main interface is it's command line tool. There are just a couple of main commands that do more or less what you would expect.

`$ roots new project-name`: Creates a new project template in the current directory, called `project-name`. Just a really simple scaffold of folders as well as some basic settings, a custom html boilerplate, and the roots css library. Good way to get off the ground quickly with the right structure. Add `--basic` for straight html, css, and js or `--express` for an express app template with roots integrated. To use roots with rails, use the [`roots-rails` gem](http://github.com/jenius/roots-rails) instead.

`$ roots watch`: The bulk of roots' usefulness is here. This command compiles your project, opens it up in your browser, then continues watching all your files for changes. As soon as you save, roots will recompile the project and immediately refresh the browser. So fresh.

`$ roots compile`: Compiles your project once to the public folder, with everything minified and compressed.

`$ roots deploy project-name`: Compiles, compresses, and deploys your project to heroku as `project-name`. If you don't add a name, heroku will generate one automatically. This command depends on the heroku toolbelt - if you don't have it, the command will instruct you on how to install it. Coming soon, custom ftp server deploys!

`$ roots update`: Upgrades roots to the latest version.

Features
--------

- super straightforward installation (no ruby needed)
- jade, stylus, and coffeescript default stack
- sprockets-style coffeescript requires
- custom super fast live reload implementation
- compile errors reported as a flash message, doesn't break workflow
- layouts - default and custom overrides
- partials (all locals automatically available)
- clean and intuitive settings file
- ignore files based on string or regex (minimatch)
- global variables and functions for views
- one command deploy to heroku
- coffeescript and markdown can be written directly into views
- minifies and compresses files on deploy
- efficient javascript package management via bower and require.js
- awesome built-in css helper library
- also supports ejs and straight html, css, and javascript
- easy to extend and add languages with a well-documented and simple plugin interface

CSS Library
-----------

CSS is a huge pain in the ass and we always end up doing the same shit over and over. Compass is great, but wasn't terse or magical enough for me, doesnt include UI components, is too reliant on ruby, and is too tied together with its build system. So I put together my own css helper library. It's a lot like [nib](https://github.com/visionmedia/nib) except it's more thorough and actually has documentation (well, soon it will). It's been living on its own for a number of months and is used in production on a number of production sites for large companies already.

The CSS library is very modular in its construction, and higher level mixins can easily be broken down into their components and customized as is necessary. This means you can start with the full bootstrap-like framework for an initial mock, then break it down into custom components when it's time to build a production site without having to trash your code. The library itself is completely independent from the build system, and can be used anywhere else if you want. It lives at [this repo](http://github.com/jenius/roots-css), and although it's included automatically whenever you use stylus, it can be loaded manually or overridden any time.

Documentation for the css library [can be found here](#).

Plugins
-------

It's pretty straightforward to add a plugin to customize roots' functionality. Plugins need only be one file, and are frequently less than 10 lines of javascript (many of the core compilers are, actually). To create a plugin, just drop a new file, javascript or coffeescript, into `/plugins`. The module need only export two methods, `settings` and `compile`.

Here are a few examples of how plugins can look. Note that currently there is no dependency management system for plugins, so you must include any npm packages directly with the plugin.

- [sass compiler (command line)](https://github.com/jenius/roots-cli/blob/master/test/plugins/sass.coffee)
- [ejs compiler (templates)](https://github.com/jenius/roots-cli/blob/master/lib/compilers/core/jade.js)
- [stylus compiler (js library-based)](https://github.com/jenius/roots-cli/blob/master/lib/compilers/core/styl.js)

More thorough documentation on `Helper`'s api will be available on the near future. For now, if you are curious, just check out the [compile helper source](https://github.com/jenius/roots-cli/blob/master/lib/compilers/compile-helper.coffee).

Note that plugins are pulled into roots' environment, so if you want to require any external files, you need to use `module.require()` instead of just `require()` in order to have roots look for files starting in the plugins directory.

The following commands are also available to help:

- `roots plugin generate` generates a plugin template for you in the `/plugins` folder.
- `roots plugin install github-username/repo` installs a plugin to `/plugins` from github.

Client Side JS
--------------

Using javascript libraries on the client-side is super helpful, but downloading them for every project and keeping them up to date is a huge pain. The wonderful folks at twitter created [bower](http://twitter.github.com/bower/) to make life easier for us as far as javascript client-side package management. You can run `roots install` followed by any package name to have bower install it directly into the `js/components` folder of your roots project. Also available:

`roots js list` - list of installed packages
`roots js search name` - search for a package by `name`
`roots js update name` - update `name` to the latest version
`roots js uninstall name` - remove `name`
`roots js info name` - get more info about `name`

There are a lot of great open-source packages registered with bower. Check them out [here](http://sindresorhus.com/bower-components/). In addition, [require.js](http://requirejs.org) is included by default to help load your client-side javascript dependencies smoothly.

Ambition
--------

I'm very excited about this project, because it makes my life a ton easier and it saves me and my employer many hours. Once the static site compiler is finished and tested, I plan on porting the system first to node (with express), then to rails (likely a gem for rails 4). If you are interested in helping out with this project or the rails or node ports, get in touch. I'd love to have you on board.

That being said, I have a lot to learn about node still, and this project is in its current state not the most clear, organized, and modular thing on earth. But it will be eventually, and will gradually happen as I clean, learn, and refactor.

##### To Do

- add railway.js template
- deploy to custom ftp server
- image optimization (this has external dependencies... yech)
- better testing

Contributors
------------

Everyone who has contributed to this project is the most awesome person ever. I want to give a huge thanks especially to these people:

- Sam Saccone (@samccone), advice, support, and responsable for a good bit of code