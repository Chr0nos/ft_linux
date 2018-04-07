# What is it ?
the very begining of my own package manager,
for now it dosent support dependencies and the packages have to been installed
in the right order.

# dependencies
you need to have wget installed

# usage
> sh pkg.sh <package to install>

# packages
the builds scripts are in ebuild directory

# install xorg ?
yes, this is the main purpose of this script, just do:

> sh pkg.sh xorg-install

this is a meta package with the good order of dependencies.
