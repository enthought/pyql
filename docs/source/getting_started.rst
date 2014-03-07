Getting started
===============

PyQL - an overview
------------------

Why building a new set of QuantLib wrappers for Python ?

The SWIG wrappers provide a very good coverage of the library but have
a number of pain points:

* Few Pythonic optimisation in the syntax: the python code for invoking QuantLib functions looks like the C++ version;
* No docstring or function signature are available on the Python side;
* The debugging is complex, and any customization of the wrapper involves complex programming;
* The build process is monolithic: any change to the wrapper requires the recompilation of the entire project;
* Complete loss of the C++ code organisation with a flat namespace in Python;
* SWIG typemaps development is not that fun.

For those reasons, and to have the ability to expose some of the
QuantLib internals that could be very useful on the Python side, we
chose another road. PyQL is build on top of Cython and creates a thin
Pythonic layer on top of QuantLib. It allows a tight control on the
wrapping and provides higher level Python integration.

Features:
+++++++++

* Integration with standard datatypes (like datetime objects) and numpy arrays;
* Simplifed API on the Python side (e.g. usage of Handles completely hidden from the user);
* Support full docstring and expose detailed function signatures to Python;
* Code organised in subpackages to provide a clean namespace, very close to the C++ code organisation;
* Easy extendibility thanks to Cython and shorter build time when adding new functionalities;
* Sphinx documentation.


Building and installing PyQL
----------------------------

PyQL must be installed on a system that has access to a build of QuantLib (the shared library and the C++ header files).  PyQL works out-of-the-box with Cython 0.17 and later; Cython 0.16 is supported if you apply a minor patch (see below). You can find the patch file in the PyQL root directory. 

Once Cython is patched, enter the pyql root directory. Open the setup.py file
and configure the Boost and QuantLib include and library directories, then run ::

    python setup.py build


Installation from source
------------------------

The following instructions explain how to build the project from source, on a Linux system.
The instructions have been tested on Ubuntu 12.04 LTS "Precise Pangolin".

Prerequites:

* python 2.7
* pandas 0.9

1. Install Quantlib

   a. Install boost 1.46 from the repository. By default, boost will be installed in /usr/lib and /usr/include.

   b. Download Quantlib 1.2 from Quantlib.org and copy to /opt

      .. code-block:: bash

		      $ sudo cp QuantLib-1.2.tar.gz /opt

   c. Extract the Quantlib folder

      .. code-block:: bash

		      $ cd /opt
		      $ sudo tar xzvf QuantLib-1.2.tar.gz

   d. Configure QuantLib

      .. code-block:: bash

		      $ cd QuantLib-1.2
		      $ ./configure --disable-static CXXFLAGS=-O2 

   e. Make and install

      .. code-block:: bash

		      $ make
		      $ sudo make install

2. Install Cython

   a. Download Cython-0.16.tar.gz from cython.org

   b. Extract the Cython folder

      .. code-block:: bash

		      $ tar xzvf Cython-0.16.tar.gz

   c. Apply patch

      .. code-block:: bash

		      $ cd Cython-0.16
		      $ patch -p1 < ~/dev/pyql/cython_0.16.patch

   d. Build and install Cython

      .. code-block:: bash

		    $ sudo python setup.py install

3. Build and test pyql

   .. code-block:: bash

		   $ cd ~/dev/pyql
		   $ make build
		   $ make tests

