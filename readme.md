# roots

roots is a fast, simple, and customizable static site compiler

[![npm](https://badge.fury.io/js/roots.png)](http://badge.fury.io/js/roots)
[![tests](https://travis-ci.org/jenius/roots.png?branch=master)](https://travis-ci.org/jenius/roots)
[![dependencies](https://david-dm.org/jenius/roots.png)](https://david-dm.org/jenius/roots)

### Why should you care?

If you make a lot of websites, or perhaps even make websites as a profession, there's no doubt that you will want to be very efficient at making websites, and on top of that you'll probably want to have the websites you make be very fast, cheap to host, and simple to build and optimize. If this is the case for you, my friend, you have come to the right place - roots is what you are looking for.

Roots is a tool for web developers to build static sites very quickly. Now, this doesn't mean that it's reserved only for websites without a server -- roots is also set up to be able to work very smoothly with client-side mv* frameworks like backbone or angular, and compliments them very well.

Roots is completely transparent, and is behind many large websites in production. It is sponsored heavily by [carrot creative](http://carrot.is), has been under active development for almost 2 years, and is very actively maintained and developed to this day. In short, you can rely on roots.

### Installation

`npm install roots -g`

### CLI Usage

coming soon...

### Public API

Roots v3 has been built from the ground up to have a strong javascript API, which is significantly different from all previous versions of roots. Let's jump right into it with an example:

```js
var Roots = require('roots');

project1 = new Roots('/path/to/project');
project1.compile()
  .on('error', console.error.bind(console))
  .on('compile', console.log.bind(console))
  .on('copy', console.log.bind(console))
  .on('done', console.log.bind(console))
```

As you can can see here, roots is initialized with a path pointing to the project root. You can also pass a second optional parameter specifying options for the project, which are [documented here](docs/configuration.md). It exposes one function, compile. When compile is run, roots emits a few events which can be seen above. `error` is emitted if there's any sort of error, `compile` and `copy` are emitted when files are compiled and/or copied respectively, and `done` is emitted when the project has finished compiling.

You can have multiple roots projects instantiated at once at a time without conflict, and you can compile a single roots project more than once at a time without conflict.

### License & Contributing

- Details on the license [can be found here](license.md)
- Details on running tests and contributing [can be found here](contributing.md)
- Details on how to get super rich from contributing to roots [can be found here](contributing.md#getting-money)
