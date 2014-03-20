Environments
============

Often times, you have different environments that your project can live in which require at least slightly different settings. For example, usually a development/local, staging, and production setup is good for most sites. Roots supports environments by allowing different `app.coffee` files to be used for different environments.

Environment-Specific App.coffee
-------------------------------

To make a new `app.coffee` file that's scoped to a specific environment, just add another extension before the `.coffee` that represents the name of the environment. For example, for a production config file, you could call it::

    app.production.coffee

You can have as many environment specific ``app.coffee`` files as you want, and can call the environments whatever you want. In all cases, they will be ignored from the compilation process.

Compiling With an Environment
-----------------------------

To compile with an environment, you can pass an ``--env`` or ``-e`` flag to the ``watch`` or ``compile`` commands on the command line with the name of your environment, as such::

    roots compile -e production

If you are using the javascript api, you can pass an ``env`` option to the ``Roots`` constructor as such:

.. code-block:: javascript
  
  var Roots = require('roots');
  var project = new Roots(__dirname, { env: 'production' })

Again, you can use any word you want for the environment, ``production`` is just used here as an example. If you cause roots to compile with an environment, but no environment-specific ``app.coffee`` file is found, it will print a warning.
