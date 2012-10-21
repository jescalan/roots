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

`$ roots update`: Upgrades roots to the latest version.

### Features

- super straightforward installation (does not rely on ruby)
- jade, stylus, and coffeescript default stack
- sprockets-style coffeescript requires
- custom super fast live reload implementation
- compile errors reported as a flash message, doesn't break workflow
- layouts - default and custom overrides
- partials (all locals automatically available)
- intuitive app settings file
- ignore files based on string or regex
- global variables and view helpers
- also supports ejs and straight html, css, and javascript
- one command deploys to heroku or a custom server (via ftp)
- coffeescript and markdown can be written directly into views
- minifies and compresses files and optimizes images on deploy
- efficient javascript package management via bower and require.js
- easy to extend with a well-documented and simple plugin interface

### CSS Library

CSS is a huge pain in the ass and we always end up doing the same shit over and over. Compass wasn't terse or magical enough for me, doesnt include UI components, and is too reliant on ruby, so I put together a css helper library. It's a lot like [nib](https://github.com/visionmedia/nib) except it's more thorough and actually has documentation. It's been living on its own for a number of months and is used in production on a number of high profile sites already. The CSS library will have received a full rewrite by the time roots is released, and should have a really sweet site with all sorts of interactive documentation.

The css library is very modular in its construction, and higher level mixins can easily be broken down into their components and customized as is necessary.

### Plugins

It's pretty straightforward to add a plugin to customize roots' functionality. Plugins need only be one file, and can be as short as three lines (many of the core compilers are, actually). To create a plugin, just drop a new file, javascript of coffeescript, into `vendor/plugins` that exports "file_type", a string with the file type you are aiming to compile, and a  "compile" method. The compile method is a function. The function takes two parameters, a helper and a file. The helper can be invoked inside the compiler by passing the file to it, and acts as an interface to a bunch of useful variables and methods that can be used to get the compile done very quickly and cleanly.

    // create a new helper by instantiating it with a file as such
    var helper = new CompileHelper(file)

    // the helper object will export the following variables
    helper.file_path
    helper.file_content
    helper.extension

    // and if your file compiles to html, it will also have
    helper.layout_path
    helper.layout_content

    // the helper also exports these methods
    helper.locals(extra)
      // => returns all locals, if you pass it one, it will add it to the locals object
      //    (this is useful particularly for handling layouts)
    helper.write(content)
      // => writes the content it's passed to the appropriate file in public/

    // note about sample compilers to get an idea of how it's done

Plugins can be manually installed into vendor/plugins or directly pulled from a github repo using a command like `roots plugin install jenius/roots-sass`, the final parameter being `github-username/repo-name`. If you'd like to write a plugin, the command `roots plugin generate` will create a nice starting template inside vendor/plugins. All known plugins will be listed on the roots website [link].

### Client Side JS

Using javascript libraries on the client-side is super helpful, but downloading them for every project and keeping them up to date is a huge pain. The wonderful folks at twitter created [bower](#) to make life easier for us as far as javascript client-side package management. You can run `roots install` followed by any package name to have bower install it directly into the vendor folder of your roots project. Also available:

`roots js list`
`roots js search`
`roots js update package-name`

There are a lot of great open-source packages registered with bower. Check them out [here](http://sindresorhus.com/bower-components/). But don't ever use bootstrap, or I will cry. Root's css library ships with nicely designed defaults if you are trying to make a good-looking wireframe or back end (just run `framework()` in your main stylus file), and if you are working on a production site, get a designer to help, or shame on you.

Although not required, it's highly recommended that you also use [require.js](http://requirejs.org) to load your client-side javascript dependencies smoothly. This functionality is already built in if you generate your project with `roots new`, and includes instruction on how to use require.js's system. The require.js site is well stuctured and has great docs if you are looking for more information.

### Ambition

I'm very excited about this project, because it makes my life a ton easier and it saves me and my employer many hours. Once the static site compiler is finished and tested, I plan on porting the system first to node (with express), then to rails (likely a gem for rails 4). Life without useful tools like the roots css library, bower, require, live reloading, nice templating langiages, and single-command deploys just seems sad to me, and makes everything take longer. If you are interested in helping out with this project or the rails or node ports, get in touch. I'd love to have you on board.

##### To Do

- build and test plugins
- custom range local for repeated content
- implement bower
- install script
- deploy to npm
- roots update task
- think about tumblr theming plugin
- error messages to flash in views
- implement image optimization

### Love/Hate

Do you love and/or hate this? Maybe you even want to help, or suggest an improvement. Tell us all about it. Find my email and harass me or file an issue. <3

### Contributors

Everyone who has contributed to this project is the most awesome person ever. I want to give a huge thanks especially to these people

- Sam Saccone (@samccone), advice, support, and responsable for a lot of code