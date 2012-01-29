Application User Interface
==========================

The API of the Python wrappers try to be as close as possible to the C++
original source but keeping a Pythonic simple access to classes, methods and
functions. Most of the complex structures related to proper memory management
are completely hidden being the Python layers (for example boost::shared_ptr and Handle).

quantlib.settings
-----------------

.. currentmodule:: quantlib.settings

.. autoclass:: Settings
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

quantlib.time.api
------------------

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
