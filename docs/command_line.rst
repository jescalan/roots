Command Line Interface
======================

For most users, the primary way to use roots will be through the command line. Although the public API mirrors the command line very closely, this piece will cover all the commands and options you can use on the command line. Also note that if you run any command with the `-h` short flag, it will display help text on how to correctly use that command and all the available options.

Also before we get started, let's clear up some terminology. A _positional_ argument is an argument that is simply typed out, without any sort of flag. For example:

    $ program /foo/bar

Here, you can see a program being run with one positional argument, and no flags at all. The positional argument here looks like a path, but it could be anything. There can also be more than one positional argument.

An _optional_ argument, also potentially known as a _flag argument_, looks more like this:

    $ program --foo bar

Here, the optional argument ``foo`` is set to ``bar``. Sometimes, the arguments have no value, it's just their presence that is needed, as such:

    $ program --foo

You can also call a program with both positional and optional arguments:

    $ program /foo/bar --baz

And finally, many optional arguments also have "short flag" versions, which use one dash instead of two and are a single letter. For example, ``--foo`` might be abbreviated also as ``-f``. With the basics out of the way, let's jump into the actual commands!

New
---

The ``new`` command creates a new roots project from a template.

**Alises**: _init_, _create_

**Positional**
- _path_: Path in which you'd like to create the project. Optional, defaults to current directory.

**Optional**
- _-t_, _--template_: Name of a template you'd like to create the project with. See ``roots template`` for more information.
- _-o_, _--overrides_: Information to pass directly to the template so that you are not prompted via the command line. Accepts a quoted comma-separated key-value list, like ``a: b, c: d``.

Watch
-----

The ``watch`` command compiles the project, opens it in a local server, then watches a project for changes to the code. When the code changes, the project is re-compiled and the browser window is reloaded.

**Positional**
- _path_: Path of the project you'd like to watch. Optional, defaults to current directory.

**Optional**
- _-e_, _--env_: Environment you'd like to run the project with. For more information on environments, see the `environments docs <environments.html>`_.
- _--no-open_: If this flag is present, the command will not open a browser when the initial compile is finished.

Compile
-------

The ``compile`` command compiles your project once to the output directory, which usually will be ``public`` unless you have changed it.

**Positional**
- _path_: Path of the project you'd like to compile. Optional, defaults to current directory.

**Optional**
- _-e_, _--env_: Environment you'd like to run the project with. For more information on environments, see the `environments docs <environments.html>`_.
- _-v_, _--verbose_: If this flag is present, the command will offer more verbose output on the compile task's status, such as individual file compiles and timing.

Template
--------

The template command allows you to interact with roots' templates for starting out new projects. This command is a simple wrapper over `sprout <https://github.com/carrot/sprout>`_. It also has it's own sub-commands listed below, so just running ``roots template`` won't do anything, you need to follow it with one of the below commands, like ``roots template list``, for example.

**Alias**: _tpl_

Template Add
------------

Adds a new template that you can use with the ``roots new`` command.

**Positional**
- _name_: What you'd like to name the template
- _uri_: A git-clone-able uri to the template

Template Remove
---------------

Removes a template that you have previously added.

**Positional**
- _name_: The template name you'd like to remove

Template Default
----------------

Makes a specified template the default to be used any time that ``roots new`` is run.

**Positional**
- _name_: The template name you'd like to make the default

Template List
-------------

Lists all the currently installed templates. No additonal arguments, you can run this on its own.

Clean
-----

Removes the compiled output from a given project.

**Positional**
- _path_: Path of the project you'd like to remove the output of. Optional, defaults to current directory.

Deploy
------

Compiles and deploys your compiled project to a static host. This is a wrapper for `ship <https://github.com/carrot/ship>`_. Running this command will prompt you for authentication details for the host you want to ship to and save these in a file called ``ship.conf`` at the root of your project. If it's a public project, make sure to gitignore this file before pushing!

**Positional**
- _path_: Path of the project you'd like to deploy. Optional, defaults to current directory.

**Optional**
- _-to_, _--to_: Which host you'd like to deploy the project to. Currently available hosts are ``s3``, ``heroku``, and ``gh-pages``, but check ship for more recent updates.

Analytics
---------

Enables or disabled roots' analytics. Analytics are anonymous, reveal no personal information, the data is public, and is only used to help the core developers to improve roots for you.

**Optional**
- _--disable_: Disable roots analytics.
- _--enable_: Enable roots analytics.
