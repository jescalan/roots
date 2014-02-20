Roots Config
============

You can configure roots through an optional `app.coffee` file at the root of your project. Although it is not required for simple projects, there are a lot of very powerful options you can take advantage of, which are explained below in the options section. But first, let's talk about the format of the file

### Format

`app.coffee` can come in two flavors. The first is more simple, just configured as a coffeescript object. For example:

```coffee
output: 'public'
env: 'development'
after: -> console.log('what a useful function')
```

This is a great way to format the file for maximum simplicity. It ends up being very clean and easy to manage. However, if you want to do more advanced things like `require`ing in files node/commonjs-style, you will not be able to do this. It is parsed simply as an object, not with full node functionality. If you do want full node functionality though, you're in luck -- all you have to do is add `module.exports =` to the top, like this.

```coffee
axis = module.require('axis-css')
autoprefixer = module.require('autoprefixer-stylus')

module.exports =

  output: 'public'

  stylus:
    use: [axis, autoprefixer]
```

As you can see, here we are able to locally require in extra dependencies and push them directly into the roots pipeline. Make sure if you are requiring locally to note the use of `module.require` - since this is loaded into roots' context, you'll need the `module` prefix in order to load your deps from the right place.

### Options

Below are all the options that you can pass to roots, from the simplest to the most advanced.

#### output
The path to a folder (starting from project root) that your project will be compiled into.
_default: `public`_

#### ignores
An array containing [minimatch](https://github.com/isaacs/minimatch) strings that represent files or folder you wish to ignore from the compile process. Full globstar syntax supported. Automatically ignores `package.json`, `node_modules`, `app.coffee` and your output directory (wouldn't want to have it recursively compile itself!)

#### dump_dirs
Array of directories that will have their contents dumped into the output folder rather than compiling into the folder they are in
_default: `['views', 'assets']`_

#### env
Basic environment variable. Usually set through command line options, but if you need you can override here.
_default: `development`_

#### debug
When enabled, commands will dump out lots of information on what roots is doing internally.
_default: `false`_

#### live_reload
When enabled, on `roots watch`, the browser will automatically reload every time you save a file in your project.
_default: `true`_

#### open_browser
When enabled, `roots watch` will automatically open a browser to the local server.
_default: `true`_

#### locals
An object that is injected into the options every compiler in use in the project. So for example, if you are using both jade and ejs in a project and some locals to be the same across the two, you don't have to duplicate, just add them to `locals`. If there is a conflict between `locals` and compiler-specific options, the compiler options will win out.

#### before
Hook function that is run before each compile. Function passes in an instance of the [roots class](../lib/index.coffee), so you have access to everything. Accepts either a single function or an array of functions, which will be run in order. Expects a promise or value to be returned from each function.

#### after
Same thing as before, but is run after each compile. Surprise surprise.

#### Coming Soon!
- layouts
- precompiled templates

### Compiler Options

You can also pass options directly to any compiler through app.coffee. Just add them as an object under the name of the compiler. For example, if you want jade to output non-compressed html:

```
jade:
  pretty: true
```

...that's all it takes. This will work for any compiler you have loaded. For more info on each supported compiler's options, see the [accord docs](https://github.com/jenius/accord/tree/master/docs).
