# Roots CLI

A light, super fast, and intuitive build system meant for rapid advanced front end development.

### Installation

Currently there is no install script, but there will be. To test the project quickly, hit `./run` from the terminal.

### Usage

Roots' main interface is it's command line tool. There are just a couple of commands that do more or less what you would expect.

`$ roots new project-name`: Creates a new project template in the current directory, called `project-name`. Just a really simple scaffold of folders as well as some basic settings, a custom html boilerplate, and the roots css library. Good way to get off the ground quickly with the right structure.

`$ roots watch`: The bulk of roots' usefulness is here. This command compiles your project, opens it up in your browser, then continues watching all your files for changes. As soon as you save, roots will recompile the project and immediately refresh the browser. So fresh.

`$ roots compile`: Compiles your project once to the public folder, with everything minified and compressed.

`$ roots deploy project-name`: Compiles, compresses, and deploys your project to heroku as `project-name`. If you don't add a name, heroku will generate one automatically. This command depends on the heroku toolbelt - if you don't have it, the command will instruct you on how to install it. Coming soon, custom ftp server deploys

### Features

- super straightforward installation (does not rely on ruby)
- jade, stylus, and coffeescript default stack
- sprockets-style coffeescript requires
- custom super fast live reload implementation
- layouts - default and custom overrides
- partials (all locals automatically available)
- intuitive app settings file
- ignore files based on string or regex
- global variables and view helpers
- also supports ejs and straight html, css, and javascript
- simple to extend with a straightforward compiler and plugin interface
- one command deploys to heroku or a custom server
- coffeescript and markdown can be written directly into views
- minifies and compresses files and optimizes images on deploy

### CSS Library

CSS is a huge pain in the ass and we always end up doing the same shit over and over. Compass wasn't terse or magical enough for me, doesnt include UI components, and is too reliant on ruby, so I put together a css helper library. It's a lot like [nib](https://github.com/visionmedia/nib) except it's more thorough and actually has documentation. It's been living on its own for a number of months and is used in production on a number of high profile sites already. The CSS library will have received a full rewrite by the time roots is released, and should have a really sweet site with all sorts of interactive documentation.

### Love/Hate

Do you love and/or hate this? Maybe you even want to help, or suggest an improvement. Tell us all about it. Find my email and harass me or file an issue. <3

### Contributors

Everyone who has contributed to this project is the most awesome person ever. I want to give a huge thanks especially to these people

- Sam Saccone (@samccone), advice, support, and responsable for a lot of code