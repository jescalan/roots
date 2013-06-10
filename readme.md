# Roots

A light, super fast, and intuitive build system meant for rapid advanced front end development.

[![Build Status](https://travis-ci.org/jenius/roots.png?branch=master)](https://travis-ci.org/jenius/roots)
[![Dependency Status](https://david-dm.org/jenius/roots.png)](https://david-dm.org/jenius/roots)

Installation
------------

Make sure you have [node.js](http://nodejs.org/) installed, then just run `npm install roots -g` and you'll be all set.

Usage
-----

Roots' main interface is it's command line tool. There are just a couple of main commands that do more or less what you would expect.

`$ roots new project-name`: Creates a new project template in the current directory, called `project-name`. 
  - append `--basic` for straight html, css, and js
  - append `--express` for an express app template with roots integrated
  - append `--blog` for a sample of how dynamic content works
  - append `--min` for a template for roots veterans (no comments, jade layouts)
  - To use roots with rails, use the [roots-rails](http://github.com/jenius/roots-rails) ruby gem instead.

`$ roots watch`: The bulk of roots' usefulness is here. This command compiles your project, opens it up in your browser, then continues watching all your files for changes. As soon as you save, roots will recompile the project and immediately refresh the browser. So fresh. 
You can manually set the port roots will run on using the `PORT` environment variable if you want. For example, `$ PORT=3000 roots watch` would run the app on port 3000.

`$ roots compile`: Compiles your project once to the public folder, with everything minified and compressed.

`$ roots deploy project-name`: Compiles, compresses, and deploys your project to heroku as `project-name`. If you don't add a name, heroku will generate one automatically. This command depends on the heroku toolbelt - if you don't have it, the command will instruct you on how to install it.
  - append `--nodejitsu` to deploy through nodejitsu
  - append `--ftp` to deploy via ftp. A [ftp config file](#) is also required (coming soon).

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
- automatically precompiles jade templates for use in client-side MVCs like backbone
- use dynamic content to create collections, blogs, etc.
- compile a single file multiple times by adding another extension

Axis CSS
-----------

Roots ships with an awesome feature-rich css library built on top of stylus. This library lives [in it's own repo](http://github.com/jenius/axis), and the documentation for it [can be found here](http://roots.cx/axis).

Client Side JS
--------------

Using javascript libraries on the client-side is super helpful, but downloading them for every project and keeping them up to date is a huge pain. Luckily, the wonderful developers at twitter created [bower](http://twitter.github.com/bower/) for this exact purpose. You can run `roots install` followed by any package name to have bower install it directly into the `assets/components` folder of your roots project. Also available:

`roots js list` - list of installed packages    
`roots js search name` - search for a package by `name`    
`roots js update name` - update `name` to the latest version    
`roots js uninstall name` - remove `name`    
`roots js info name` - get more info about `name`    

There are a lot of great open-source packages registered with bower. Check them out [here](http://sindresorhus.com/bower-components/). In addition, [require.js](http://requirejs.org) is included by default to help load your client-side javascript dependencies smoothly.

Plugins
-------

Roots can easily be extended with new compilers on a per-project basis. See the [documentation for plugins](http://roots.cx/docs#plugins) for more info.

Precompiled Templates
---------------------

Roots can precompile specific templates and make them available in your views. This can be super convenient if you are loading content onto your page using javascript, making your markup much cleaner and easier to manage. Note that this is brand new functionality, so if you are having any issues please let me know, but in my testing and personal usage, it's been quite solid. Here's how to make it happen:

- In your `app.coffee` file, you should see a commented out line setting `exports.templates` to a path. Uncomment this line, set the path to whatever you'd like, and create a folder at that path.

- Put a jade file inside that folder. This will be your template, so create it as you'd like.

- When you compile your project, it will create a file called `templates.js` inside your `js` folder. Load this file on to your page either directly or using require.js.

- You should now have access to a global variable called `templates` -- this is an object that holds each of your precompiled templates as javascript functions. The key will be the filename, and the value will be a function that when executed will generate html. If you have any variables in the template, execute the function passing in a single object that holds the variable names and values.

- If this is confusing, check out [this tutorial video](http://www.youtube.com/watch?v=_lPLVd0UsdI)

Dynamic Content
---------------

In roots, you can work with dynamic content much like jekyll, but a little cleaner and more flexible. The addition of dynamic content to roots makes it suitable for any website that doesn't need user accounts and logins. I think this is awesome because it widens the breadth of projects which you can create as a static site. And static sites are awesome because they are simple and fast as hell. Here's a short walkthrough of how to use dynamic content - I'll use a blog as an example:

- Create a folder at the root of the project called the name of your collection. Since I'm making a blog here, I'm going to call it "posts".

- Inside this folder, create a new jade file and name it whatever you want. This is your first blog post, whoo :tada:

- Dynamic files are defined by [yaml front matter](https://github.com/mojombo/jekyll/wiki/YAML-Front-Matter), exactly like jekyll. To make this file dynamic, add a front matter block, like this for example:

```yaml
---    
title: hello world    
date: 7/9/2013    
---    
```

- Below the front matter, use the full power of jade to write whatever html will be the body of your post. A great way to do this is to immediately throw down a markdown filter and just type out your post.

- Now if you were running `watch`, restart the server. When you add new dynamic content, I haven't made it so that it's dynamically loaded yet, so you'll need a quick restart.

- In your views, you will now have access to a variable called `site`. Inside of site will be stored any dynamic categories you have along with all their posts. So to access your blog posts, loop through `site.posts` (name of the folder sets the key).

- Each piece of dynamic content will be an object that contains all the key/value pairs from your yaml front matter as well as one additional key -- `content` -- which holds everything below the front matter.

- If you run `roots new whatever --blog`, I have a template set up that already has all the boilerplate set up, if you want to test it real quick.

- See the [docs for dynamic content](http://roots.cx/docs#dynamic) for more help!

Multipass Compiles
------------------

Want to compile a a single file for two different languages? No worries, just add a second (or third) extension to the file. As long as the two language parsers don't conflict, it will compile out cleanly. Feel free to write a [plugin](http://roots.cx/docs#plugins) to handle any other language you please.

The Future
----------

See the [issues](https://github.com/jenius/roots/issues) for discussion of upcoming features!

Contributors
------------

I would love to have more contributors, and if you've helped out, you are awesome. I want to give a huge thanks especially to these people:

- [Sam Saccone](https://github.com/samccone): trolling, support, and responsible for a good bit of code
- [Sean Lang](https://github.com/slang800): great suggestions, frequent pull requests, essentially a genius
- [Everyone else](https://github.com/jenius/roots/contributors): because I <3 you guys

License (MIT)
-------------

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
