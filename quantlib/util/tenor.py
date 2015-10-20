'''
Tenor class

@author: Bart Mosley
@copyright: BG Research LLC, 2011
@modified: July 2012 to replace SWIG Quantlib bindings with pyQL Cython code.

'''
from datetime import date 

from pybg.enums import TimeUnits

from pybg.quantlib.time.api import *

from pybg.ql import pydate_from_qldate, qldate_from_pydate


class Tenor(object):
    _tenorUnits = {'D': TimeUnits.Days,
                   'W': TimeUnits.Weeks, 
                   'M': TimeUnits.Months, 
                   'Y': TimeUnits.Years}
    _tenorLength = {'D': 365,
                   'W': 52, 
                   'M': 12, 
                   'Y': 1}  # useful for sorting
    
    def __init__(self, txt):
        firstNum = True
        firstCh = True
        numTxt = ""
        unit="Y"
        for i in str(txt).replace(' ', ''):
            if i.isalnum():
                if i.isdigit():
                    numTxt = numTxt + i
                    
                    if firstNum:
                        firstNum = False
                elif i.isalpha():
                    if firstCh and (i.upper() in self._tenorUnits):                       
                        unit = i.upper()
                        firstCh = False
            else:
                pass
                
        if(firstNum):
            numTxt="0"
        
        self.length = int(numTxt)
        self.unit = unit
        self.timeunit = self._tenorUnits.get(self.unit, Days)

    @classmethod 
    def fromdates(cls, settle, maturity, daycount=ActualActual()):
        '''
        Returns the tenor associated with settlement and maturity.
        
        '''
        settle = qldate_from_pydate(settle)
        maturity = qldate_from_pydate(maturity)
        years_ = daycount.year_fraction(settle, maturity)
        
        if years_ >= 1.0:
            t = "".join((str(int(round(years_))),"Y"))
        else:
            t = "".join((str(int(round(years_*12.))),"M"))
        
        return cls(t)
    
    def __str__(self):
        return str(self.length)+self.unit
    
    def __repr__(self):
        return "<Tenor:"+self.__str__()+">"
    
        
    def numberOfPeriods(self, frequency=Semiannual):
        '''Returns the number of integer periods in the tenor 
           based on the given frequency.
        
        '''
        return int(self.term * int(frequency))
    
    def advance(self, 
                date_, 
                convention=Unadjusted, 
                calendar=TARGET(), 
                reverse=False,
                aspy=True):
        
        date_ = qldate_from_pydate(date_)
        length_ = self.length if not reverse else -self.length
        
        date_ = calendar.advance(date_, length_, self.timeunit, 
                                 convention=convention)
                                 
        return date_ if not aspy else pydate_from_qldate(date_)
    
    def schedule(self, settle_, maturity_, convention=Unadjusted,
                       calendar=TARGET(),
                       aspy=True):
        '''
        tenor('3m').schedule(settleDate, maturityDate) or
        tenor('3m').schedule(settleDate, '10Y')
        
        gives a schedule of dates from settleDate to maturity with a 
        short front stub.
        '''
        settle_ = qldate_from_pydate(settle_)
        mty_ = qldate_from_pydate(maturity_)
        
        sched = []
        if type(maturity_) == str and not mty_:
            maturity_ = Tenor(maturity_).advance(settle_, 
                                                 convention=convention,
                                                 calendar=calendar
                                                 )
        else:
            maturity_ = mty_
            
        dt = maturity_
        while dt.serial > settle_.serial:
            sched.append(calendar.adjust(dt, convention))
            dt = self.advance(dt, reverse=True)
            
        else:
            sched.append(settle_)
            
        sched.sort(key=lambda dt: dt.serial)
        
        if aspy:
            sched = [pydate_from_qldate(dt) for dt in sched]
        
        return sched
                    
    @property
    def term(self):
        '''
        Length of tenor in years.
        '''
        return float(self.length) / float(self._tenorLength.get(self.unit, 1.0))
        
    @property
    def QLPeriod(self):
        return Period(self.length, self.timeunit)
    
    @property
    def tuple(self):
        return (self.length, self.timeunit)
        
        