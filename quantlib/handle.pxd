from libcpp cimport bool

cdef extern from 'ql/shared_ptr.hpp' namespace 'QuantLib::ext' nogil:

    cdef cppclass shared_ptr[T]:
        shared_ptr()
        shared_ptr(T*)
        shared_ptr(shared_ptr[T]&)
        T* get()
        T& operator*()
        void reset(T*)
        bool operator bool()
        shared_ptr[T]& operator=[Y](const shared_ptr[Y]& ptr)
        bool operator!()

    shared_ptr[T] make_shared[T](...)
    shared_ptr[T] static_pointer_cast[T](...)
    shared_ptr[T] dynamic_pointer_cast[T](...)

cdef extern from 'ql/optional.hpp' namespace 'QuantLib::ext' nogil:
    cdef cppclass nullopt_t:
        nullopt_t()

    cdef nullopt_t nullopt

    cdef cppclass optional[T]:
        optional()
        optional(nullopt_t)
        optional(const T&) except +
        T& value()
        T& value_or[U](U& default_value)
        bool operator!()
        optional& operator=(optional&)

    optional[T] make_optional[T](...) except +

cdef extern from 'ql/handle.hpp' namespace 'QuantLib' nogil:
    cdef cppclass Handle[T]:
        Handle()
        Handle(shared_ptr[T]&)
        Handle(shared_ptr[T]&, bool registerAsObserver)
        shared_ptr[T]& currentLink()
        bool empty()

    cdef cppclass RelinkableHandle[T](Handle):
        RelinkableHandle()
        RelinkableHandle(T*)
        RelinkableHandle(shared_ptr[T]&)
        RelinkableHandle(shared_ptr[T]&, bool registerAsObserver)
        void linkTo(shared_ptr[T]&)
        void linkTo(shared_ptr[T]&, bool registerAsObserver)
