include '../../../types.pxi'
from cython.operator cimport dereference as deref
from quantlib.time.date cimport Date, Period
from quantlib.handle cimport shared_ptr
from ..smilesection cimport SmileSection
from ..volatilitytype import VolatilityType

cdef class SwaptionVolatilityStructure(VolatilityTermStructure):

    cdef inline _svs.SwaptionVolatilityStructure* get_svs(self) nogil:
        return self._derived_ptr.get()

    @staticmethod
    cdef Handle[_svs.SwaptionVolatilityStructure] swaption_vol_handle(vol):
        if isinstance(vol, SwaptionVolatilityStructure):
            return Handle[_svs.SwaptionVolatilityStructure]((<SwaptionVolatilityStructure>vol)._derived_ptr, False)
        elif isinstance(vol, HandleSwaptionVolatilityStructure):
            return (<HandleSwaptionVolatilityStructure>vol).handle
        else:
            raise TypeError("vol needs to be either a SwaptionVolatilityStructure or a HandleSwaptionVolatilityStructure")

    def volatility(self, option_date, swap_date, Rate strike,
                   bool extrapolate=False):
        if isinstance(swap_date, Period):
            if isinstance(option_date, Period):
                return self.get_svs().volatility(
                    deref((<Period>option_date)._thisptr),
                    deref((<Period>swap_date)._thisptr),
                    strike,
                    extrapolate)
            elif isinstance(option_date, Date):
                return self.get_svs().volatility(
                    deref((<Date>option_date)._thisptr),
                    deref((<Period>swap_date)._thisptr),
                    strike,
                    extrapolate)
            elif isinstance(option_date, float):
                return self.get_svs().volatility(
                    <Time>option_date,
                    deref((<Period>swap_date)._thisptr),
                    strike,
                    extrapolate)
            else:
                raise TypeError('option_date needs to be a Period, Date or Time')
        elif isinstance(swap_date, float):
            if isinstance(option_date, Period):
                return self.get_svs().volatility(
                    deref((<Period>option_date)._thisptr),
                    <Time>swap_date,
                    strike,
                    extrapolate)
            elif isinstance(option_date, Date):
                return self.get_svs().volatility(
                    deref((<Date>option_date)._thisptr),
                    <Time>swap_date,
                    strike,
                    extrapolate)
            elif isinstance(option_date, float):
                return self.get_svs().volatility(
                    <Time>option_date,
                    <Time>swap_date,
                    strike,
                    extrapolate)
            else:
                raise TypeError('option_date needs to be a Period, Date or Time')
        else:
            raise TypeError('swap_date needs to be a Period or a Time')


    def smile_section(self, Period option_tenor not None,
                      Period swap_tenor not None,
                      bool extrapolation=False):
        cdef SmileSection r = SmileSection.__new__(SmileSection)
        r._thisptr = self.get_svs().smileSection(deref(option_tenor._thisptr),
                                                      deref(swap_tenor._thisptr),
                                                      extrapolation)
        return r

    def black_variance(self, option_date, swap_date, Rate strike,
                       bool extrapolate=False):
        if isinstance(swap_date, Period):
            if isinstance(option_date, Period):
                return self.get_svs().blackVariance(
                    deref((<Period>option_date)._thisptr),
                    deref((<Period>swap_date)._thisptr),
                    strike,
                    extrapolate)
            elif isinstance(option_date, Date):
                return self.get_svs().blackVariance(
                    deref((<Date>option_date)._thisptr),
                    deref((<Period>swap_date)._thisptr),
                    strike,
                    extrapolate)
            elif isinstance(option_date, float):
                return self.get_svs().blackVariance(
                    <Time>option_date,
                    deref((<Period>swap_date)._thisptr),
                    strike,
                    extrapolate)
            else:
                raise TypeError('option_date needs to be a Period, Date or Time')
        elif isinstance(swap_date, float):
            if isinstance(option_date, Period):
                return self.get_svs().blackVariance(
                    deref((<Period>option_date)._thisptr),
                    <Time>swap_date,
                    strike,
                    extrapolate)
            elif isinstance(option_date, Date):
                return self.get_svs().blackVariance(
                    deref((<Date>option_date)._thisptr),
                    <Time>swap_date,
                    strike,
                    extrapolate)
            elif isinstance(option_date, float):
                return self.get_svs().blackVariance(
                    <Time>option_date,
                    <Time>swap_date,
                    strike,
                    extrapolate)
            else:
                raise TypeError('option_date needs to be a Period, Date or Time')
        else:
            raise TypeError('swap_date needs to be a Period or a Time')

    def shift(self, option_date, swap_date, bool extrapolate=False):
        if isinstance(swap_date, Period):
            if isinstance(option_date, Period):
                return self.get_svs().shift(
                    deref((<Period>option_date)._thisptr),
                    deref((<Period>swap_date)._thisptr),
                    extrapolate)
            elif isinstance(option_date, Date):
                return self.get_svs().shift(
                    deref((<Date>option_date)._thisptr),
                    deref((<Period>swap_date)._thisptr),
                    extrapolate)
            elif isinstance(option_date, float):
                return self.get_svs().shift(
                    <Time>option_date,
                    deref((<Period>swap_date)._thisptr),
                    extrapolate)
            else:
                raise TypeError('option_date needs to be a Period, Date or Time')
        elif isinstance(swap_date, float):
            if isinstance(option_date, Period):
                return self.get_svs().shift(
                    deref((<Period>option_date)._thisptr),
                    <Time>swap_date,
                    extrapolate)
            elif isinstance(option_date, Date):
                return self.get_svs().shift(
                    deref((<Date>option_date)._thisptr),
                    <Time>swap_date,
                    extrapolate)
            elif isinstance(option_date, float):
                return self.get_svs().shift(
                    <Time>option_date,
                    <Time>swap_date,
                    extrapolate)
            else:
                raise TypeError('option_date needs to be a Period, Date or Time')
        else:
            raise TypeError('swap_date needs to be a Period or a Time')

    @property
    def volatility_type(self):
        return VolatilityType(self.get_svs().volatilityType())


cdef class HandleSwaptionVolatilityStructure:
    def __init__(self, SwaptionVolatilityStructure structure=None, bool register_as_observer=True):
        if structure is not None:
            self.handle = RelinkableHandle[_svs.SwaptionVolatilityStructure](structure._derived_ptr, register_as_observer)

    def link_to(self, SwaptionVolatilityStructure structure not None, bool register_as_observer=True):
        self.handle.linkTo(structure._derived_ptr, register_as_observer)

    @property
    def current_link(self):
        cdef SwaptionVolatilityStructure instance = SwaptionVolatilityStructure.__new__(SwaptionVolatilityStructure)
        if not self.handle.empty():
            instance._derived_ptr = self.handle.currentLink()
            instance._thisptr = instance._derived_ptr
            return instance
        else:
            raise ValueError("can't dereference empty handle")
