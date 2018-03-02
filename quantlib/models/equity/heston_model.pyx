"""
 Copyright (C) 2011, Enthought Inc
 Copyright (C) 2011, Patrick Henaff

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
"""

include '../../types.pxi'

from cython.operator cimport dereference as deref

from libcpp.vector cimport vector

cimport _heston_model as _hm
cimport quantlib.models._calibration_helper as _ch
cimport quantlib.processes._heston_process as _hp
cimport quantlib._stochastic_process as _sp
cimport quantlib.termstructures.yields._flat_forward as _ffwd
cimport quantlib._quote as _qt
cimport quantlib.pricingengines._pricing_engine as _pe

from quantlib.handle cimport Handle, shared_ptr, static_pointer_cast
from quantlib.math.optimization cimport (Constraint,OptimizationMethod,
                                         EndCriteria)

from quantlib.processes.heston_process cimport HestonProcess
from quantlib.pricingengines.engine cimport PricingEngine
from quantlib.quotes cimport Quote
from quantlib.time.calendar cimport Calendar
from quantlib.time.date cimport Period
from quantlib.termstructures.yields.flat_forward cimport (
    YieldTermStructure
)
from quantlib.models.calibration_helper cimport CalibrationHelper


cdef class HestonModelHelper(CalibrationHelper):

    def __str__(self):
        return 'Heston model helper'

    def __init__(self,
        Period maturity,
        Calendar calendar,
        Real s0,
        Real strike_price,
        Quote volatility,
        YieldTermStructure risk_free_rate,
        YieldTermStructure dividend_yield,
        error_type=_ch.RelativePriceError
    ):
        # create handles
        cdef Handle[_qt.Quote] volatility_handle = \
                Handle[_qt.Quote](volatility._thisptr)

        self._thisptr = shared_ptr[_ch.CalibrationHelper](
            new _hm.HestonModelHelper(
                deref(maturity._thisptr),
                deref(calendar._thisptr),
                s0,
                strike_price,
                volatility_handle,
                risk_free_rate._thisptr,
                dividend_yield._thisptr,
                <_hm.CalibrationErrorType>error_type
            )
        )

cdef class HestonModel:

    def __init__(self, HestonProcess process):

        self._thisptr = shared_ptr[_hm.HestonModel](
            new _hm.HestonModel(static_pointer_cast[_hp.HestonProcess](
                process._thisptr))
        )

    def process(self):
        cdef HestonProcess process = HestonProcess.__new__(HestonProcess)
        process._thisptr = static_pointer_cast[_sp.StochasticProcess](
            self._thisptr.get().process())
        return process

    property theta:
        def __get__(self):
            return self._thisptr.get().theta()

    property kappa:
        def __get__(self):
            return self._thisptr.get().kappa()

    property sigma:
        def __get__(self):
            return self._thisptr.get().sigma()

    property rho:
        def __get__(self):
            return self._thisptr.get().rho()

    property v0:
        def __get__(self):
            return self._thisptr.get().v0()

    def calibrate(self, list helpers, OptimizationMethod method, EndCriteria
            end_criteria, Constraint constraint=None):

        #convert list to vector
        cdef vector[shared_ptr[_ch.CalibrationHelper]] helpers_vector

        cdef shared_ptr[_ch.CalibrationHelper] chelper
        for helper in helpers:
            chelper = (<HestonModelHelper>helper)._thisptr
            helpers_vector.push_back(chelper)

        if constraint is None:
            self._thisptr.get().calibrate(
                helpers_vector,
                deref(method._thisptr.get()),
                deref(end_criteria._thisptr.get()))
        else:
            self._thisptr.get().calibrate(
                helpers_vector,
                deref(method._thisptr.get()),
                deref(end_criteria._thisptr.get()),
                deref(constraint._thisptr.get()))
