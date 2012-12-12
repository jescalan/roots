# Roots CLI

A light, super fast, and intuitive build system meant for rapid advanced front end development.

Installation
------------

Make sure you have [node.js](http://nodejs.org/) installed, then just run `npm install roots -g` and you'll be all set. Or run this script from your terminal: `curl get.roots.cx | sh`.

Usage
-----

Roots' main interface is it's command line tool. There are just a couple of main commands that do more or less what you would expect.

`$ roots new project-name`: Creates a new project template in the current directory, called `project-name`. 
  - append `--basic` for straight html, css, and js
  - append `--express` for an express app template with roots integrated
  - To use roots with rails, use the [roots-rails](http://github.com/jenius/roots-rails) ruby gem instead.

`$ roots watch`: The bulk of roots' usefulness is here. This command compiles your project, opens it up in your browser, then continues watching all your files for changes. As soon as you save, roots will recompile the project and immediately refresh the browser. So fresh.

`$ roots compile`: Compiles your project once to the public folder, with everything minified and compressed.

`$ roots deploy project-name`: Compiles, compresses, and deploys your project to heroku as `project-name`. If you don't add a name, heroku will generate one automatically. This command depends on the heroku toolbelt - if you don't have it, the command will instruct you on how to install it. Coming soon, custom ftp server deploys!

`$ roots update`: Upgrades roots to the latest version.

Features
--------

- extremely simple [installation](#installation)
- clean and minimal default project template
- [jade](http://jade-lang.com/), [stylus](http://learnboost.github.com/stylus/), and [coffeescript](http://coffeescript.org/) default stack
- super fast live reload implementation
- compile errors displayed as a flash message, doesn’t break workflow
- layouts and partials fully supported
- [coffeescript](http://coffeescript.org/) and [markdown](http://daringfireball.net/projects/markdown/) can be written directly in views
- extremely robust, modular, and powerful [css helper library](/css) built in
- global variables and functions (view helpers)
- clean and intuitive app settings file
- single command deploy to heroku
- intelligently minifies html, css, and js on deploy
- efficient client-side js management through [bower](http://twitter.github.com/bower/) and [require.js](http://requirejs.org/)
- easy to extend with a simple and well-documented plugin interface

CSS Library
-----------

Roots ships with an awesome feature-rich css library built on top of stylus. This library lives [in it's own repo](http://github.com/jenius/roots-css), and the documentation for it [can be found here](http://roots.cx/css).

Client Side JS
--------------

Using javascript libraries on the client-side is super helpful, but downloading them for every project and keeping them up to date is a huge pain. Luckily, the wonderful developers at twitter created [bower](http://twitter.github.com/bower/) for this exact purpose. You can run `roots install` followed by any package name to have bower install it directly into the `js/components` folder of your roots project. Also available:

`roots js list` - list of installed packages    
`roots js search name` - search for a package by `name`    
`roots js update name` - update `name` to the latest version    
`roots js uninstall name` - remove `name`    
`roots js info name` - get more info about `name`    

There are a lot of great open-source packages registered with bower. Check them out [here](http://sindresorhus.com/bower-components/). In addition, [require.js](http://requirejs.org) is included by default to help load your client-side javascript dependencies smoothly.

Plugins
-------

Roots can easily be extended with new compilers on a per-project basis. See the [documentation for plugins](http://roots.cx#plugins) for more info.

The Future
----------

Let it be known that this is my first large project with node.js - I'm no expert. I definitely still have plenty to learn, and if you have any advice about how to improve the code or structure of this project, it is more than welcome - feel free to [email me](http://jenius.me/#!/contact), put in a pull request, or file an issue and I'd be happy to take a look : )

One thing that I'm particularly bad at is testing. I'll be working hard on this in the coming months, but if anyone would like to help out with testing particularly, that would be incredible. Below, I keep track of what's on my list to implement next.

##### To Do

- add `roots -v` and `roots --version`
- add railway.js template
- deploy to custom ftp server (difficult)
- image optimization (this has external dependencies... yech)
- better testing

Contributors
------------

Everyone who has contributed to this project is the most awesome person ever. I want to give a huge thanks especially to these people:

- [Sam Saccone](https://github.com/samccone): advice, support, and responsable for a good bit of code

License
-------

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.