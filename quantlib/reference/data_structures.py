""" Definition of canonical data structures used in the
high-level functions. The data structures are all pandas DataFrames,
with defined column names and types. The data frames are empty, and should be
used as follows:

>>> import quantlib.reference.data_structures as df
>>> x = df.option_quotes.reindex(index=range(10))
"""

import numpy as np
from pandas import DataFrame

import quantlib.reference.names as nm


def option_quotes_template():
    
    return DataFrame(np.empty((0,), dtype=[(nm.OPTION_TYPE, 'f4'),
                                           (nm.STRIKE, 'f4'),
                                           (nm.EXPIRY_DATE, 'f4'),
                                           (nm.SPOT, 'f4')]))



def riskfree_dividend_template():
    return DataFrame.from_records(np.empty((0,),
                                  dtype=[(nm.DIVIDEND_YIELD,'f4'),
                                         (nm.INTEREST_RATE,'f4'),
                                         (nm.MATURITY_DATE,'object')]),
                                  index=nm.MATURITY_DATE)


