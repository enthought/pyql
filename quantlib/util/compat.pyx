""" Compatibility layer for Py2/Py3 support. """

from cpython cimport PyBytes_AsString, PY_MAJOR_VERSION
from libcpp.string cimport string

cdef string utf8_array_from_py_string(text):
    """
    Returns the result of calling string(PyBytes_AsString(text)) to return a
    C++ string after handling encoding of text to bytes (as UTF-8) if
    necessary. Compatible with both unicode strings on Py2 and Py3 and
    byte-strings on Py2.

    See https://github.com/cython/cython/wiki/FAQ#how-do-i-pass-a-python-string-parameter-on-to-a-c-library
    """
    if isinstance(text, unicode):
        utf8_data = text.encode('UTF-8')
    elif (PY_MAJOR_VERSION < 3) and isinstance(text, str):
        utf8_data = text.decode('UTF-8')    # ensure it's UTF-8 encoded if there are high-bit chars
    else:
        raise ValueError("requires text input, got %s" % type(text))
    return string(PyBytes_AsString(utf8_data))

cdef py_string_from_utf8_array(const char* char_array):
    """
    Converts the given char* to a native Python string (bytes on Py2, unicode on Py3)
    """
    if PY_MAJOR_VERSION < 3:
        return char_array
    else:
        return char_array.decode('UTF-8')

# from Cython doc: convert various string representations to UTF-8 if needed

cdef unicode _ustring(s):
    if type(s) is unicode:
        # fast path for most common case(s)
        return <unicode>s
    elif PY_MAJOR_VERSION < 3 and isinstance(s, str):
        return s.decode('UTF-8')
    elif PY_MAJOR_VERSION >= 3 and isinstance(s, bytes):
        return s.decode('UTF-8')
    elif isinstance(s, unicode):
        return unicode(s)
    else:
        raise TypeError("Unknown type for s: %s (trying to convert to unicode)" % type(s))
