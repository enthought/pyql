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

cdef class ActualActual(DayCounter):

    def __init__(self, Convention convention=Convention.ISDA):
        self._thisptr = <_daycounter.DayCounter*> new \
            _aa.ActualActual(convention)

ActualActual.__doc__ = """ Actual/Actual day count

    The day count can be calculated according to:

        - the ISDA convention, also known as "Actual/Actual (Historical)",
          "Actual/Actual", "Act/Act", and according to ISDA also "Actual/365",
          "Act/365", and "A/365";
        - the ISMA and US Treasury convention, also known as
          "Actual/Actual (Bond)";
        - the AFB convention, also known as "Actual/Actual (Euro)".

        For more details, refer to
        http://www.isda.org/publications/pdf/Day-Count-Fracation1999.pdf

        Valid names for ACT/ACT daycounters are: \n {}
    """.format([])

cdef _daycounter.DayCounter* from_name(str convention):

    cdef Convention ql_convention = Convention[convention]

    return new _aa.ActualActual(ql_convention)
