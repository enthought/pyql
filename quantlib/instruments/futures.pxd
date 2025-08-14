cdef extern from 'ql/instruments/futures.hpp' namespace 'QuantLib::Futures':
    cpdef enum FuturesType "QuantLib::Futures::Type":
        """Futures types enumeration

        These conventions specify the kind of futures types

        Attributes
        ----------
        IMM
           Chicago Mercantile International Money Market, i.e
           third Wednesday of March, June, September, December
        ASX
           Australian Security Exchange, i.e. second Friday
           of March, June, September, December
        Custom
           Other rules
        """
        IMM
        ASX
        Custom
