Features
========

There are lots of other static site generators. This page will attempt to explain what keeps us working hard on roots.

Motivation
----------

Roots is essential to my and my company's daily work. The work I do on my own is freelance, and the work I do at my company is very similar, which means that rather than working on a single project, I tend to move very quickly between a lot of different projects with a lot of different people. This means that I need a very strong and flexible system that is actively maintained with a clean and extensible codebase in order to be confident that any project can be handled.

In addition, when working on lots of web projects quickly, it becomes more and more important to wrap up common patterns and eliminate unnecessary time sinks. This often means writing on top of languages that compile down to html, having a wide range of compilers supported, and having those compilers be flexible to different options, a core piece of roots.

Finally, it's important to accomplish all these goals with the least amount of configuration code, and the most clear documentation possible. Often times other people will jump in and out of projects, and it's important that anyone is able to quickly get a handle on the code and get things up and running fast. Roots is the only system I am aware of that satisfies all these requirements.

Feature List
------------

- speed
- custom compiler options
- before/after hooks
- precompiled templates
- dynamic content
- new project templating
- simple deployment
- client-side javascript management
- multipass compilation
- live reload in browser
- clean and clear error handling

Comparisons
-----------

There are boatloads of other static site genrators out there, and here we'll analyze a couple of them briefly, what they are best for, and how they compare to Roots.

* **DocPad**: Powerful, but complex interface for users and developers. Roots has the same power, and is complex for developers, but simple for users.
* **Grunt**: General purpose build tool that has everything you need, but a very ugly interface and everything needs to be wired together manually. Roots has a very slim and clean interface and comes pre-wired specifically for building websites.
* **Jekyll**: Very blog-specific, slower because ruby, very difficult to extend with different languages, plugins and workflows. Roots is significantly faster, more flexible with the type of site you can build, and more extensible.
* **Octopress**: Very similar to jekyll, except even more specific to blogs. Again, Roots is a lot more flexible in this regard.
* **Middleman**: Really an excellent and full-features static generator if you are into ruby. Roots' only advantage here is speed, works better with js languages, and multipass compiles.
* **Wintersmith**: Complex interface for users and developers - users are required to shape and interace directly with the file/parse tree. Roots insulates users from this and exposes a much simpler interface.
* **Metalsmith**: Much like grunt or gulp, this is a build tool that can be configured to make static sites. Roots is a tool specifically for building static sites, and comes with a bunch of extra features and conveniences.
* **Hexo**: Blog-specific. Roots is more flexible than this.
* **Stasis**: Little known fact -- the first version of roots was actually just stasis with some css libraries. I love stasis, but eventually outgrew it's limited feature set. It also appears to be unmaintained now.
* **Nanoc**: TODO
* **Pelican**: TODO
* **Harp**: TODO
* **Punch**: TODO
* **Brunch**: TODO

In my very humble opinion, the strongest alternatives to roots are, in order, **Middleman**, **Brunch**, **Docpad**, and **Metalsmith**. That is for some reason if you have spent all this time here and ended up deciding that you actually don't like Roots.
