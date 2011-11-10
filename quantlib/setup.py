
#from setuptools import setup, find_packages
from setuptools import setup
#from distutils.core import setup
#from setuptools import find_packages
# Warning : do not import the distutils extension before setuptools
# It does break the cythonize call
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
    INCLUDE_DIRS = ['/usr/local/include', '/usr/include', '.']
    LIBRARY_DIRS = ['/usr/local/lib', '/usr/lib', ]


def collect_extensions():

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

    cython_extension_directories = []
    for dirpath, directories, files in os.walk('quantlib'):
        print 'Path', dirpath

        # skip the settings package
        if dirpath.find('settings') > -1 or dirpath.find('test') > -1:
            continue

        # if the directory contains pyx files, cythonise it
        if len(glob.glob('{}/*.pyx'.format(dirpath))) > 0:
            cython_extension_directories.append(dirpath)

    print cython_extension_directories
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
    for ext in collected_extensions:
        if ext.name == piecewise_yield_curve_extension.name:
            collected_extensions.remove(ext)
            break
    else:
        raise RuntimeError('Piecewise yield curve extension not found')


    return collected_extensions + [
        settings_extension, test_extension, piecewise_yield_curve_extension
    ]

setup(
    name='quantlib',
    packages = ['quantlib.settings'],
    ext_modules = collect_extensions(),
    cmdclass = {'build_ext': build_ext}
)
