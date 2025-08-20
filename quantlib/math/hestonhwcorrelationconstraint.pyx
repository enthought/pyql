# Copyright (C) 2015, Enthought Inc
# Copyright (C) 2015, Patrick Henaff
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE.  See the license for more details.

from quantlib.handle cimport shared_ptr
from quantlib.math.optimization cimport Constraint
from . cimport _optimization as _opt
from . cimport _hestonhwcorrelationconstraint as _hhw

cdef class HestonHullWhiteCorrelationConstraint(Constraint):

    def __init__(self, double equity_short_rate_corr):
        self._thisptr = shared_ptr[_opt.Constraint](
            _hhw.constraint_factory(equity_short_rate_corr))

    def __str__(self):
        return 'Heston/Hull-White correlation constraint'
