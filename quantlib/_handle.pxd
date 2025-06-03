from libcpp cimport bool
from .ext cimport shared_ptr

cdef extern from 'ql/handle.hpp' namespace 'QuantLib' nogil:
    cdef cppclass Handle[T]:
        Handle()
        Handle(Handle&)
        Handle(shared_ptr[T]&)
        Handle(shared_ptr[T]&, bool registerAsObserver)
        shared_ptr[T]& currentLink()
        bool empty()

    cdef cppclass RelinkableHandle[T](Handle):
        RelinkableHandle()
        RelinkableHandle(shared_ptr[T]&, bool registerAsObserver)
        void linkTo(shared_ptr[T]&, bool registerAsObserver)
