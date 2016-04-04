"""
 Copyright (C) 2016, Enthought Inc
 Copyright (C) 2016, Patrick Henaff

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
"""

from quantlib.indexes.regions import (
    AustraliaRegion, EURegion, FranceRegion, UKRegion, USRegion)

from quantlib.util.object_registry import ObjectRegistry

REGISTERED_REGION = [
    AustraliaRegion, EURegion, FranceRegion, UKRegion, USRegion]

def initialize_region_registry():

    registry = ObjectRegistry('Region')

    for region_cls in REGISTERED_REGION:
        region = region_cls()
        registry.register(region.code, region)

    return registry

REGISTRY = initialize_region_registry()
region_from_name = REGISTRY.from_name
