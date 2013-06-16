Testing roots
-------------

Let it be known that I am notoriously terrible at writing tests, but am working hard to get better at this. That being said, there is a basic test suite in place that covers most of the important functions of roots. If you're planning on contributing, it would be great if you'd make sure the tests are still passing.

The tests are written in mocha and coffeescript, and can be run with:

```
npm test
```

The timeout is set to 5000ms (in `tests/mocha.opts`) because the compile process can take a bit, and since roots is a command line tool, it is tested through child processes that run it on the command line.
