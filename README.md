nlpy
====

A collection of dotfiles and postinstall scripts.to setup a new Ubuntu GNOME
system as a data analysis/bioinformatics workstation.

`./bootstrap.sh` scripts is split into several functions:

* `setup_core` installs common build dependencies, openblas, samtools, bedtools,
    trimmomatic, julia, R, and updates GNOME to the latest available version from gnome3-staging ppa. 
* `setup_env` install python 3 data analysis/bioinformatics stack in a virtual
    environment. Numpy is compiled from source to make sure it uses `openblas`
    installed be `setup_core`
* `setup_i3` installs `i3` tiling window manager
* `setup_vim` installs `vim` with `vundle` to handle plugins and `YouCompleteMe`
    for autocompletion.

