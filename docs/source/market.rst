Market
======

PyQL is primarily a wrapper around QuantLib, and strictly follows the QuantLib class structure. A casual look at the PyQL test
suite will convince the user that using QuantLib, or its PyQL wrapper, requires a pretty detailed understanding of its class
structure.

QuantLib is an industrial-strength pricing library. 

The number of market convention parameters that need to be supplied in order to perform the simplest calculation can be overwelming.  
Fortunately, there is some logic to this profusion of market conventions. 

In an attempt to bring some order and logic to this profusion of market conventions, PyQL introduces the notion of Market.
A Market is the virtual place where financial assets are traded. It defines all the conventions needed to quote prices, measure yield, compute yield curves from market quotes, etc. Examples of these virtual market places are:

* Fixed income markets
  * The US Treasury market
  * The US Libor market
  * The Euribor market
* Equity markets
  * US Equity

A market fulfills two functions: it is a dictionary of market conventions, and provides methods for performing
standard calculations on market quotes. This two functions are now detailed.

Repository of Trading Conventions
---------------------------------

A market provides the following information:

- The calendar of business days
- The daycount conventions 

Standard Calculations
---------------------

The methods that are defined are function of the type of market under consideration. For Fixed Income markets:

- Bootstrapping of yield curves from market quotes
- Direct calculation of discount factors

Market quotes
-------------

Market quotes are provided as a list of tuples. Each tuple includes 3 items:

- Α label that identifies the type of instrument: DEP/SWAP/FRA/ED
- The tenor, as a string of the form '1M', '10Y', '3W'
- A numeric quote

 
Creating a new market:
----------------------

.. code-block:: python
   
   m = market_factory('USD-Libor')



