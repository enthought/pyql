
from setuptools import setup
# Warning : do not import the distutils extension before setuptools
# It does break the cythonize function calls
from distutils.extension import Extension

import glob
import os
import sys

from Cython.Distutils import build_ext
from Cython.Build import cythonize

import numpy

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
    # custom install of QuantLib 1.1
    INCLUDE_DIRS = ['/opt/QuantLib-1.1', '.']
    LIBRARY_DIRS = ['/opt/QuantLib-1.1/lib',]
    

def collect_extensions():
    """ Collect all the directories with Cython extensions and return the list
    of Extension.

    Th function combines static Extension declaration and calls to cythonize
    to build the list of extenions.
    """

    settings_extension = Extension('quantlib.settings',
        ['quantlib/settings/settings.pyx', 'quantlib/settings/ql_settings.cpp'],
        language='c++',
        include_dirs=INCLUDE_DIRS,
        library_dirs=LIBRARY_DIRS,
        define_macros = [('HAVE_CONFIG_H', 1)],
        libraries=['QuantLib']
    )

    test_extension = Extension('quantlib.test.test_cython_bug',
        ['quantlib/test/test_cython_bug.pyx', 'quantlib/settings/ql_settings.cpp'],
        language='c++',
        include_dirs=INCLUDE_DIRS,
        library_dirs=LIBRARY_DIRS,
        define_macros = [('HAVE_CONFIG_H', None)],
        libraries=['QuantLib']
    )

    piecewise_yield_curve_extension = Extension(
        'quantlib.termstructures.yields.piecewise_yield_curve',
        [
            'quantlib/termstructures/yields/piecewise_yield_curve.pyx',
            'quantlib/termstructures/yields/_piecewise_support_code.cpp'
        ],
        language='c++',
        include_dirs=INCLUDE_DIRS,
        library_dirs=LIBRARY_DIRS,
        define_macros = [('HAVE_CONFIG_H', None)],
        libraries=['QuantLib']
    )

    multipath_extension = Extension(
        name='quantlib.sim.simulate',
        sources=[
            'quantlib/sim/simulate.pyx',
            'quantlib/sim/_simulate_support_code.cpp'
        ],
        language='c++',
        include_dirs=INCLUDE_DIRS + [numpy.get_include()],
        library_dirs=LIBRARY_DIRS,
        define_macros = [('HAVE_CONFIG_H', 1)],
        libraries=['QuantLib']
    )

    manual_extensions = [
        multipath_extension,
        piecewise_yield_curve_extension,
        settings_extension,
        test_extension,
    ]

    cython_extension_directories = []
    for dirpath, directories, files in os.walk('quantlib'):
        print 'Path', dirpath

        # skip the settings package
        if dirpath.find('settings') > -1 or dirpath.find('test') > -1:
            continue

        # if the directory contains pyx files, cythonise it
        if len(glob.glob('{}/*.pyx'.format(dirpath))) > 0:
            cython_extension_directories.append(dirpath)

    collected_extensions = cythonize(
        [
            Extension('*', ['{}/*.pyx'.format(dirpath)],
                include_dirs=INCLUDE_DIRS,
                library_dirs=LIBRARY_DIRS,
                define_macros = [('HAVE_CONFIG_H', 1)]
            ) for dirpath in cython_extension_directories
        ]
    )

    # remove the generated piecewise_yield_curve extension
    names = [extension.name for extension in manual_extensions]
    for ext in collected_extensions:
        if ext.name in names:
            collected_extensions.remove(ext)
            continue

    return collected_extensions + manual_extensions

setup(
    name='quantlib',
    version='0.1',
    author='Didrik Pinte,Patrick Henaff',
    packages = ['quantlib.settings'],
    ext_modules = collect_extensions(),
    cmdclass = {'build_ext': build_ext}
)
