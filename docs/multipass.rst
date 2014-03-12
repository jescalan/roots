Multipass Compilation
=====================

Roots stands alone among static site compilers in its ability to handle **multipass compilation**, meaning that a single file can be compiled multiple times to determine the output. While not a common use-case for most builds, multipass compilation can be a very powerful tool for some advanced setups.

To compile a fiel for multiple languages, you can just **add another extension**. For example, if you wanted a file to be compiled in ejs then jade, you could call the file `example.jade.ejs`, and as long as both compilers are installed, it will work.

File Extension Logic
--------------------

Roots abides by a set of rules when processing and outputting file extensions. If you are confused about why a certain file has a certain extension after being compiled, this is probably the section you are looking for.

First, if a file has no extensions that are compiled at all, it is copied exactly to the output folder without being changed. The only time extensions are modified is when one or more of a file's extensions match to an installed and supported compiler. Roots uses `accord <https://github.com/jenius/accord>`_ for all compilation under the hood, and you can see the list of supported languages there.

If you have an extension that maps to an accord-supported compiler and that package has been installed through your ``package.json`` file, the file will be compiled. If the **first extension after the filename** is compiled, that compiler's output target will be the sole output extension for the file every time. For example, ``example.jade.foo.bar`` will always output ``example.html``, since ``jade`` is the first extension and ``.html`` is jade's output target. If you think about it, this makes sense, since the ``foo`` and ``bar`` extensions need to compile into a format that jade would be able to parse without error.

If the first extension after the filename is *not compiled*, it will take that extension no matter what. For example, if you had a file called ``example.html.coffee.ejs``, it would compiled to ``example.html`` every time, regardless of any compiled or non-compiled extensions following it. So the overall lesson to learn here is that **the first extension is the only one that matters when determining the output extension**.

It's worth noting that for roots, there's *no such thing as dots in filenames*. Since roots parses multiple extensions, if you put a dot in a filename, it's treated as an extension. Dots should not be in filenames anyway, but that's a separate debate. So for example if for some very strange reason, you had a file called ``example.min.coffee``, it would output ``example.min``, because ``.min`` is the first extension, and is not compiled. If this example concerns you, take note of two things. First, coffeescript doesn't output minified code, so having ``.min`` in the filename would technically be incorrect. You can always minify the file and modify the extension through a roots extension intended for concatenating and minifiying files. Second, if you have a ``whatever.min.js`` file in your project, it will output correctly because neither ``min`` or ``js`` are compiled, so the file and its extensions will just be copied.

Finally, if you have a ``.jade`` file in your project for example, but have not installed the ``jade`` package through your ``package.json`` file, it will be treated as a static file and copied with the ``.jade`` extension intact.

Adding Custom Compilers
-----------------------

Sometimes you might want to add in your own compiler, whether it's something you cooked up quickly for a specific purpose or something not yet supported by accord that you need immediately. If you want to do this, unfortunately, you can not at the moment because roots is still in beta and we haven't finished this feature yet. But it is in the pipeline before release, so this will change soon!
