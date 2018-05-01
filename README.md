Android Open Source Project Docker Build Environment
====================================================

Minimal build environment for AOSP with handy automation wrapper scripts.

Developers can use the Docker image to build directly while running the
distribution of choice, without having to worry about breaking the AOSP build
due to package updates as is sometimes common on rolling distributions like
Arch Linux.

Production build servers and integration test servers should also use the same
Docker image and environment. This eliminate most surprises in breakages by
by empowering developers and production builds to use the exact same
environment.  The hope is that breakages will be caught earlier by the devs.

This only works (well) on Linux.  Running this via `boot2docker` will result in
a very painful performacne hit due to VirtualBox's `vboxsf` shared folder
service which works terrible for **very** large builds like AOSP.  It might
work, but consider youself warned.  If you're aware of another way to get
around this, send a pull request!

For *Mac OS X* and *Windows* users, consider
[kylemanna/vagrant-aosp](https://github.com/kylemanna/vagrant-aosp) as a good
virtual machine to enable development.


Quickstart
----------
[how to build aosp 4.x?](README-4.x.md)

How it Works
------------

The Dockerfile contains the minimal packages necessary to build Android based
on the main Ubuntu base image.

The `aosp` wrapper is a simple wrapper to simplify invocation of the Docker
image.  The wrapper ensures that a volume mount is accessible and has valid
permissions for the `aosp` user in the Docker image (this unfortunately
requires sudo).  It also forwards an ssh-agent in to the Docker container
so that private git repositories can be accessed if needed.

The intention is to use `aosp` to prefix all commands one would run in the
Docker container.  For example to run `repo sync` in the Docker container:

    aosp repo sync -j2

The `aosp` wrapper doesn't work well with setting up environments, but with
some bash magic, this can be side stepped with short little scripts.  See
`tests/build-kitkat.sh` for an example of a complete fetch and build of AOSP.


Tested
------

* Android Kitkat `android-4.4.4_r1`
