from libcpp cimport bool

cdef extern from 'boost/shared_ptr.hpp' namespace 'boost':

    cdef cppclass shared_ptr[T]:
        shared_ptr()
        shared_ptr(T*)
        shared_ptr(shared_ptr[T]&)
        T* get()
        T& operator*()
        void reset(T*)
        bool operator bool()

cdef extern from 'boost/pointer_cast.hpp' namespace 'boost':
    shared_ptr[T] static_pointer_cast[T](...)

cdef extern from 'boost/optional.hpp' namespace 'boost':
    cdef cppclass optional[T]:
        optional()
        optional(const T&)
        T get()
        bool operator!()
        optional& operator=(T&)

cdef extern from 'ql/handle.hpp' namespace 'QuantLib':
    cdef cppclass Handle[T]:
        Handle()
        Handle(shared_ptr[T]&)
        shared_ptr[T]& currentLink()
        bool empty()

    cdef cppclass RelinkableHandle[T](Handle):
        RelinkableHandle()
        RelinkableHandle(T*)
        RelinkableHandle(shared_ptr[T]&)
        void linkTo(shared_ptr[T]&)
        void linkTo(shared_ptr[T]&, bool registerAsObserver)

cdef extern from 'ql/qldefines.hpp':
    cdef int QL_NULL_INTEGER
    cdef float QL_NULL_REAL
