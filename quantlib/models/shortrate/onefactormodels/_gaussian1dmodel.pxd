from libcpp cimport bool
from quantlib.time._date cimport Date
from quantlib.types cimport Rate, Real, SizeTime
from quantlib.handle cimport Handle, shared_ptr
from quantlib.termstructures._yield_term_structure cimport YieldTermStructure
from quantlib.instruments.option cimport OptionType
from ..._model cimport TermStructureConsistentModel

cdef extern from 'ql/models/shortrate/onefactormodels/gaussian1dmodel.hpp' namespace 'QuantLib' nogil:
    cdef cppclass Gaussian1dModel(TermStructureConsistentModel):
        const shared_ptr[StochasticProcess1D] stateProcess()

        const Real numeraire(const Time t,
                             const Real y,
                             const Handle[YieldTermStructure] yts # Handle[YieldTermstructure]()
                             ) const
        const Real zerobond(const Time T,
                            const Time t, # = 0.0,
                            const Real y, # = 0.0,
                            const Handle[YieldTermStructure] &yts# = Handle<YieldTermStructure>());
                            )

        const Real numeraire(const Date &referenceDate,
                             const Real y, # = 0.0,
                             const Handle[YieldTermStructure] &yts, # = Handle<YieldTermStructure>()) const;
                             ) const
        const Real zerobond(const Date &maturity,
                            const Date &referenceDate, # = Null<Date>(),
                            const Real y, # = 0.0,
                            const Handle<YieldTermStructure> &yts, #= Handle<YieldTermStructure>()) const;
                            ) const
        const Real zerobondOption(const OptionType &type,
                                  const Date &expiry,
                                  const Date &valueDate,
                                  const Date &maturity,
                                  const Rate strike,
                                  const Date &referenceDate, # = Null<Date>(),
                                  const Real y, # = 0.0,
                                  const Handle[YieldTermStructure] &yts, #= Handle<YieldTermStructure>(),
                                  const Real yStdDevs, # = 7.0,
                                  const Size yGridPoints, # = 64,
                                  const bool extrapolatePayoff, # = true,
                                  const bool flatPayoffExtrapolation,# = false) const;
                                  ) const
        const Real forwardRate(const Date &fixing,
                               const Date &referenceDate, # = Null<Date>(),
                               const Real y, # = 0.0,
                               shared_ptr[IborIndex] iborIdx # =ext::shared_ptr<IborIndex>()) const;
                               ) const
        const Real swapRate(const Date &fixing,
                            const Period &tenor,
                            const Date &referenceDate # = Null<Date>(),
                            const Real y # = 0.0,
                            shared_ptr[SwapIndex] swapIdx #= ext::shared_ptr<SwapIndex>()) const;
                            ) const

        const Real swapAnnuity(const Date &fixing,
                               const Period &tenor,
                               const Date &referenceDate # = Null<Date>(),
                               const Real y #= 0.0,
                               shared_ptr[SwapIndex] swapIdx, #= shared_ptr<SwapIndex>()) const
                               ) const
