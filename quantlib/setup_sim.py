from setuptools import setup
# Warning : do not import the distutils extension before setuptools
# It does break the cythonize function calls
from distutils.extension import Extension

import glob
import os
import sys

from Cython.Distutils import build_ext
from Cython.Build import cythonize

if sys.platform == 'darwin':
    INCLUDE_DIRS = ['/opt/local/include', '.']
    LIBRARY_DIRS = ["/opt/local/lib"]
elif sys.platform == 'win32':
    # using msys
    INCLUDE_DIRS = [r'C:\msys\1.0\local\include', '.']
    LIBRARY_DIRS = [r"C:\msys\1.0\local\lib"]
elif sys.platform == 'linux2':
    # good for Debian / ubuntu 10.04 (with QL .99 installed by default)
    # INCLUDE_DIRS = ['/usr/local/include', '/usr/include', '.']
    # LIBRARY_DIRS = ['/usr/local/lib', '/usr/lib', ]
    INCLUDE_DIRS = ['/opt/QuantLib-1.1', '.']
    LIBRARY_DIRS = ['/opt/QuantLib-1.1/lib', ]


mc_extension = [Extension(name='quantlib.sim.simulate',
sources=['quantlib/sim/simulate.pyx', 'quantlib/sim/_simulate_support_code.cpp'],
language='c++',
include_dirs=INCLUDE_DIRS,
library_dirs=LIBRARY_DIRS,
define_macros = [('HAVE_CONFIG_H', 1)],
libraries=['QuantLib']
)]

setup(name='quantlib', cmdclass={'build_ext': build_ext},
ext_modules=mc_extension,)
    
