"""
 Copyright (C) 2013, Enthought Inc
 Copyright (C) 2013, Patrick Henaff
 Copyright (c) 2012 BG Research LLC
 
 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
"""

cimport _cashflow as _cf
cimport quantlib.time._date as _date
cimport quantlib.time.date as date

from libcpp.vector cimport vector
from cython.operator cimport dereference as deref

from quantlib.handle cimport shared_ptr
from quantlib.time.date import pydate_from_qldate

cdef class CashFlow:
    """Abstract Base Class.
    
    Use SimpleCashFlow instead
    
    """
    def __cinit__(self):
        self._thisptr = NULL

    def __init__(self):
        raise ValueError(
            'This is an abstract class.'
        )

    def __dealloc__(self):
        if self._thisptr is not NULL:
            del self._thisptr
  
    property date:
        def __get__(self):
            cdef _date.Date cf_date
            if self._thisptr:
                cf_date = self._thisptr.get().date()
                return date.date_from_qldate(cf_date)
            else:
                return None
                
    property amount:
        def __get__(self):
            if self._thisptr:
                return self._thisptr.get().amount()
            else:
                return None


cdef class SimpleCashFlow(CashFlow):

    def __init__(self, Real amount, date.Date cfdate):
        cdef _date.Date* _cfdate
        _cfdate = <_date.Date*>((<date.Date>cfdate)._thisptr.get())
        
        self._thisptr = new shared_ptr[_cf.CashFlow]( \
                            new _cf.SimpleCashFlow(amount,
                                                   deref(_cfdate))
                            )

    def __str__(self):
        return 'Simple Cash Flow: %f, %s' % (self.amount,
                                             self.date)
                                     
cdef object leg_items(vector[shared_ptr[_cf.CashFlow]] leg):
    cdef int i
    cdef shared_ptr[_cf.CashFlow] _thiscf
    cdef date.Date _thisdate
    cdef int size = leg.size()
    
    itemlist = []
    for i from 0 <= i < size:
        _thiscf = leg.at(i)
        _thisdate = date.Date(_thiscf.get().date().serialNumber())
        
        itemlist.append((pydate_from_qldate(_thisdate),
                         _thiscf.get().amount()))
        
    return itemlist

cdef class SimpleLeg:

    def __cinit__(self):
        self._thisptr = NULL

    def __init__(self, leg):
        '''Takes as input a list of (amount, Date) tuples.
        
        '''
        #TODO: make so that it handles pydate as well as QL Dates.
        cdef shared_ptr[_cf.CashFlow] *_thiscf
        cdef date.Date testDate
        cdef _date.Date _testDate
        cdef _date.Date *_thisdate
        cdef int i
        
        self._thisptr = new shared_ptr[vector[shared_ptr[_cf.CashFlow]]](\
                    new vector[shared_ptr[_cf.CashFlow]]() 
                    )
                    
        for i in range(len(leg)):
            _thisamount = leg[i][0]
            _thisdate = <_date.Date*>((<date.Date>leg[i][1])._thisptr.get())
            
            _thiscf = new shared_ptr[_cf.CashFlow]( \
                                new _cf.SimpleCashFlow(_thisamount,
                                                       deref(_thisdate))
                                                  )   

            self._thisptr.get().push_back(deref(_thiscf))
        
    def __dealloc__(self):
        if self._thisptr is not NULL:
            del self._thisptr
    
    property size:
        def __get__(self):
            cdef int size = self._thisptr.get().size()
            return size
            
    property items:
        def __get__(self):
            '''Return Leg as (amount, date) list
            
            '''
            cdef vector[shared_ptr[_cf.CashFlow]] leg = \
                                        deref(self._thisptr.get())
            return leg_items(leg)
            



