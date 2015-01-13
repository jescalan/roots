Errors
======

Unfortunately, errors happen. If one does occur, it might be our fault and it might be your fault. When roots throws an error that we have recognized is possible, we try to throw it with as clear and human-readable an error message as possible to make it easy to see where things went downhill. Documented here are all the error codes that roots can throw. It's certainly possible that there's an error that doesn't match any of these, if so please file an issue!

The numbers you see here are unix error codes. They start at `125` because this is where the `standard error codes end <http://www-numi.fnal.gov/offline_software/srt_public_context/WebDocs/Errors/unix_system_errors.html>`_. If you are using roots programatically, expect for the program to exit with the same code as is documented here.

125 - Malformed Extension
-------------------------

This error means that you fed roots an `extension <extensions.html>`_ of the incorrect type. To fix this, check the specific error message that roots gave you, read through the extension docs linked above, and make sure that everything is formatted correctly. If you are having trouble writing an extension, feel free to drop in to the `roots support channel <http://gitter.im/jenius/roots>`_

126 - Malformed Write Hook Output
---------------------------------

This error means that your extension's `write hook <extensions.html#write-hook>`_ returned incorrectly formatted output. See the docs for write hooks (linked above) for more details on how to correct this.

EMFILE, too many open files
----------------------------------

This occurs when roots hits the maximum limit of open files on a UNIX system (more specifically the number file descriptors that can be assigned). Unfortunately, the default value on most Mac OS X machines is ``1024``, and a large roots project can easily exceed this value. In order to fix the issue, run:

``$ ulimit -n <NEW_LIMIT>``

For example, ``ulimit -n 10000`` will raise the open file limit to 10000. For more information, check out Isaac Schlueter's `blog post <http://blog.izs.me/post/56827866110/wtf-is-emfile-and-why-does-it-happen-to-me>`_ on the topic.
