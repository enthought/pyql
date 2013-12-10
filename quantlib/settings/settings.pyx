# distutils: language = c++
# distutils: libraries = QuantLib
from cython.operator cimport dereference as deref
from libcpp cimport bool as cbool
from cpython cimport PyBytes_AsString
from python_version cimport PY_MAJOR_VERSION
from libcpp.string cimport string

cimport quantlib.time._date as qldate
cimport quantlib.time.date as date

cdef extern from "ql_settings.hpp" namespace "QL":
    qldate.Date get_evaluation_date()
    void set_evaluation_date(qldate.Date& date)

cdef extern from 'ql/version.hpp':

    char* QL_VERSION
    int QL_HEX_VERSION
    char* QL_LIB_VERSION

__quantlib_version__ = QL_VERSION
__quantlib_lib_version__ = QL_LIB_VERSION
__quantlib_hex_version__ = QL_HEX_VERSION

cdef class Settings:

    def __init__(self):
        pass

    property evaluation_date:
        """Property to set/get the evaluation date. """
        def __get__(self):
            cdef qldate.Date evaluation_date = get_evaluation_date()
            return date.date_from_qldate(evaluation_date)

        def __set__(self, date.Date evaluation_date):
            cdef qldate.Date* date_ref = <qldate.Date*>evaluation_date._thisptr.get()
            set_evaluation_date(deref(date_ref))

    property version:
        """Returns the QuantLib C++ version (QL_VERSION) used by this wrapper."""
        def __get__(self):
            return QL_VERSION

    @classmethod
    def instance(cls):
        """ Returns an instance of the global Settings object.

        Utility method to mimic the behaviour of the C++ singleton.

        """

        return cls()


def py_compat_str_as_utf8_string(text):
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
        text.decode('UTF-8')    # ensure it's UTF-8 encoded if there are high-bit chars
        utf8_data = text
    else:
        raise ValueError("requires text input, got %s" % type(text))
    return string(PyBytes_AsString(utf8_data))

def utf8_char_array_to_py_compat_str(char* char_array):
    """
    Converts the given char* to a native Python string (bytes on Py2, unicode on Py3)
    """
    if PY_MAJOR_VERSION < 3:
        return char_array
    else:
        return char_array.decode('UTF-8')

