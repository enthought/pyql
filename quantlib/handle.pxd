from libcpp cimport bool

cdef extern from 'boost/shared_ptr.hpp' namespace 'boost':

    cdef cppclass shared_ptr[T]:
        shared_ptr()
        shared_ptr(T*)
        shared_ptr(shared_ptr[T]&)
        T* get()
        long use_count()
        #void reset(shared_ptr[T]&)

cdef extern from 'boost/optional.hpp' namespace 'boost':
    cdef cppclass optional[T]:
        optional()
        optional(const T&)
        T get()
        bool operator!()

    optional[T] make_optional[T](bool, const T&)

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
