""" Definition of canonical data structures used in the
high-level functions of pyql. The data structures are all pandas DataFrames,
with defined column names and types. The data frames are empty, and should be
used as follows:

>>> import quantlib.reference.data_structures as df
>>> x = df.option_quotes.reindex(index=range(10))
"""

import numpy as np
from pandas import DataFrame

import quantlib.reference.names as nm


def option_quotes_template():

    return DataFrame(np.empty((0,), dtype=[(nm.TRADE_DATE, 'object'),
                                           (nm.STRIKE, 'f4'),
                                           (nm.EXPIRY_DATE, 'object'),
                                           (nm.OPTION_TYPE, 'a1'),
                                           (nm.SPOT, 'f4'),
                                           (nm.EXERCISE_STYLE, 'a4'),
                                           (nm.PRICE_BID, 'f4'),
                                           (nm.PRICE_ASK, 'f4')]))


def riskfree_dividend_template():
    return DataFrame.from_records(np.empty((1,),
                                  dtype=[(nm.DIVIDEND_YIELD, 'f4'),
                                         (nm.INTEREST_RATE, 'f4'),
                                         (nm.MATURITY_DATE, 'object')]),
                                  index=nm.MATURITY_DATE)
