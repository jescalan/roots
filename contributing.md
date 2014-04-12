Contributing to Roots
---------------------

Hello there! First of all, thanks for being interested in roots and helping out. We all think you are awesome, and by contributing to open source projects, you are making the world a better place. That being said, there are a few ways to make the process of contributing code to roots smoother, detailed below:

### Filing Issues

If you are opening an issue about a bug, make sure that you include clear steps for how we can reproduce the problem. If we can't reproduce it, we can't fix it. If you are suggesting a feature, make sure your explanation is clear and detailed.

### Contributing

We've tried to make the roots codebase as clean and easy to understand as possible, but when it comes down to it, roots is a _very complex project_ and may take a good bit of time to grok the code if you're trying to jump in. The fact that you can be compiling multiple times at once with multiple projects at once, on multiple files at once, with multiple compile passes on each file, and no errors, slowness, or overflows should occur in the situation makes for a codebase that can be really challenging to fully understand.

That being said, we've made sure to _very thoroughly document_ every single function and class in the codebase, not only for contributors and potential contributors, but so that we are able to quickly get a handle on what's going on in any part of the code. This means that in each file, there can easily be more comments than code, which can make it difficult to scan through if you are just reading code and not after all the docs (yet). If this is the case, you should install a plugin that will fold the comments, such as [FoldComments for Sublime Text](https://github.com/hasclass/FoldComments). This way, you can hit a keystroke to quickly expand and contract the large comment blocks and either look at the much more compact code pieces or read through the comments/docs.

### Testing

Roots is constantly evolving, and to ensure that things are secure and working for everyone, we need to have tests. If you are adding a new feature, please make sure to add a test for it.

Please also ensure that any new lines you add are _fully covered_ by tests. Of course, this does not mean there will be no bugs, but it certainly makes it less likely. To test the code coverage, you can run `npm run coverage`.

### Code Style

To keep a consistant coding style in the project, we're going with [Felix's Node.js Style Guide](http://nodeguide.com/style.html) for JS and [Polar Mobile's guide](https://github.com/polarmobile/coffeescript-style-guide) for CoffeeScript, but it should be noted that much of this project uses under_scores rather than camelCase for naming. Both of these are pretty standard guides. For documenting in the code, we're using [JSDoc](http://usejsdoc.org/).

### Commit Cleanliness

It's ok if you start out with a bunch of experimentation and your commit log isn't totally clean, but before any pull requests are accepted, we like to have a nice clean commit log. That means [well-written and clear commit messages](http://tbaggery.com/2008/04/19/a-note-about-git-commit-messages.html) and commits that each do something significant, rather than being typo or bug fixes.

If you submit a pull request that doesn't have a clean commit log, we will ask you to clean it up before we accept. This means being familiar with rebasing - if you are not, [this guide](https://help.github.com/articles/interactive-rebase) by github should help you to get started, and feel free to ask us anything, we are happy to help.

### Getting Money

We are kind and generous here at roots HQ, and would love to thank anyone who makes a contribution to roots. We therefore have pledged to send 100 - 500 [dogecoins](http://dogecoin.com/) per merged pull request to any contributors. Please note that dogecoin is estimated to reach a value of $100<sup>[citation needed]</sup>, so that means you'll theoretically be recieving between $10,000 and $50,000 per successful PR. There is no limit to how many pull requests you can claim a bounty on, so more contributions == more money. Documentation of you making it rain with your newfound riches is always appreciated.

To claim the bounty, just leave your dogecoin wallet address in a comment on the closed PR.
