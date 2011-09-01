cimport _currency

cdef class Currency:
    cdef _currency.Currency *_thisptr

    def __cinit__(self):
        self._thisptr = new _currency.Currency()

    property name:
        def __get__(self):
            return self._thisptr.name().c_str()

    property code:
        def __get__(self):
            return self._thisptr.code().c_str()

    def __str__(self):
        if not self._thisptr.empty():
            return self._thisptr.name().c_str()
        else:
            return 'null currency'
