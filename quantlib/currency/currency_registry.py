from .currencies import *
from ..util.object_registry import ObjectRegistry

REGISTERED_CURRENCY = [
    USDCurrency, EURCurrency, GBPCurrency, JPYCurrency, CHFCurrency,
    AUDCurrency, DKKCurrency, INRCurrency, HKDCurrency, NOKCurrency,
    NZDCurrency, PLNCurrency, SEKCurrency, SGDCurrency, ZARCurrency
]

def initialize_currency_registry():

    registry = ObjectRegistry('Currency')

    for currency_cls in REGISTERED_CURRENCY:
        currency = currency_cls()
        registry.register(currency.code, currency)

    return registry

REGISTRY = initialize_currency_registry()
currency_from_name = REGISTRY.from_name
