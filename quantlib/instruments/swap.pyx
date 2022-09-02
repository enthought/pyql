# Copyright (C) 2013, Enthought Inc
# Copyright (C) 2013, Patrick Henaff

# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE.  See the license for more details.

""" Interest rate swap"""

from quantlib.types cimport Size
from quantlib.cashflow cimport Leg
cimport quantlib.time._date as _date
from quantlib.time.date cimport date_from_qldate
from . cimport _swap

cdef inline _swap.Swap* get_swap(Swap swap):
    """ Utility function to extract a properly casted Swap pointer out of the
    internal _thisptr attribute of the Instrument base class. """

    return <_swap.Swap*>swap._thisptr.get()


cdef class Swap(Instrument):
    """
    Base swap class
    """
    Payer = Type.Payer
    Receiver = Type.Receiver

    def __init__(self):
        raise NotImplementedError('Generic swap not yet implemented. \
        Please use child classes.')

    ## def __init__(self, Leg firstLeg,
    ##              Leg secondLeg):

    ##     cdef _cf.Leg* leg1 = firstLeg._thisptr.get()
    ##     cdef _cf.Leg* leg2 = secondLeg._thisptr.get()

    ##     self._thisptr = new shared_ptr[_instrument.Instrument](\
    ##        new _swap.Swap(deref(leg1),
    ##                       deref(leg2)))


    ## def __init__(self, vector[Leg] legs,
    ##          vector[bool] payer):

    ##     cdef vector[_cf.Leg]* _legs = new vector[_cf.Leg](len(legs))
    ##     for l in legs:
    ##         _legs.push_back(l)

    ##     cdef vector[bool]* _payer = new vector[bool](len(payer))
    ##     for p in payer:
    ##         _payer.push_back(p)

    ##     self._thisptr = new shared_ptr[_instrument.Instrument](\
    ##         new _swap.Swap(_legs, payer)
    ##         )

    property start_date:
        def __get__(self):
            cdef _date.Date dt = get_swap(self).startDate()
            return date_from_qldate(dt)

    property maturity_date:
        def __get__(self):
            cdef _date.Date dt = get_swap(self).maturityDate()
            return date_from_qldate(dt)

    def leg_BPS(self, Size j):
        return get_swap(self).legBPS(j)

    def leg_NPV(self, Size j):
        return get_swap(self).legNPV(j)

    def startDiscounts(self, Size j):
        return get_swap(self).startDiscounts(j)

    def endDiscounts(self, Size j):
        return get_swap(self).endDiscounts(j)

    def npv_date_discount(self):
        return get_swap(self).npvDateDiscount()

    def leg(self, int i):
        cdef Leg leg = Leg.__new__(Leg)
        leg._thisptr = get_swap(self).leg(i)
        return leg

    def __getitem__(self, int i):
        cdef Leg leg = Leg.__new__(Leg)
        leg._thisptr = get_swap(self).leg(i)
        return leg
