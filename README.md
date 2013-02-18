# goblint-quickinstall

QuickInstall script for Goblint Analyzer (includes OPAM QuickInstall).

## What is required?

* [OCaml](http://ocaml.org/) >= 4.00.1
* [Git](http://git-scm.com/)
* [GNU Bash](http://www.gnu.org/software/bash/) >= 3 (?)

## What is installed/fetched?

* [OPAM](http://opam.ocamlpro.com/)
* [findlib](http://projects.camlcity.org/projects/findlib.html) 1.3.3
* [camomile](http://camomile.sourceforge.net/) 0.8.3
* [batteries](http://batteries.forge.ocamlcore.org/) 1.5.0
* [CIL](http://kerneis.github.com/cil/) 1.5.1
* [xml-light](http://tech.motion-twin.com/xmllight.html) 2.2
* [Goblint](https://github.com/goblint/analyzer)

## QuickInstall

### OPAM + Goblint
```
curl https://raw.github.com/xsc/goblint-quickinstall/master/quick-install.sh > install.sh && bash install.sh goblint
```
This will download the QuickInstall script and install OPAM system-wide (will prompt for superuser privileges) and Goblint into the subdirectory ```goblint``` using the latest commit in the [Goblint Repository](https://github.com/goblint/analyzer).

### Only OPAM
```
curl https://raw.github.com/xsc/goblint-quickinstall/master/quick-install.sh > install.sh && bash install.sh --opam-only
```

### Full Goblint Checkout
```
curl https://raw.github.com/xsc/goblint-quickinstall/master/quick-install.sh > install.sh && bash install.sh --full-clone goblint
```
This will create a full clone of the Goblint Repository in the ```goblint``` subdirectory. 
(OPAM will be installed, too).

## License

Copyright &copy; 2013 Yannick Scherer

Distributed under the Eclipse Public License.
