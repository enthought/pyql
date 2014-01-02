# Compatibility layer for Python 2.6: try loading unittest2
import sys
if sys.version_info[:2] == (2, 6):
    try:
        import unittest2 as unittest
    except ImportError:
        raise Exception('The test suite requires unittest2 on Python 2.6')
else:
    import unittest


