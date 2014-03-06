Errors
======

Unfortunately, errors happen. If one does occur, it might be our fault and it might be your fault. When roots throws an error that we have recognized is possible, we try to throw it with as clear and human-readable an error message as possible to make it easy to see where things went downhill. Documented here are all the error codes that roots can throw. It's certainly possible that there's an error that doesn't match any of these, if so please file an issue!

The numbers you see here are unix error codes. They start at `125` because this is where the `standard error codes end <http://www-numi.fnal.gov/offline_software/srt_public_context/WebDocs/Errors/unix_system_errors.html>`_. If you are using roots programatically, expect for the program to exit with the same code as is documented here.

125 - Malformed Extension
-------------------------

This error means that you fed roots an `extension <docs/extensions.md>`_ of the incorrect type. To fix this, check through your extensions and make sure that they all are correctly formatted according to the roots extension spec.
