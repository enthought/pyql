Reference
=========

The mlab module provides high-level functions suitable for easily performing common quantitative finance calculations. These functions use as input standardized data structures that are provided to limit the amount of data transformation needed to string functions together.

The mlab functions often use pandas data frames as inputs. In order to encourage inter-operability between functions, we have defined a number of standard data structures. The column names of these data frames are defined in the ''names'' module. The standardized data structures should be created with the functions provided in the ''data_structures'' module. 


Names
-----

The column names of all datasets are defined in names.py. A column name should always be referenced by the corresponding variable name,
and not by a character string. For example, refer to the 'Strike' column of an option_quotes data
set by:

.. code-block:: python
   
   import quantlib.reference.names as nm
   strike = option_quotes[nm.STRIKE]
   
rather than:

.. code-block:: python
   
   strike = option_quotes['Strike']

 
Data Structures Templates
-------------------------

These data structures are defined to facilitate the inter-operability of the high level functions found in the 'mlab' module.

**Option Quotes**

This data structure contains the necessary data for calibrating a stochastic model for the underlying asset, also known as volatility model.

An option quotes data structure with 10 rows is created with the statements:

.. code-block:: python
   
   import quantlib.reference.data_structures as ds
   option_quotes = ds.option_quotes_template().reindex(index=range(10))


**Risk-free Rate and Dividends**

When calibrating a volatility model, the default algorithm is to compute the implied term structure of risk-free rate and dividend yield from the option data, using the call-put parity relationship. The result of this calculation is the 'riskfree_dividend' data structure.




