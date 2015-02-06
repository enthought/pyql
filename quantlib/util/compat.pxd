from libcpp.string cimport string

cdef string utf8_array_from_py_string(text)
cdef py_string_from_utf8_array(const char* char_array)

