# roots

roots is a fast, simple, and customizable static site compiler

[![npm](https://badge.fury.io/js/roots.png)](http://badge.fury.io/js/roots)
[![tests](https://travis-ci.org/jenius/roots.png?branch=master)](https://travis-ci.org/jenius/roots)
[![dependencies](https://david-dm.org/jenius/roots.png)](https://david-dm.org/jenius/roots)

> **Note:** This project is in early development, and versioning is a little different. [Read this](http://markup.im/#q4_cRZ1Q) for more details.

### Dev To Do List

- multipass compiles
- dynamic content
- precompiled templates
- custom compilers
- another round of speed profiling

### Why should you care?

If you make a lot of websites, or perhaps even make websites as a profession, there's no doubt that you will want to be very efficient at making websites, and on top of that you'll probably want to have the websites you make be very fast, cheap to host, and simple to build and optimize. If this is the case for you, my friend, you have come to the right place - roots is what you are looking for.

Roots is a tool for web developers to build static sites very quickly. Now, this doesn't mean that it's reserved only for websites without a server -- roots is also set up to be able to work very smoothly with client-side mv* frameworks like backbone or angular, and compliments them very well.

Roots is completely transparent, and is behind many large websites in production. It is sponsored heavily by [carrot creative](http://carrot.is), has been under active development for almost 2 years, and is very actively maintained and developed to this day. In short, you can rely on roots.

Roots is certainly not the only static site compiler out there. Check out a [comparison to other available static compilers](docs/features.md).

### Installation

`npm install roots -g`

### CLI Usage

coming soon...

### Public API

Roots v3 has been built from the ground up to have a strong public API, which is significantly different from all previous versions of roots. Let's walk through it here.

#### Creating a new `Roots` instance

There are two ways you can create a new instance of the `Roots` class - first using the traditional constructor, which expects a path that contains a roots project, and second with the `Roots.new` class method. Let's take a look at both here.

First, let's look at the more traditional constructor:

```js
var Roots = require('roots'),
    path = require('path');

var project = new Roots(path.join(__dirname, 'example-project'));
```

As you can can see here, roots is initialized with a path pointing to the project root. You can also pass a second optional parameter specifying options for the project, which are [documented here](docs/configuration.md). Note that the path passed to the constructor *must already exist*, or roots will throw an error.

Now let's check out the `Roots.new` alternate constructor. This method takes a path to where you would like your project to be created, an optional template you want to use for it, and an optional callback which returns an initialized `Roots` instance for your newly created project.

Additionally, the `Roots.new` command is an event emitter, and you can listen for a number of events throughout the initialization process, as demonstrated below:

```js
var Roots = require('roots'),
    path = require('path');

var new_cmd = Roots.new({
  path: path.join(__dirname, 'example-project'),   // directory can not yet exist
  template: 'base',                                // optional - defaults to 'base'
  options: { description: 'foobar' }               // optional - options to pass to template
  done: function(project) { console.log(project) } // optional - returns Roots instance
});

new_cmd
  .on('template:base_added') // no templates present on system, added a base template
  .on('template:created')    // created the project template
  .on('deps:installing')     // found a package.json, ran `npm install`
  .on('deps:finished')       // finished installing deps
  .on('error')               // an error occurred, passes error
  .on('done')                // everything finished
```

Note that the path you pass to this constructor should not exist, a folder will be created there. If a folder already exists at that path, it will be filled with the files from the template, which probably is not what you want.

#### Compiling a Project

To compile a roots project once, you can use the `compile` method, which is fairly straightforward and returns the roots instance (which is an event emitter). Below is a quick example of loading in a roots project and compiling it:

```js
var Roots = require('roots');

project = new Roots('/path/to/project');
project.compile()
  .on('error')   // compile error
  .on('compile') // fires every time a file is compiled, passes file name
  .on('copy')    // fires every time a file is copied, passes file name
  .on('done')    // compile is finished
```

This is a fairly straightforward call -- as mentioned above, `compile` returns your instance so that you can chain your event emitter listeners directly onto it. The events are fairly self-explanitory.

#### Watching a Project

You can also watch through the public API, but beware -- while watching, there is currently no way to stop the process other than exiting it manually. It returns your instance like `compile` and you can listen for the same events:

```js
var Roots = require('roots');

project = new Roots('/path/to/project');
project.watch()
  .on('error')
  .on('compile')
  .on('copy')
  .on('done')
```

### License & Contributing

- Details on the license [can be found here](license.md)
- Details on running tests and contributing [can be found here](contributing.md)
- Details on how to get super rich from contributing to roots [can be found here](contributing.md#getting-money)
