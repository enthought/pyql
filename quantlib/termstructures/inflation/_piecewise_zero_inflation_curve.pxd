cdef extern from 'ql/termstructures/inflation/piecewisezeroinflationcurve.hpp' namespace 'QuantLib':
    cdef cppclass PiecewiseZeroInflationCurve[T,I](
        const Date& referenceDate,
        const Calendar& calendar,
        const DayCounter& dayCounter,
        const Period& lag,
        Frequency frequency,
        bool index_is_interpolated,
        Rate baseZeroRate,
        const Handle[YieldTermStructure]& nominal_ts,
        const std::vector<boost::shared_ptr<typename Traits::helper> >&
        instruments,
        Real accuracy = 1.0e-12,
        const Interpolator& i = Interpolator())
