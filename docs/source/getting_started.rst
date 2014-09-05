Getting started
===============

PyQL - an overview
------------------

Why building a new set of QuantLib wrappers for Python ?

The SWIG wrappers provide a very good coverage of the library but have
a number of pain points:

* Few Pythonic optimisations in the syntax: the python code for invoking QuantLib functions looks like the C++ version;
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

Prerequisites:

* QuantLib_ (version 1.1 or higher)
* Cython_ (version 0.19 or higher)

Once the dependencies have been installed, enter the pyql root directory. Open the setup.py file
and configure the Boost and QuantLib include and library directories, then run ::

    python setup.py build

.. _QuantLib: http://www.quantlib.org

.. _Cython: http://www.cython.org

Installation from source
------------------------

The following instructions explain how to build the project from source, on a Linux system.
The instructions have been tested on Debian GNU/Linux 6.0.7 (squeeze).

Prerequisites:

* python 2.7
* pandas 0.9

1. Install Quantlib

   a. Install the latest version of Boost from the repository. Here we use Boost 1.55.0. By default, Boost will be installed in /usr/lib and /usr/include.

   b. Download Quantlib 1.4 from Quantlib.org and copy to /opt

      .. code-block:: bash

		      $ sudo cp QuantLib-1.4.tar.gz /opt

      .. note:: You can install QuantLib in a different directory if needed. If you do, edit the :code:`setup.py` file as described below.

   c. Extract the Quantlib folder

      .. code-block:: bash

		      $ cd /opt
		      $ sudo tar xzvf QuantLib-1.4.tar.gz

   d. Configure QuantLib

      .. code-block:: bash

		      $ cd QuantLib-1.4
		      $ ./configure --disable-static CXXFLAGS=-O2 

   e. Make and install

      .. code-block:: bash

		      $ make
		      $ sudo make install

2. Install Cython. While you can install Cython from source, we strongly recommend to install Cython via pip_::

    pip install cython

   If you do not have the required permissions to install Python packages in the system path, you can install Cython in your local user account via::

    pip install --user cython

3. Build and test pyql

   .. code-block:: bash

		   $ cd ~/dev/pyql
		   $ make build
		   $ make tests

   .. note:: If you have installed QuantLib in a directory different from :code:`/opt`, edit the `setup.py` file before running make and update the :code:`INCLUDE_DIRS` and :code:`LIBRARY_DIRS` to point to your installation of QuantLib.

.. _pip: https://pypi.python.org/pypi/pip


Installation from source on Windows
-----------------------------------

The following instructions explain how to build the project from source, on a
Windows system.
The instructions have been tested on Windows 7 32bit with Visual Studio 2008.

.. warning: Visual Studio version

    Visual Studio needs to be the 2008 version. It is the only version compatible
    with a Python 2.7 installation that is built against the CRT90.

Prerequisites:

* python 2.7 (e.g. Canopy with Cython 0.20 or above)
* pandas 0.9

1. Install Quantlib

   a. Install the latest version of Boost from sourceforge. You can get the
   binaries of 1.55 for windows 32 or 64bit depending on your target.
   
   b. Download Quantlib 1.4 from Quantlib.org and unzip locally

   c. Extract the Quantlib folder

   d. Open the QuantLib_vc9 solution with Visual Studio
   
   e. Patch ql/settings.py

    In the ql/settings.py file, update the Settings class defintion as
    following (line 37)::
    
        class __declspec(dllexport) Settings : public Singleton<Settings> {

   f. In the QuantLib project properties
    
    - Change "General" -> "Configuration type" to "Dynamic Library (DLL)"
    - Apply
    - Change "Linker" -> "Input" -> "Module definition file" to point to 
      symbol.def in your clone of the PyQL repo
   
     Apply the changes and build the project
     
   g. Copy the QuantLib.dll to a directory which is on the PATH (or just the
      PyQL directory if you're in development mode)
   
2. Install Cython. While you can install Cython from source, we strongly
   recommend to install Cython via the Canopy Package Manager, another Python
   distribution or via pip_::

    pip install cython

   If you do not have the required permissions to install Python packages in the system path, you can install Cython in your local user account via::

    pip install --user cython

3. Build and test pyql

    Edit the setup.py to make sure the INCLUDE_DIRS and LIBRARY_DIRS point to
    the correct directories.

   .. code-block:: bash

        PS C:\dev\pyql> python setup.py build
        PS C:\dev\pyql> python setup.py install

   .. note:: Development mode
   
        If you want to build the library in place and test things, you can do:
        

        .. code-block:: bash
        
                PS C:\dev\pyql> python setup.py build_ext --inplace
                PS C:\dev\pyql> python -m unittest discover -v

.. _pip: https://pypi.python.org/pypi/pip