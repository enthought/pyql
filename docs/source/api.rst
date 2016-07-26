Reference documentation for the :mod:`quantlib` package
=======================================================

The API of the Python wrappers try to be as close as possible to the C++
original source but keeping a Pythonic simple access to classes, methods and
functions. Most of the complex structures related to proper memory management
are completely hidden being the Python layers (for example boost::shared_ptr and Handle).

quantlib
--------

.. currentmodule:: quantlib.currency

.. autoclass:: Currency
    :members:

.. autoclass:: USDCurrency
    :members:

.. autoclass:: EURCurrency
    :members:

.. currentmodule:: quantlib.settings

.. autoclass:: Settings
    :members:

.. currentmodule:: quantlib.quotes

.. autoclass:: Quote
    :members:

.. autoclass:: SimpleQuote
    :members:

quantlib.indexes
----------------

.. currentmodule:: quantlib.index

.. autoclass:: Index
    :members:

.. currentmodule:: quantlib.indexes.interest_rate_index

.. autoclass:: InterestRateIndex
    :members:

.. currentmodule:: quantlib.indexes.ibor_index

.. autoclass:: IborIndex
    :members:

.. currentmodule:: quantlib.indexes.euribor

.. autoclass:: Euribor
    :members:

.. currentmodule:: quantlib.indexes.libor

.. autoclass:: Libor
    :members:

quantlib.instruments
--------------------


.. currentmodule:: quantlib.instruments.bonds

.. autoclass:: Bond
    :members:

.. autoclass:: FixedRateBond
    :members:

.. autoclass:: ZeroCouponBond
    :members:

.. currentmodule:: quantlib.instruments.option

.. autosummary::

.. autoclass:: VanillaOption
    :members:

quantlib.math
-------------

.. currentmodule:: quantlib.math.optimization

.. autoclass:: OptimizationMethod
    :members:

.. autoclass:: LevenbergMarquardt
    :members:

.. autoclass:: EndCriteria
    :members:


quantlib.model.equity
---------------------

.. currentmodule:: quantlib.models.equity.heston_model

.. autoclass:: HestonModel
    :members:

.. autoclass:: HestonModelHelper
    :members:

.. currentmodule:: quantlib.models.equity.bates_model

.. autoclass:: BatesModel
    :members:

.. autoclass:: BatesDetJumpModel
    :members:

.. autoclass:: BatesDoubleExpModel
    :members:

.. autoclass:: BatesDoubleExpDetJumpModel
    :members:

quantlib.pricingengines
-----------------------

.. automodule:: quantlib.pricingengines.blackformula

.. currentmodule:: quantlib.pricingengines.vanilla

.. autoclass:: PricingEngine
    :members:

.. autoclass:: VanillaOptionEngine
    :members:

.. autoclass:: AnalyticEuropeanEngine
    :members:

.. autoclass:: AnalyticHestonEngine
    :members:

.. autoclass:: BaroneAdesiWhaleyApproximationEngine
    :members:

.. autoclass:: BatesEngine
    :members:

.. autoclass:: BatesDetJumpEngine
    :members:

.. autoclass:: BatesDoubleExpEngine
    :members:

.. autoclass:: BatesDoubleExpDetJumpEngine
    :members:

quantlib.processes
------------------

.. currentmodule:: quantlib.processes.black_scholes_process

.. autoclass:: GeneralizedBlackScholesProcess
    :members:

.. autoclass:: BlackScholesMertonProcess
    :members:

.. currentmodule:: quantlib.processes.bates_process

.. autoclass:: BatesProcess
    :members:

.. currentmodule:: quantlib.processes.heston_process

.. autoclass:: HestonProcess
    :members:

quantlib.termstructures
-----------------------

.. currentmodule:: quantlib.termstructures.volatility.equityfx.black_vol_term_structure

.. autoclass:: BlackVolTermStructure
    :members:

.. autoclass:: BlackConstantVol
    :members:

.. currentmodule:: quantlib.termstructures.yields.api

.. autoclass:: YieldTermStructure
    :members:

.. autoclass:: FlatForward
    :members:

.. autoclass:: ZeroCurve
    :members:

.. autoclass:: RateHelper
    :members:

.. autoclass:: DepositRateHelper

.. automodule:: quantlib.termstructures.yields.piecewise_yield_curve
    :members:

.. automodule:: quantlib.termstructures.credit.flat_forward
    :members:

.. automodule:: quantlib.termstructures.credit.interpolated_hazardrate_curve
    :members:

quantlib.time
-------------

.. currentmodule:: quantlib.time.date 

.. autoclass:: Date
    :members:
    :noindex:

.. autoclass:: Period
    :members:

.. currentmodule:: quantlib.time.calendar 

.. autoclass:: Calendar
    :members:

.. autoclass:: TARGET

.. autofunction:: holiday_list

.. currentmodule:: quantlib.time.daycounter

.. autoclass:: DayCounter
    :members:

.. currentmodule:: quantlib.time.schedule

.. autoclass:: Schedule
    :members:



