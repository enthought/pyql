from .handle cimport shared_ptr
from .types cimport Size

cdef extern from 'ql/patterns/observable.hpp' namespace 'QuantLib' nogil:
    cdef cppclass Observable:
        pass

    cdef cppclass Observer:
        Observer()
        void registerWith(const shared_ptr[Observable]&)
        Size unregisterWith(const shared_ptr[Observable]&)

cdef extern from 'cpp_layer/observable.hpp' nogil:
    cdef cppclass PyObserver(Observer):
        PyObserver()
        PyObserver(object callback) except +
