from setuptools import setup, find_packages, Extension

from distutils import log
from distutils.sysconfig import customize_compiler

import glob
import os
import platform
import sys

from Cython.Distutils import build_ext
from Cython.Build import cythonize

if sys.platform == 'win32':
    VC_INCLUDE_REDIST = False  # Set to True to include C runtime dlls in distribution.
    from distutils import msvc9compiler
    from platform import architecture
    VC_VERSION = msvc9compiler.VERSION
    ARCH = "x64" if architecture()[0] == "64bit" else "x86"

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
    INCLUDE_DIRS = [
        '/usr/local/include', '.', '../sources/boost_1_55_0',
        SUPPORT_CODE_INCLUDE
    ]
    LIBRARY_DIRS = ["/usr/local/lib"]

elif sys.platform == 'win32':
    # With MSVC2008, the library is called QuantLib.lib but with MSVC2010, the
    # naming is QuantLib-vc100-mt
    if VC_VERSION >= 10.0:
        QL_LIBRARY = 'QuantLib-vc%d0-%s-mt' % (VC_VERSION, ARCH)

    INCLUDE_DIRS = [
        r'c:\dev\QuantLib-1.4',  # QuantLib headers
        r'c:\dev\boost_1_56_0',  # Boost headers
        '.',
        SUPPORT_CODE_INCLUDE
    ]
    LIBRARY_DIRS = [
        r"C:\dev\QuantLib-1.4\build\vc%d0\%s\Release" % (
            VC_VERSION, ("x64" if ARCH == "x64" else "Win32")),  # for the dll lib
        r"C:\dev\QuantLib-1.4\lib",
        '.',
        r'.\dll',
    ]
elif sys.platform.startswith('linux'):   # 'linux' on Py3, 'linux2' on Py2
    INCLUDE_DIRS = ['/usr/local/include', '/usr/include', '.', SUPPORT_CODE_INCLUDE]
    LIBRARY_DIRS = ['/usr/local/lib', '/usr/lib']

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
        args = ['/subsystem:windows', '/machine:%s' % ("X64" if ARCH == "x64" else "I386")]
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
        args = ['-Wl,--strip-all']

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
        'libraries':[QL_LIBRARY]
    }

    settings_extension = Extension('quantlib.settings',
        ['quantlib/settings.pyx', 'cpp_layer/ql_settings.cpp'],
        **kwargs
    )

    test_extension = Extension('quantlib.test.test_cython_bug',
        ['quantlib/test/test_cython_bug.pyx', 'cpp_layer/ql_settings.cpp'],
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

    hestonhw_constraint_extension = Extension(
        name='quantlib.math.hestonhwcorrelationconstraint',
        sources=[
            'quantlib/math/hestonhwcorrelationconstraint.pyx',
            'cpp_layer/constraint_support_code.cpp'
        ],
        **kwargs
    )

    manual_extensions = [
        hestonhw_constraint_extension,
        multipath_extension,
        settings_extension,
        test_extension,
    ]

    # remove  all the manual extensions from the collected ones
    if not HAS_NUMPY:
        # remove the multipath extension from the list
        manual_extensions = manual_extensions[1:]
        print('Numpy is not available, multipath extension not compiled')

    collected_extensions = cythonize(
            manual_extensions +
            [Extension('*', ['**/*.pyx'], **kwargs)],
            compiler_directives=CYTHON_DIRECTIVES, nthreads = 4)

    return collected_extensions

class pyql_build_ext(build_ext):
    """
    Custom build command for quantlib that on Windows copies the quantlib dll
    and optionally c runtime dlls to the quantlib package.
    """
    def build_extensions(self):
        customize_compiler(self.compiler)
        try:
            self.compiler.compiler_so.remove("-Wstrict-prototypes")
        except (AttributeError, ValueError):
            pass
        build_ext.build_extensions(self)

    def run(self):
        build_ext.run(self)

        # Find the quantlib dll and copy it to the built package
        if sys.platform == "win32":
            # Find the visual studio runtime redist dlls
            dlls = []
            if VC_INCLUDE_REDIST:
                plat_name = msvc9compiler.get_platform()
                plat_spec = msvc9compiler.PLAT_TO_VCVARS[plat_name]

                # look for the compiler executable
                vc_env = msvc9compiler.query_vcvarsall(VC_VERSION, plat_spec)
                for path in vc_env['path'].split(os.pathsep):
                    if os.path.exists(os.path.join(path, "cl.exe")):
                        crt_dir = "Microsoft.VC%d0.CRT" % VC_VERSION
                        redist_dir = os.path.join(path, "..", ".redist", ARCH, crt_dir)
                        if not os.path.exists(redist_dir):
                            redist_dir = os.path.join(path, "..", "..", "redist", ARCH, crt_dir)
                        break
                else:
                    raise RuntimeError("Can't find cl.exe")

                assert os.path.exists(redist_dir), "Can't find CRT redist dlls '%s'" % redist_dir
                dlls.extend(glob.glob(os.path.join(redist_dir, "msvc*.dll")))

            for libdir in LIBRARY_DIRS:
                if os.path.exists(os.path.join(libdir, QL_LIBRARY + ".dll")):
                    dlls.append(os.path.join(libdir, QL_LIBRARY + ".dll"))
                    break
            else:
                raise AssertionError("%s.dll not found" % QL_LIBRARY)

            for dll in dlls:
                self.copy_file(dll, os.path.join(self.build_lib, "quantlib", os.path.basename(dll)))

            # Write the list of dlls to be pre-loaded
            filename = os.path.join(self.build_lib, "quantlib", "preload_dlls.txt")
            log.info("writing preload dlls list to %s", filename)
            if not self.dry_run:
                with open(filename, "wt") as fh:
                    fh.write("\n".join(map(os.path.basename, dlls)))


setup(
    name = 'quantlib',
    version = '0.1',
    author = 'Didrik Pinte,Patrick Henaff',
    license = 'BSD',
    packages = find_packages(),
    include_package_data = True,
    ext_modules = collect_extensions(),
    setup_requires=['cython'],
    cmdclass = {'build_ext': pyql_build_ext},
    install_requires = ['tabulate', 'pandas', 'six'],
    zip_safe = False
)
