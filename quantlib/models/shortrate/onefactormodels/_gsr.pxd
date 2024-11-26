from libcpp.vector cimport vector
from quantlib.types cimport Real
from quantlib.time._date cimport Date
from quantlib.handle cimport Handle
from ._gaussian1dmodel cimport Gaussian1dModel
from ..._model cimport CalibratedModel


cdef extern from 'ql/models/shortrate/onefactormodels/gsr.hpp' namespace 'QuantLib' nogil:
    cdef cppclass Gsr(Gaussian1dModel, CalibratedModel):
          # constant mean reversion
          Gsr(const Handle[YieldTermStructure]& termStructure,
              vector[Date] volstepdates,
              const vector[Real]& volatilities,
              Real reversion,
              Real T #= 60.0);
              )
          # piecewise mean reversion (with same step dates as volatilities)
          Gsr(const Handle[YieldTermStructure]& termStructure,
              vector[Date] volstepdates,
              const vector[Real]& volatilities,
              const vector[Real]& reversions,
              Real T #= 60.0)
              )
          # constant mean reversion with floating model data
          Gsr(const Handle[YieldTermStructure]& termStructure,
              vector[Date] volstepdates,
              vector[Handle[Quote]] volatilities,
              const Handle[Quote]& reversion,
              Real T #= 60.0);
              )
          # piecewise mean reversion with floating model data
          Gsr(const Handle[YieldTermStructure]& termStructure,
              std::vector[Date] volstepdates,
              std::vector[Handle[Quote]] volatilities,
              std::vector[Handle[Quote]] reversions,
              Real T #= 60.0);
              )
