""" Definition of the canonical data structures used in the
"mlab" high-level functions. The data structures are all pandas DataFrames,
with defined column names and types. The data frames are empty, and should be
used as follows:

>>> import quantlib.reference.data_structures as df
>>> x = df.option_quotes.reindex(index=range(10))
"""

import numpy as np
from pandas import DataFrame

from quantlib.reference.names import (TYPE, STRIKE, DTEXPIRY, SPOT,
                                    DIVRATE, RISKFREERATE,DTMATURITY)

option_quotes = DataFrame(np.empty((0,), dtype=[(TYPE, 'f4'), (STRIKE, 'f4'),
                                  (DTEXPIRY, 'f4'), (SPOT, 'f4')]))


riskfree_dividend = DataFrame.from_records(np.empty((0,),
                                                    dtype=[(DIVRATE,'f4'),
                                                    (RISKFREERATE,'f4'),
                                                    (DTMATURITY,'object')]),
                              index=DTMATURITY)


