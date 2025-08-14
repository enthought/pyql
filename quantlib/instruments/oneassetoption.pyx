cdef class OneAssetOption(Option):

    cdef inline _oa.OneAssetOption* as_ptr(self) noexcept nogil:
        return <_oa.OneAssetOption*>self._thisptr.get()

    @property
    def delta(self):
        return self.as_ptr().delta()

    @property
    def delta_forward(self):
        return self.as_ptr().deltaForward()

    @property
    def elasticity(self):
        return self.as_ptr().elasticity()

    @property
    def gamma(self):
        return self.as_ptr().gamma()

    @property
    def theta(self):
        return self.as_ptr().theta()

    @property
    def theta_per_day(self):
        return self.as_ptr().thetaPerDay()

    @property
    def vega(self):
        return self.as_ptr().vega()

    @property
    def rho(self):
        return self.as_ptr().rho()

    @property
    def dividend_rho(self):
        return self.as_ptr().dividendRho()

    @property
    def strike_sensitivity(self):
        return self.as_ptr().strikeSensitivity()

    @property
    def itm_cash_probability(self):
        return self.as_ptr().itmCashProbability()
