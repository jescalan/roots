Javascript API
===============

Roots v3 has been built from the ground up to have a strong js API, which is significantly different from all previous versions of roots. Let's walk through it here.

Creating a new `Roots` instance
-------------------------------

There are two ways you can create a new instance of the `Roots` class - first using the traditional constructor, which expects a path that contains a roots project, and second with the `Roots.new` class method. Let's take a look at both here.

First, let's look at the more traditional constructor:

.. code-block:: javascript

    var Roots = require('roots'),
        path = require('path');

    var project = new Roots(path.join(__dirname, 'example-project'));

As you can can see here, roots is initialized with a path pointing to the project root. You can also pass a second optional parameter specifying options for the project, which are `documented here <configuration.html>`_. Note that the path passed to the constructor *must already exist*, or roots will throw an error.

Now let's check out the ``Roots.new`` alternate constructor. This method takes a path to where you would like your project to be created, an optional template you want to use for it, and an optional callback which returns an initialized `Roots` instance for your newly created project.

Additionally, the ``Roots.new`` command is an event emitter, and you can listen for a number of events throughout the initialization process, as demonstrated below:

.. code-block:: javascript

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

Note that the path you pass to this constructor should not exist, a folder will be created there. If a folder already exists at that path, it will be filled with the files from the template, which probably is not what you want.

Compiling a Project
-------------------

To compile a roots project once, you can use the ``compile`` method, which is fairly straightforward and returns the roots instance (which is an event emitter). Below is a quick example of loading in a roots project and compiling it:

.. code-block:: javascript

    var Roots = require('roots');

    project = new Roots('/path/to/project');
    project.compile()
      .on('error')   // compile error
      .on('compile') // fires every time a file is compiled, passes file name
      .on('copy')    // fires every time a file is copied, passes file name
      .on('done')    // compile is finished

This is a fairly straightforward call -- as mentioned above, ``compile`` returns your instance so that you can chain your event emitter listeners directly onto it. The events are fairly self-explanitory.

Watching a Project
------------------

You can also watch through the public API, but beware -- while watching, there is currently no way to stop the process other than exiting it manually. It returns your instance like ``compile`` and you can listen for the same events:

.. code-block:: javascript

    var Roots = require('roots');

    project = new Roots('/path/to/project');
    project.watch()
      .on('error')
      .on('compile')
      .on('copy')
      .on('done')
