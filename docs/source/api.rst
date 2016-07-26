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
    :undoc-members:
    :noindex:

.. currentmodule:: quantlib.settings

.. autoclass:: Settings
    :members:
    :undoc-members:
    :noindex:

:mod:`quantlib.settings`
------------------------
.. automodule:: quantlib.settings
    :members:
    :undoc-members:
    :noindex:

:mod:`quantlib.quotes`
----------------------
.. automodule:: quantlib.quotes
    :members:
    :undoc-members:
    :noindex:

:mod:`quantlib.indexes`
-----------------------
.. currentmodule:: quantlib.index

.. autoclass:: Index
    :members:
    :noindex:

.. currentmodule:: quantlib.indexes.interest_rate_index

.. autoclass:: InterestRateIndex
    :members:
    :noindex:

.. currentmodule:: quantlib.indexes.ibor_index

.. autoclass:: IborIndex
    :members:
    :noindex:

.. currentmodule:: quantlib.indexes.euribor

.. autoclass:: Euribor
    :members:
    :noindex:

.. currentmodule:: quantlib.indexes.libor

.. autoclass:: Libor
    :members:
    :noindex:

quantlib.instruments
--------------------

.. currentmodule:: quantlib.instruments.bonds

.. autoclass:: Bond
    :members:
    :noindex:

.. autoclass:: FixedRateBond
    :members:
    :noindex:

.. autoclass:: ZeroCouponBond
    :members:
    :noindex:

.. currentmodule:: quantlib.instruments.option

.. autosummary::

.. autoclass:: VanillaOption
    :members:
    :noindex:

quantlib.math
-------------

.. currentmodule:: quantlib.math.optimization

.. autoclass:: OptimizationMethod
    :members:
    :noindex:

.. autoclass:: LevenbergMarquardt
    :members:
    :noindex:

.. autoclass:: EndCriteria
    :members:
    :noindex:


quantlib.model.equity
---------------------

.. currentmodule:: quantlib.models.equity.heston_model

.. autoclass:: HestonModel
    :members:
    :noindex:

.. autoclass:: HestonModelHelper
    :members:
    :noindex:

.. currentmodule:: quantlib.models.equity.bates_model

.. autoclass:: BatesModel
    :members:
    :noindex:

.. autoclass:: BatesDetJumpModel
    :members:
    :noindex:

.. autoclass:: BatesDoubleExpModel
    :members:
    :noindex:

.. autoclass:: BatesDoubleExpDetJumpModel
    :members:
    :noindex:

:mod:`quantlib.pricingengines`
------------------------------

.. automodule:: quantlib.pricingengines.blackformula

.. automodule:: quantlib.pricingengines.engine

.. automodule:: quantlib.pricingengines.vanilla
.. currentmodule:: quantlib.pricingengines.vanilla.vanilla

.. autoclass:: VanillaOptionEngine
    :members:
    :noindex:

.. autoclass:: AnalyticEuropeanEngine
    :members:
    :noindex:

.. autoclass:: AnalyticHestonEngine
    :members:
    :noindex:

.. autoclass:: BaroneAdesiWhaleyApproximationEngine
    :members:
    :noindex:

.. autoclass:: BatesEngine
    :members:
    :noindex:

.. autoclass:: BatesDetJumpEngine
    :members:
    :noindex:

.. autoclass:: BatesDoubleExpEngine
    :members:
    :noindex:

.. autoclass:: BatesDoubleExpDetJumpEngine
    :members:
    :noindex:

:mod:`quantlib.processes`
-------------------------

.. currentmodule:: quantlib.processes.black_scholes_process

.. autoclass:: GeneralizedBlackScholesProcess
    :members:
    :noindex:

.. autoclass:: BlackScholesMertonProcess
    :members:
    :noindex:

.. currentmodule:: quantlib.processes.bates_process

.. autoclass:: BatesProcess
    :members:
    :noindex:

.. currentmodule:: quantlib.processes.heston_process

.. autoclass:: HestonProcess
    :members:
    :noindex:

:mod:`quantlib.termstructures`
------------------------------

.. automodule:: quantlib.termstructures.volatility.equityfx.black_vol_term_structure
   :members:
   :noindex:

.. currentmodule:: quantlib.termstructures.yields.api

.. autoclass:: YieldTermStructure
    :members:
    :noindex:

.. autoclass:: FlatForward
    :members:

.. autoclass:: ZeroCurve
    :members:
    :noindex:

.. autoclass:: RateHelper
    :members:
    :noindex:

.. autoclass:: DepositRateHelper
    :members:
    :noindex:

.. automodule:: quantlib.termstructures.yields.piecewise_yield_curve
    :members:

.. automodule:: quantlib.termstructures.credit.flat_forward
    :members:

.. automodule:: quantlib.termstructures.credit.interpolated_hazardrate_curve
    :members:

.. autoclass:: FlatForward
    :members:
    :noindex:

.. automodule:: quantlib.termstructures.credit.default_probability_helpers
    :members:
    :noindex:

.. automodule:: quantlib.termstructures.credit.piecewise_default_curve
    :members:
    :noindex:

.. automodule:: quantlib.termstructures.credit.flat_hazard_rate
    :members:
    :noindex:

:mod:`quantlib.time`
--------------------

.. automodule:: quantlib.time.date
    :members:
    :undoc-members:

.. py:data:: quantlib.time.date.Months
.. data:: quantlib.time.date.Days

.. currentmodule:: quantlib.time.calendar 

.. autoclass:: Calendar
    :members:
    :noindex:

.. autoclass:: TARGET

.. autofunction:: holiday_list

.. automodule:: quantlib.time.daycounter
   :members:

.. automodule:: quantlib.time.schedule
    :members:



