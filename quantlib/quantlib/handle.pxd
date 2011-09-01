from libcpp cimport bool

cdef extern from 'boost/shared_ptr.hpp' namespace 'boost':

    cdef cppclass shared_ptr[T]:
        shared_ptr(T*)
        T* get()

cdef extern from 'ql/handle.hpp' namespace 'QuantLib':
    cdef cppclass Handle[T]:
        Handle()
        Handle(shared_ptr[T]*)
        Handle(T*)
        shared_ptr[T]& currentLink()

    cdef cppclass RelinkableHandle[T](Handle):
        RelinkableHandle()
        RelinkableHandle(T*)
        RelinkableHandle(shared_ptr[T]*)
        void linkTo(shared_ptr[T]&)
        void linkTo(shared_ptr[T]&, bool registerAsObserver)
        
