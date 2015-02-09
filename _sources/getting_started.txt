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

* Boost (version 1.55 or higher)
* QuantLib_ (version 1.4 or higher)
* Cython_ (version 0.19 or higher)

Once the dependencies have been installed, enter the pyql root directory. Open the setup.py file
and configure the Boost and QuantLib include and library directories, then run ::

    python setup.py build

.. _QuantLib: http://www.quantlib.org

.. _Cython: http://www.cython.org

Installation from source
------------------------

The following instructions explain how to build the project from source, on a Linux system.
The instructions have been tested on Ubuntu 12.04 LTS.

Prerequisites:

* python 2.7
* C++ development environment 
* pandas 0.9

1. Install Boost (taken from a nice post_ by S. Zebardast)

   a. Download the Boost source package

      .. code-block:: bash

        wget -O boost_1_55_0.tar.gz \
        http://sourceforge.net/projects/boost/files/boost/1.55.0/boost_1_55_0.tar.gz/download
        tar xzvf boost_1_55_0.tar.gz

   b. Make sure you have the required libraries

      .. code-block:: bash

        sudo apt-get update
        sudo apt-get install build-essential g++ python-dev autotools-dev libicu-dev libbz2-dev 

  c. Build and install

     .. code-block:: bash

       cd boost_1_55_0
       sudo ./bootstrap.sh --prefix=/usr/local
       sudo ./b2 install

   If /usr/local/lib is not in your path:

   .. code-block:: bash

     sudo sh -c 'echo "/usr/local/lib" >> /etc/ld.so.conf.d/local.conf'
  
   and finally:

   .. code-block:: bash

     sudo ldconfig

2. Install Quantlib

   a. Download Quantlib 1.4 from Quantlib.org and copy to /opt

      .. code-block:: bash

        wget -O QuantLib-1.4.tar.gz  \
        http://sourceforge.net/projects/quantlib/files/QuantLib/1.4/QuantLib-1.4.tar.gz/download
        sudo cp QuantLib-1.4.tar.gz /opt


   b. Extract the Quantlib folder

      .. code-block:: bash

		      cd /opt
		      sudo tar xzvf QuantLib-1.4.tar.gz

   c. Configure QuantLib

      .. code-block:: bash

		      cd QuantLib-1.4
		      ./configure --disable-static CXXFLAGS=-O2 --with-boost-include=/usr/local/include --with-boost-lib=/usr/local/lib 

   d. Make and install

      .. code-block:: bash

		      make
		      sudo make install

3. Install Cython. While you can install Cython from source, we strongly recommend to install Cython via pip_::

    pip install cython

   If you do not have the required permissions to install Python packages in the system path, you can install Cython in your local user account via::

    pip install --user cython

4. Download pyql (https://github.com/enthought/pyql), then extract, build and test:

   .. code-block:: bash

		   $ cd ~/dev/pyql
		   $ make build
		   $ make tests

If you have installed QuantLib in a directory different from :code:`/opt`, edit the `setup.py` file before running make and update the :code:`INCLUDE_DIRS` and :code:`LIBRARY_DIRS` to point to your installation of QuantLib.

.. _pip: https://pypi.python.org/pypi/pip
.. _post: https://coderwall.com/p/0atfug

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
    - Add the Boost include directory to "C/C++" -> "Additional Include Directories"
    - Apply
    
    Do a first build to get all the object files generated
    
   g. Generate the def file:
   
    In your PyQL clone, got the scripts directory, and edit the main function.
    Set `input_directory` to the Release directory where your object files are 
    and change the `output_file` if appropriate (symbol_win32.def is the
    default) ! The def file is platform specific (you can't reuse a 32bit def
    file for a 64bit linker).
    
    This will generate a def file of about 44 Mb with all the needed symbols for
    PyQL compilation.
    
   h. Build the dll with the new def file
   
    - Change "Linker" -> "Input" -> "Module definition file" to point to 
      def file you just generated.
   
     Apply the changes and build the project
     
   i. Copy the QuantLib.dll to a directory which is on the PATH (or just the
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
