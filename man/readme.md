#Ronn

[Ronn](https://github.com/rtomayko/ronn) is how we hide from the hidious syntax that man pages are written with. In addition, it gives us an HTML page that we put on [roots.cx](http://roots.cx) install. So if you're gonna be editing the man page, install it:

```
gem install ronn -g
```

#Modifying and Merging

This is the process for making changes to the man:

- Add changes to roots.1.ronn, using the same formatting displayed.
- Run `ronn  --style toc man/roots.1.ronn`, which will compile `roots.1.html` and `roots.1`
- PR your changes into the main roots repo

Also, if you change the synopsis you should update `/lib/commands/help.js`. 

#Updating Roots.cx

We gotta keep the page on roots.cx sync, so use these steps to update it:

- Fork [roots.cx](https://github.com/jenius/roots.cx)
- Replace [roots.cx/views/docs/man.html](https://github.com/jenius/roots.cx/blob/master/views/docs/man.html) with a copy of `roots.1.html` (that you got from compiling with ronn in the last section)

