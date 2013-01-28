'''Actual/Actual day count

The day count can be calculated according to:

 - the ISDA convention, also known as "Actual/Actual (Historical)",
   "Actual/Actual", "Act/Act", and according to ISDA also "Actual/365",
   "Act/365", and "A/365";
 - the ISMA and US Treasury convention, also known as
   "Actual/Actual (Bond)";
 - the AFB convention, also known as "Actual/Actual (Euro)".

For more details, refer to
http://www.isda.org/publications/pdf/Day-Count-Fracation1999.pdf
'''
cimport quantlib.time._daycounter as _daycounter
cimport quantlib.time.daycounters._actual_actual as _aa
from quantlib.time.daycounter cimport DayCounter

cdef public enum Convention:
    ISMA       = _aa.ISMA
    Bond       = _aa.Bond
    ISDA       = _aa.ISDA
    Historical = _aa.Historical
    Actual365  = _aa.Actual365
    AFB        = _aa.AFB
    Euro       = _aa.Euro

CONVENTIONS = {
    'ISMA' : _aa.ISMA,
    'Bond' : _aa.Bond,
    'ISDA' : _aa.ISDA,
    'Historical' : _aa.Historical,
    'Actual365' : _aa.Actual365,
    'AFB' : _aa.AFB,
    'Euro' : _aa.Euro
}


cdef class ActualActual(DayCounter):
    """ Actual/Actual day count

    The day count can be calculated according to:

        - the ISDA convention, also known as "Actual/Actual (Historical)",
          "Actual/Actual", "Act/Act", and according to ISDA also "Actual/365",
          "Act/365", and "A/365";
        - the ISMA and US Treasury convention, also known as
          "Actual/Actual (Bond)";
        - the AFB convention, also known as "Actual/Actual (Euro)".

        For more details, refer to
        http://www.isda.org/publications/pdf/Day-Count-Fracation1999.pdf

    """

    def __cinit__(self, convention=ISMA):
        self._thisptr = <_daycounter.DayCounter*> new \
            _aa.ActualActual(<_aa.Convention>convention)


cdef _daycounter.DayCounter* from_name(str name, str convention):

    cdef _aa.Convention ql_convention = <_aa.Convention>CONVENTIONS[convention]

    cdef _daycounter.DayCounter* return_val =  new _aa.ActualActual(ql_convention)

    return return_val



