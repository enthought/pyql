
from setuptools import setup, find_packages
# Warning : do not import the distutils extension before setuptools
# It does break the cythonize function calls
from distutils.extension import Extension
from distutils.sysconfig import get_config_vars

import glob
import os
import platform
import sys

from Cython.Distutils import build_ext
from Cython.Build import cythonize

try:
    import numpy
    HAS_NUMPY = True
except ImportError:
    HAS_NUMPY = False

DEBUG = False

SUPPORT_CODE_INCLUDE = './cpp_layer'

QL_LIBRARY = 'QuantLib'

# FIXME: would be good to be able to customize the path with environment
# variables in place of hardcoded paths ...
if sys.platform == 'darwin':
    INCLUDE_DIRS = ['/usr/local/include', '.', '../sources/boost_1_55_0', SUPPORT_CODE_INCLUDE]
    LIBRARY_DIRS = ["/usr/local/lib"]

    ## From SO: hack to remove warning about strict prototypes
    ## http://stackoverflow.com/questions/8106258/cc1plus-warning-command-line-option-wstrict-prototypes-is-valid-for-ada-c-o    
    (opt,) = get_config_vars('OPT')
    os.environ['OPT'] = " ".join(
        flag for flag in opt.split() if flag != '-Wstrict-prototypes')

elif sys.platform == 'win32':
    # With MSVC2008, the library is called QuantLib.lib but with MSVC2010, the
    # naming is QuantLib-vc100-mt
    if sys.version_info >= (3, 0):
        QL_LIBRARY = 'QuantLib-vc100-mt'
    INCLUDE_DIRS = [
        r'c:\dev\QuantLib-1.4',  # QuantLib headers
        r'c:\dev\boost_1_56_0',  # Boost headers
        '.',
        SUPPORT_CODE_INCLUDE
    ]
    LIBRARY_DIRS = [
        r"C:\dev\QuantLib-1.4\build\vc100\Win32\Release", # for the dll lib
        r"C:\dev\QuantLib-1.4\lib", 
        '.',
        r'.\dll',
    ]
elif sys.platform.startswith('linux'):   # 'linux' on Py3, 'linux2' on Py2
    # good for Debian / ubuntu 10.04 (with QL .99 installed by default)
    INCLUDE_DIRS = ['/usr/local/include', '/usr/include', '.', SUPPORT_CODE_INCLUDE]
    LIBRARY_DIRS = ['/usr/local/lib', '/usr/lib', ]
    # custom install of QuantLib 1.1
    # INCLUDE_DIRS = ['/opt/QuantLib-1.1', '.', SUPPORT_CODE_INCLUDE]
    # LIBRARY_DIRS = ['/opt/QuantLib-1.1/lib',]

if HAS_NUMPY:
    INCLUDE_DIRS.append(numpy.get_include())

def get_define_macros():
    #defines = [ ('HAVE_CONFIG_H', None)]
    defines = []
    if sys.platform == 'win32':
        # based on the SWIG wrappers
        defines += [
            (name, None) for name in [
                '__WIN32__', 'WIN32', 'NDEBUG', '_WINDOWS', 'NOMINMAX', 'WINNT',
                '_WINDLL', '_SCL_SECURE_NO_DEPRECATE', '_CRT_SECURE_NO_DEPRECATE',
                '_SCL_SECURE_NO_WARNINGS'
            ]
        ]
    return defines

def get_extra_compile_args():
    if sys.platform == 'win32':
        args = ['/GR', '/FD', '/Zm250', '/EHsc']
        if DEBUG:
            args.append('/Z7')
    else:
        args = []

    return args

def get_extra_link_args():
    if sys.platform == 'win32':
        args = ['/subsystem:windows', '/machine:I386']
        if DEBUG:
            args.append('/DEBUG')
    elif sys.platform == 'darwin':
        major, minor = [
            int(item) for item in platform.mac_ver()[0].split('.')[:2]]
        if major == 10 and minor >= 9:
            # On Mac OS 10.9 we link against the libstdc++ library.
            args = ['-stdlib=libstdc++', '-mmacosx-version-min=10.6']
        else:
            args = []
    else:
        args = []

    return args

