Roots Man Page
--------------

- Install [ronn](https://github.com/rtomayko/ronn) with `gem install ronn -g`
- Run `ronn man/roots.1.ronn` to regenerate


### Modifying and merging

NOTE: fork [roots.cx](https://github.com/jenius/roots.cx) prior to completing the following steps.

- Add changes to roots.1.ronn, using the same formatting displayed.
- run ```ronn man/roots.1.ronn``` which will compile the roots.1.html
- copy & paste this over to your [roots.cx/views/docs](https://github.com/jenius/roots.cx/tree/master/views/docs) fork
- Remove ```man.html``` and rename your pasted version to ```man.html```
