include '../../types.pxi'

from cython.operator cimport dereference as deref
from libcpp.vector cimport vector

from quantlib.handle cimport shared_ptr, Handle

cimport quantlib.instruments._bonds as _bonds
cimport quantlib._quote as _qt

from quantlib.instruments.bonds cimport Bond
from quantlib.quotes cimport Quote
from quantlib.time.date cimport Date
from quantlib.time.schedule cimport Schedule
from quantlib.time.daycounter cimport DayCounter
from quantlib.time._calendar cimport Following

cimport _bond_helpers as _bh



from quantlib.termstructures.yields.rate_helpers cimport RateHelper


cdef class BondHelper(RateHelper):

    def __init__(self, Quote clean_price, Bond bond):

        # Create handles.
        cdef Handle[_qt.Quote] price_handle = \
                Handle[_qt.Quote](deref(clean_price._thisptr))

        self._thisptr = new shared_ptr[_bh.RateHelper](
            new _bh.BondHelper(
                price_handle,
                deref(<shared_ptr[_bonds.Bond]*> bond._thisptr)
            ))


cdef class FixedRateBondHelper(BondHelper):

    def __init__(self, Quote clean_price, Natural settlement_days,
                 Real face_amount, Schedule schedule, coupons,
                 DayCounter day_counter, int payment_conv=Following,
                 Real redemption=100.0, Date issue_date=None):

        # Turn Python coupons list into an STL vector.
        cdef vector[Rate] cpp_coupons = vector[Rate]()
        for rate in coupons:
            cpp_coupons.push_back(rate)

        # Create handles.
        cdef Handle[_qt.Quote] price_handle = \
                Handle[_qt.Quote](deref(clean_price._thisptr))

        self._thisptr = new shared_ptr[_bh.RateHelper](
            new _bh.FixedRateBondHelper(
                price_handle,
                settlement_days,
                face_amount,
                deref(schedule._thisptr),
                cpp_coupons,
                deref(day_counter._thisptr),
                payment_conv,
                redemption,
                deref(issue_date._thisptr.get())
            ))
