from . cimport _defines
from .utilities.null cimport Null
from .types cimport Integer, Real

QL_MIN_INTEGER = _defines.QL_MIN_INTEGER
QL_MAX_INTEGER = _defines.QL_MAX_INTEGER
QL_MIN_REAL = _defines.QL_MIN_REAL
QL_MAX_REAL = _defines.QL_MAX_REAL
QL_MIN_POSITIVE_REAL = _defines.QL_MIN_POSITIVE_REAL
QL_EPSILON = _defines.QL_EPSILON
QL_NULL_REAL = Null[Real]()
QL_NULL_INTEGER = Null[Integer]()
