""" library for quantitative finance"""
import sys
import os

# preload the QuantLib dlls that are included in the package
if sys.platform == 'win32':
    try:
        import pkg_resources
        import ctypes
        preload_dlls = pkg_resources.resource_string(__name__, "preload_dlls.txt").decode()
        for dll in preload_dlls.splitlines():
            ctypes.cdll.LoadLibrary(os.path.join(os.path.dirname(__file__), dll.strip()))
    except (ImportError, IOError):
        # If the resource couldn't be found or if pkg_resources doesn't exist set the PATH
        # to include this folder.
        os.environ["PATH"] = os.path.abspath(os.path.dirname(__file__)) + ";" + os.environ["PATH"]
elif sys.platform == "linux":
    import ctypes
    sys.setdlopenflags(2 | ctypes.RTLD_GLOBAL)
