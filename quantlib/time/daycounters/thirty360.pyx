# coding: utf-8

from __future__ import unicode_literals

cimport quantlib.time._daycounter as _daycounter
cimport quantlib.time.daycounters._thirty360 as _th
from quantlib.time.daycounter cimport DayCounter

cdef public enum Convention:
    USA           = _th.USA
    BONDBASIS     = _th.BondBasis
    EUROPEAN      = _th.European
    EUROBONDBASIS = _th.EurobondBasis
    ITALIAN       = _th.Italian

CONVENTIONS = {
    "USA":       _th.USA,
    "BONDBASIS": _th.BondBasis,
    "EUROPEAN":  _th.European,
    "EUROBONDBASIS": _th.EurobondBasis,
    "ITALIAN":   _th.Italian
    }


DOC_TEMPLATE = """The 30/360 day count can be calculated according to US, European, or
Italian conventions.

US (NASD) convention: if the starting date is the 31st of a
month, it becomes equal to the 30th of the same month.
If the ending date is the 31st of a month and the starting
date is earlier than the 30th of a month, the ending date
becomes equal to the 1st of the next month, otherwise the
ending date becomes equal to the 30th of the same month.
Also known as "30/360", "360/360", or "Bond Basis"

European convention: starting dates or ending dates that
occur on the 31st of a month become equal to the 30th of the
same month.
Also known as "30E/360", or "Eurobond Basis"

Italian convention: starting dates or ending dates that
occur on February and are grater than 27 become equal to 30
for computational sake.

Valid names for 30/360 daycounts are:

* {}


"""

cdef class Thirty360(DayCounter):

    _valid_names = [
        '30/360({})'.format(convention ) for convention in CONVENTIONS
    ]
    __doc__ =  DOC_TEMPLATE.format(
        '\n* '.join(_valid_names)
    )

    def __cinit__(self, convention=BONDBASIS):
        self._thisptr = <_daycounter.DayCounter*> new \
            _th.Thirty360(<_th.Convention> convention)

cdef _daycounter.DayCounter* from_name(str convention):

    cdef _th.Convention ql_convention = <_th.Convention>CONVENTIONS[convention]

    cdef _daycounter.DayCounter* return_val =  new _th.Thirty360(ql_convention)

    return return_val

