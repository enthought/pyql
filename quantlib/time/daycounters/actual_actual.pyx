'''Actual/Actual day count

The day count can be calculated according to:

 - the ISDA convention, also known as "Actual/Actual (Historical)",
   "Actual/Actual", "Act/Act", and according to ISDA also "Actual/365",
   "Act/365", and "A/365";
 - the ISMA and US Treasury convention, also known as
   "Actual/Actual (Bond)";
 - the AFB convention, also known as "Actual/Actual (Euro)".

For more details, refer to
https://www.isda.org/a/pIJEE/The-Actual-Actual-Day-Count-Fraction-1999.pdf
'''

from . cimport _actual_actual as _aa
from quantlib.time.schedule cimport Schedule

cdef class ActualActual(DayCounter):

    def __init__(self, Convention convention=Convention.ISDA, Schedule schedule=Schedule.__new__(Schedule)):
        """ Actual/Actual day count

        The day count can be calculated according to:

        - the ISDA convention, also known as "Actual/Actual (Historical)",
          "Actual/Actual", "Act/Act", and according to ISDA also "Actual/365",
          "Act/365", and "A/365";
        - the ISMA and US Treasury convention, also known as
          "Actual/Actual (Bond)";
        - the AFB convention, also known as "Actual/Actual (Euro)".

        For more details, refer to
        https://www.isda.org/a/pIJEE/The-Actual-Actual-Day-Count-Fraction-1999.pdf
        """
        self._thisptr = new _aa.ActualActual(convention, schedule._thisptr)
