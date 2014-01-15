_ = require 'lodash'

class Extensions

  constructor: (@roots) ->
    @all = []

  register: (ext, priority) ->
    if typeof priority == undefined then return @all.push(ext)
    @all.splice(priority, 0, ext)

  remove: (name) ->
    _.remove(@all, ((i) -> i.name == name))

module.exports = Extensions

###

Roots Extensions
----------------

The roots extension API is an extremely powerful managed set of hooks into roots' internals that allow external packages to customize roots' behavior. This class is responsible for the management of extensions in a roots project.

Extensions can expose hooks that link into a 4 different spots in the roots compile pipeline, detailed more thoroughly below.

## FS Parse Hooks

The first step in the roots compile pipeline is parsing the project directory and categorizing files. By default, roots splits all files into two categories: compiled and copied. By hooking into the fs parser, an extension can filter files into its own category. FS parse hooks can come in three pieces:

- detection function & category name
- extract or pass through
- detect before or after the default (compile/copy) categories

## Compile Order Hook

After parsing the project, roots takes each category and runs the files through the compiler. In this hook, you can choose whether you need for your category to be compiled before or after the default compile tasks. For example, the dynamic content extension requires that dynamic content files be compiled before normal content so that the dynamic content can be available in the locals. If no before/after is chosen, it will be compiled in parallel with the other tasks.

## Compile Hooks

You might want to also jump directly into the compile process, and these two hooks make this possible. The roots compiler first grabs a list of compilers that need to be used to compile the file, and the options that need to be passed into the compiler. Next, roots goes through the list and compiles the file once for each compiler, passing the content of the previous compiler on to the next pass. You can activate hooks right before and right after this compile has finished. In the before hook, you can add, remove, or swap compile adapters, or options before the compile goes off, and in the after hook, you can modify the compiled content before passing it to be written, or prevent the write.

## Category Hooks

As mentioned above, by hooking into the fs parser, you are able to sort files into your own category. Sometimes you want to be able to have a hook when a specified category has finished compiling all of its files. An extension that precompiles files and writes all the contents to a single `templates` file would want to store the contents, then write them all once that category is finished compiling through. Thats what this hook is for.

###
