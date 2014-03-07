PyQL - QuantLib Cython wrappers
===============================

This library is a new set of wrappers using Cython on top of QuantLib.
It currently focuses on useful simple objects like Date, Calendar but
might be extended to more complex wrappers if needed.

This is still considered as alpha version even if it works quite well.

As PyQL is already used by other projects, we are still looking for a good
name. Suggestions are welcome!

Prerequisites
-------------

* [QuantLib](http://www.quantlib.org) (version 1.1 or higher)
* [Cython](http://www.cython.org)

To build the library, you'll need Cython 0.16 or higher. If you want to use
Cython 0.16, you'll need to apply the cython_0.16.patch in this repository
(unicode issue fix). See the [getting started guide](docs/source/getting_started.rst)
for more information. More recent versions of Cython should work out-of-the-box.
Cython 0.15 is not supported anymore as it does not support templated ctypedef.

Building the library
--------------------

The build and test suite can be run as follows::

    make clean
    make build
    make tests

To build the library on Mac OS X 10.9, the QuantLib library must be linked
against libstdc++. To do so, set the environment variables `CXXFLAGS` and
`LDFLAGS` to `-stlib=libstdc++ -mmacosx-version-min=10.6` before building
from source.
