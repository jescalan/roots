# Roots CLI

A light, super fast, and intuitive build system meant for rapid advanced front end development.

**NOTE:** This is super alpha at the moment, and not prepared for mainstream use. If you still want to check it out, by all means feel free, but don't be surprised if a few little pieces aren't working properly. And get in touch too, ping me [on twitter](http://twitter.com/jescalan) and I'd be glad to help!

### Installation

Make sure you have [node.js](http://nodejs.org/) installed, then just run `npm install roots-static -g` and you'll be all set.

### Usage

Roots' main interface is it's command line tool. There are just a couple of main commands that do more or less what you would expect.

`$ roots new project-name`: Creates a new project template in the current directory, called `project-name`. Just a really simple scaffold of folders as well as some basic settings, a custom html boilerplate, and the roots css library. Good way to get off the ground quickly with the right structure.

`$ roots watch`: The bulk of roots' usefulness is here. This command compiles your project, opens it up in your browser, then continues watching all your files for changes. As soon as you save, roots will recompile the project and immediately refresh the browser. So fresh.

`$ roots compile`: Compiles your project once to the public folder, with everything minified and compressed.

`$ roots deploy project-name`: Compiles, compresses, and deploys your project to heroku as `project-name`. If you don't add a name, heroku will generate one automatically. This command depends on the heroku toolbelt - if you don't have it, the command will instruct you on how to install it. Coming soon, custom ftp server deploys!

`$ roots update`: Upgrades roots to the latest version.

### Features

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
- one command deploys to heroku or a custom server via ftp (custom server not yet implemented)
- coffeescript and markdown can be written directly into views
- minifies and compresses files and optimizes images on deploy
- efficient javascript package management via bower and require.js
- awesome built-in css helper library makes life so much easier
- also supports ejs and straight html, css, and javascript
- easy to extend and add languages with a well-documented and simple plugin interface

### CSS Library

CSS is a huge pain in the ass and we always end up doing the same shit over and over. Compass is great, but wasn't terse or magical enough for me, doesnt include UI components, is too reliant on ruby, and is too tied together with its build system. So I put together my own css helper library. It's a lot like [nib](https://github.com/visionmedia/nib) except it's more thorough and actually has documentation. It's been living on its own for a number of months and is used in production on a number of production sites for large companies already.

The CSS library is very modular in its construction, and higher level mixins can easily be broken down into their components and customized as is necessary. This means you can start with the full bootstrap-like framework for an initial mock, then break it down into custom components when it's time to build a production site without having to trash your code. The library itself is completely independent from the build system, and can be used anywhere else if you want. It lives entirely in the `roots-css` folder in `assets/css`, and at [this repo](#).

The library will have received a full rewrite by the time roots is released, and should have really sweet docs with all sorts of interactive examples, which will be linked to here.

### Plugins

It's pretty straightforward to add a plugin to customize roots' functionality. Plugins need only be one file, and are frequently less than 10 lines of javascript (many of the core compilers are, actually). To create a plugin, just drop a new file, javascript or coffeescript, into `vendor/plugins`. The module need only export two methods, `settings` and `compile`.

Here are a few examples of how plugins can look. Note that currently there is no dependency management system for plugins, so you must include any npm packages directly with the plugin.

- [sass compiler (command line)](https://github.com/jenius/roots-cli/blob/master/test/vendor/plugins/sass.coffee)
- [ejs compiler (templates)](https://github.com/jenius/roots-cli/blob/master/lib/compilers/core/jade.js)
- [stylus compiler (js library-based)](https://github.com/jenius/roots-cli/blob/master/lib/compilers/core/styl.js)

More thorough documentation on `Helper`'s api will be available on the near future. For now, if you are curious, just check out the [compile helper source](https://github.com/jenius/roots-cli/blob/master/lib/compilers/compile-helper.coffee).

##### not yet implemented

Plugins can be manually installed into vendor/plugins or directly pulled from a github repo using a command like `roots plugin install jenius/roots-sass`, the final parameter being `github-username/repo-name`. If you'd like to write a plugin, the command `roots plugin generate` will create a nice starting template inside vendor/plugins. All known plugins will be listed on the roots website [link].

### Client Side JS

Using javascript libraries on the client-side is super helpful, but downloading them for every project and keeping them up to date is a huge pain. The wonderful folks at twitter created [bower](#) to make life easier for us as far as javascript client-side package management. You can run `roots install` followed by any package name to have bower install it directly into the vendor folder of your roots project. Also available:

`roots js list`
`roots js search`
`roots js update package-name`

There are a lot of great open-source packages registered with bower. Check them out [here](http://sindresorhus.com/bower-components/). But don't ever use bootstrap, or I will cry. Root's css library ships with nicely designed defaults if you are trying to make a good-looking wireframe or back end (just run `framework()` in your main stylus file), and if you are working on a production site, get a designer to help, or shame on you.

Although not required, it's highly recommended that you also use [require.js](http://requirejs.org) to load your client-side javascript dependencies smoothly. This functionality is already built in if you generate your project with `roots new`, and includes instruction on how to use require.js's system. The require.js site is well stuctured and has great docs if you are looking for more information.

### Ambition

I'm very excited about this project, because it makes my life a ton easier and it saves me and my employer many hours. Once the static site compiler is finished and tested, I plan on porting the system first to node (with express), then to rails (likely a gem for rails 4). Life without useful tools like the roots css library, bower, requirejs, live reloading, nice templating languages, and single-command deploys just seems sad to me, and makes everything take longer. If you are interested in helping out with this project or the rails or node ports, get in touch. I'd love to have you on board.

That being said, I have a lot to learn about node still, and this project is in its current state not the most clear, organized, and modular thing on earth. But it will be eventually, and will gradually happen as I clean, learn, and refactor.

##### To Do

- load plugins based on paths provided in app.coffee for speed + simplicity
- roots plugin generate and roots plugin install commands
- package the css library into its own module and stylus.use() it instead
- pull in vendor css, js, and img (only static)
- implement image optimization
- custom range local for repeated content
- deploy to custom ftp server
- integrate with express 3.0
- think about tumblr theming plugin

##### Refactor Phases

- phases 1 and 2 complete (organize commands and organize compile process)
- phase 3: figure out how to deal with callbacks for parallel async operations
- phase 4: optimize speed

### Love/Hate

Do you love and/or hate this? Maybe you even want to help, or suggest an improvement. Tell us all about it. Find my email and harass me or file an issue. <3

### Contributors

Everyone who has contributed to this project is the most awesome person ever. I want to give a huge thanks especially to these people:

- Sam Saccone (@samccone), advice, support, and responsable for a good bit of code