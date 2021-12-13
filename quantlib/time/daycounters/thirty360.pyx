from cython.operator import dereference as deref
from quantlib.time.date cimport Date
cimport quantlib.time._daycounter as _daycounter
from . cimport _thirty360 as _th
from .thirty360 cimport Convention as QlConvention
from quantlib.time.daycounter cimport DayCounter

cdef class Thirty360(DayCounter):
   """The 30/360 day count can be calculated according to a
    number of convention.

   US convention: if the starting date is the 31st of a month or
   the last day of February, it becomes equal to the 30th of the
   same month.  If the ending date is the 31st of a month and the
   starting date is the 30th or 31th of a month, the ending date
   becomes equal to the 30th.  If the ending date is the last of
   February and the starting date is also the last of February,
   the ending date becomes equal to the 30th.
   Also known as "30/360" or "360/360".


   Bond Basis convention: if the starting date is the 31st of a
   month, it becomes equal to the 30th of the same month.
   If the ending date is the 31st of a month and the starting
   date is the 30th or 31th of a month, the ending date
   also becomes equal to the 30th of the month.
   Also known as "US (ISMA)".

   European convention: starting dates or ending dates that
   occur on the 31st of a month become equal to the 30th of the
   same month.
   Also known as "30E/360", or "Eurobond Basis"

   Italian convention: starting dates or ending dates that
   occur on February and are grater than 27 become equal to 30
   for computational sake.

   ISDA convention: starting or ending dates on the 31st of the
   month become equal to 30; starting dates or ending dates that
   occur on the last day of February also become equal to 30,
   except for the termination date.  Also known as "30E/360
   ISDA", "30/360 ISDA", or "30/360 German".

   NASD convention: if the starting date is the 31st of a
   month, it becomes equal to the 30th of the same month.
   If the ending date is the 31st of a month and the starting
   date is earlier than the 30th of a month, the ending date
   becomes equal to the 1st of the next month, otherwise the
   ending date becomes equal to the 30th of the same month.

   Valid names for 30/360 daycounts are:

   * USA
   * BondBasis
   * European
   * EurobondBasis
   * Italian
   * German
   * ISMA
   * ISDA
   * NASD
    """

   def __cinit__(self, convention=BondBasis, Date termination_date=Date()):
       self._thisptr = new _th.Thirty360(<QlConvention> convention,
                                         deref(termination_date._thisptr))

cdef _daycounter.DayCounter* from_name(str convention) except NULL:
    try:
        return new _th.Thirty360(<QlConvention>Convention[convention])
    except KeyError:
        raise ValueError("Unknown convention: {}".format(convention))
