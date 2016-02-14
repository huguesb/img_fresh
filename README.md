img\_fresh
==========

A simple script to avoid redundant builds of docker images.


Why ?
-----

Sometimes the docker cache just isn't enough:

 - The entire build context, which may include large assets, is uploaded to the
   docker daemon even if all layers are cache hits.
 - Non-standard build process where containers build other containers, such as
   [gockerize](https://github.com/aerofs/gockerize), cannot easily take advantage
   of the docker cache.

In these cases, simply comparing the creation timestamp of the image to that of
the most recently modified file in the build context is sufficient to safely
avoid redundant builds.


License
-------

BSD 2-Clause, see accompanying LICENSE file.


Requirements
------------

 - bash
 - docker 1.5+


Usage
-----

```bash
source img_fresh.sh

if img_fresh myimage path/to/build/context ; then
  echo myimage up-to-date
else
  docker build -t myimage path/to/build/context
fi
```

