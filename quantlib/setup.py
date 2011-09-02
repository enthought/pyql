
#from setuptools import setup, find_packages
#from setuptools import setup
from distutils.core import setup
#from setuptools import find_packages
# Warning : do not import the distutils extension before setuptools
# It does break the cythonize call
from distutils.extension import Extension 
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
    # good for Debian
    INCLUDE_DIRS = ['/usr/include', '.']
    LIBRARY_DIRS = ['/usr/lib']

settings_extension = Extension('quantlib.settings',
    ['quantlib/settings/settings.pyx', 'quantlib/settings/ql_settings.cpp'],
    language='c++',
    include_dirs=INCLUDE_DIRS,
    library_dirs=LIBRARY_DIRS,
    libraries=['QuantLib']
)

collected_extensions = cythonize([
    # Cythonising Extension does not support more than one pattern in the
    # source list. It is not possible to combine all the files in one
    # Extension
    Extension('*', 
        ['quantlib/time/*.pyx'],
        include_dirs=INCLUDE_DIRS,
        library_dirs=LIBRARY_DIRS,   
    ), 
    Extension('*', 
        ['quantlib/time/daycounters/*.pyx'],
        include_dirs=INCLUDE_DIRS,
        library_dirs=LIBRARY_DIRS,
    ),  
    Extension('*', 
        ['quantlib/time/calendars/*.pyx'],
        include_dirs=INCLUDE_DIRS,
        library_dirs=LIBRARY_DIRS,
    ),
    Extension('*', 
        ['quantlib/*.pyx'],
        include_dirs=INCLUDE_DIRS,
        library_dirs=LIBRARY_DIRS,
    ),
    Extension('*', 
        ['quantlib/indexes/*.pyx'],
        include_dirs=INCLUDE_DIRS,
        library_dirs=LIBRARY_DIRS,
    ),
    Extension('*', 
        ['quantlib/termstructures/yields/*.pyx'],
        include_dirs=INCLUDE_DIRS,
        library_dirs=LIBRARY_DIRS,
    ),
    Extension('*', 
        ['quantlib/termstructures/volatility/equityfx/*.pyx'],
        include_dirs=INCLUDE_DIRS,
        library_dirs=LIBRARY_DIRS,
    ),
    Extension('*', 
        ['quantlib/instruments/*.pyx'],
        include_dirs=INCLUDE_DIRS,
        library_dirs=LIBRARY_DIRS,
    ),
    Extension('*', 
        ['quantlib/processes/*.pyx'],
        include_dirs=INCLUDE_DIRS,
        library_dirs=LIBRARY_DIRS,
    ),
    Extension('*', 
        ['quantlib/pricingengines/*.pyx'],
        include_dirs=INCLUDE_DIRS,
        library_dirs=LIBRARY_DIRS,
    ),
 
])

setup(
    name='quantlib',
    packages = ['quantlib.settings'],
    ext_modules =  collected_extensions + [settings_extension],
    cmdclass = {'build_ext': build_ext}
)
