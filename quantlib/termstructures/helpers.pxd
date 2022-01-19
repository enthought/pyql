cdef extern from 'ql/termstructures/bootstraphelper.hpp' namespace 'QuantLib::Pillar':
    cpdef enum Pillar "QuantLib::Pillar::Choice":
            MaturityDate
            LastRelevantDate
            CustomDate
