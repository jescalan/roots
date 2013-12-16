Features
========

There are lots of other static compilers on the market. I'd like to explain why I continue working on roots depsite this, and eventually this document will also probably contain a feature comparison between a few of the more popular ones.

### Motivation

Roots is essential to my and my company's daily work. The work I do on my own is freelance, and the work I do at my company is very similar, which means that rather than working on a single project, I tend to move very quickly between a lot of different projects with a lot of different people. This means that I need a very strong and flexible system that is actively maintained with a clean and extensible codebase in order to be confident that any project can be handled.

In addition, when working on lots of web projects quickly, it becomes more and more important to wrap up common patterns and eliminate unnecessary time sinks. This often means writing on top of languages that compile down to html, having a wide range of compilers supported, and having those compilers be flexible to different options, a core piece of roots.

Finally, it's important to accomplish all these goals with the least amount of configuration code, and the most clear documentation possible. Often times other people will jump in and out of projects, and it's important that anyone is able to quickly get a handle on the code and get things up and running fast. Roots is the only system I am aware of that satisfies all these requirements.

### Important Features

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
