# Extract IPK from already installed package

This repository provides a script to create an IPK file from an already installed package.

## Usage

````
./extract-ipk <package>
````

This will create a file named `<package>.ipk` in current working directory.

The IPK contains all files related to the package as well as all necessary pre- and post scripts to install or remove it.

## Background

Lately, I noticed that OPKG preserves all files and information to extract an IPK file from an already installed package.
I was't sure whether this will work, so I played around a bit. The result works very well for the  packages I tried.

## Caveats

Some uses cases will not work with the script in its current form:
- empty directories will get lost
- some meta data will get lost (depending on your OPKG configuration)
- special files (e.g. dev nodes) may get lost (unless they are created in preinst or postinst scripts)
- OPKG info path is hard coded to `/var/lib/opkg/info`

