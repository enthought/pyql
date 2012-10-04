Getting started
===============

PyQL - an overview
------------------

Why building a new set of QuantLib wrappers for Python ?

The SWIG wrappers provide a very good coverage of the library but have
a number of pain points:

 * few Pythonic optimisation in the syntax: the code a user must writeon the Python side looks like the C++ version
 * no docstring or function signature available on the Python side
 * complex debugging and complex customization of the wrappers
 * monolithic build process
 * complete loss of the C++ code organisation with a flat namespace in Python
 * SWIG typemaps development is not that fun

For those reasons and to have the ability to expose some of the
QuantLib internals that could be very useful on the Python side, we
chosed another road. PyQL is build on top of Cython and creates a thin
Pythonic layer on top of QuantLib. It allows a tight control on the
wrapping and provides higher level Python integration.

Features:
+++++++++

 * Integration with standard datatypes (like datetime objects) and numpy arrays
 * Simplifed API on the Python side (e.g. usage of Handles completely hidden from the user)
 * Support full docstring and expose detailed function signatures to Python
 * Code organised in subpackages to provide a decent namespace, very close to the C++ code organisation
 * Easy extendibility thanks to Cython and shorter build time when adding new functionnalities
 * Sphinx documentation


Building and installing PyQL
----------------------------

PyQL must be installed on a system that has access to a build of QuantLib. It
requires patched version of Cython 0.15 (major patch) or 0.16 (minor patch).
You can find them both in the PyQL root directory. 

Once Cython is patched, enter the pyql root directory. Open the setup.py file
and configure the Boost and QuantLib include and library directories, then run ::

    python setup.py build