CYTHON_DIRECTIVES = {"embedsignature": True}

def collect_extensions():
    """ Collect all the directories with Cython extensions and return the list
    of Extension.

    Th function combines static Extension declaration and calls to cythonize
    to build the list of extenions.
    """

    kwargs = {
        'language':'c++',
        'include_dirs':INCLUDE_DIRS,
        'library_dirs':LIBRARY_DIRS,
        'define_macros':get_define_macros(),
        'extra_compile_args':get_extra_compile_args(),
        'extra_link_args':get_extra_link_args(),
        'libraries':[QL_LIBRARY],
        'cython_directives':CYTHON_DIRECTIVES
    }

    settings_extension = Extension('quantlib.settings',
        ['quantlib/settings.pyx', 'cpp_layer/ql_settings.cpp'],
        **kwargs
    )

    test_extension = Extension('quantlib.test.test_cython_bug',
        ['quantlib/test/test_cython_bug.pyx', 'cpp_layer/ql_settings.cpp'],
        **kwargs
    )

    piecewise_yield_curve_extension = Extension(
        'quantlib.termstructures.yields.piecewise_yield_curve',
        [
            'quantlib/termstructures/yields/piecewise_yield_curve.pyx',
            'cpp_layer/yield_piecewise_support_code.cpp'
        ],
        **kwargs

    )

    piecewise_default_curve_extension = Extension(
        'quantlib.termstructures.credit.piecewise_default_curve',
        [
            'quantlib/termstructures/credit/piecewise_default_curve.pyx',
            'cpp_layer/credit_piecewise_support_code.cpp'
        ],
        **kwargs
    )



    mc_vanilla_engine_extension = Extension(
        name='quantlib.pricingengines.vanilla.mcvanillaengine',
        sources=[
            'quantlib/pricingengines/vanilla/mcvanillaengine.pyx',
            'cpp_layer/mc_vanilla_engine_support_code.cpp'
        ],
        **kwargs
    )

    business_day_convention_extension = Extension(
        name='quantlib.time.businessdayconvention',
        sources=[
            'quantlib/time/businessdayconvention.pyx',
            'cpp_layer/businessdayconvention_support_code.cpp'
        ],
        **kwargs
    )

    multipath_extension = Extension(
            name='quantlib.sim.simulate',
            sources=[
                'quantlib/sim/simulate.pyx',
                'cpp_layer/simulate_support_code.cpp'
            ],
            **kwargs
        )

    manual_extensions = [
        multipath_extension,
        mc_vanilla_engine_extension,
        piecewise_yield_curve_extension,
        piecewise_default_curve_extension,
        settings_extension,
        test_extension,
        business_day_convention_extension
    ]



    cython_extension_directories = []
    for dirpath, directories, files in os.walk('quantlib'):

        # skip the settings package
        if dirpath.find('settings') > -1 or dirpath.find('test') > -1:
            continue

        # if the directory contains pyx files, cythonise it
        if len(glob.glob('{0}/*.pyx'.format(dirpath))) > 0:
            cython_extension_directories.append(dirpath)

    collected_extensions = cythonize(
        [
            Extension('*', ['{0}/*.pyx'.format(dirpath)], **kwargs)
            for dirpath in cython_extension_directories
        ]
    )

    # remove  all the manual extensions from the collected ones
    names = [extension.name for extension in manual_extensions]
    for ext in collected_extensions:
        if ext.name in names:
            collected_extensions.remove(ext)
            continue
    if not HAS_NUMPY:
        # remove the multipath extension from the list
        manual_extensions = manual_extensions[1:]
        print('Numpy is not available, mulitpath extension not compiled')


    extensions = collected_extensions + manual_extensions

    return extensions

setup(
    name = 'quantlib',
    version = '0.1',
    author = 'Didrik Pinte,Patrick Henaff',
    license = 'BSD',
    packages = find_packages(),
    ext_modules = collect_extensions(),
    cmdclass = {'build_ext': build_ext},
    install_requires = ['distribute', 'tabulate', 'pandas', 'six'],
    zip_safe = False
)
