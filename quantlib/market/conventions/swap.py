import collections

import tabulate

labels = [
    "market", "currency", "settlement_days", "fixed_leg_period",
    "fixed_leg_daycount", "fixed_leg_convention", "floating_leg_reference",
    "floating_leg_period", "floating_leg_daycount", "floating_leg_convention",
    "calendar"
]

# column labels for pretty printing
labels_short = [
    "market", "currency", "settle", "fx per", "fx d/c", "fx conv",
    "fl ref", "fl per", "fl d/c", "fl conv", "calendar"
]

data = [
    ("USD(NY)", "USD", 2, "6M", "30/360", "ModifiedFollowing", "LIBOR", "3M",
     "ACT/360", "ModifiedFollowing", "TARGET"),
    ("USD(LONDON)", "USD", 2, "1Y", "ACT/360", "ModifiedFollowing","LIBOR",
     "3M", "ACT/360", "ModifiedFollowing", "TARGET"),
    ("EUR:1Y", "EUR", 2, "1Y", "30/360", "Unadjusted", "Euribor", "3M",
     "ACT/360", "ModifiedFollowing", "TARGET"),
    ("EUR:>1Y", "EUR", 2, "1Y", "30/360", "Unadjusted", "Euribor", "6M",
     "ACT/360", "ModifiedFollowing", "TARGET"),
    ("GBP:1Y", "GBP", 0, "1Y", "ACT/365", "ModifiedFollowing", "LIBOR", "3M",
     "ACT/365", "ModifiedFollowing", "GBR"),
    ("GBP:>1Y", "GBP", 0, "6M", "ACT/365", "ModifiedFollowing", "LIBOR", "6M",
     "ACT/365", "ModifiedFollowing", "GBR"),
    ("JPY(Tibor)", "JPY", 2, "6M", "ACT/365", "ModifiedFollowing", "Tibor",
     "3M", "ACT/365", "ModifiedFollowing", "JPN"),
    ("JPY(Libor)", "JPY", 2, "6M", "ACT/365", "ModifiedFollowing", "LIBOR",
     "6M", "ACT/360", "ModifiedFollowing", "JPN"),
    ("CHF:1Y", "CHF", 2, "1Y", "30/360", "ModifiedFollowing", "LIBOR", "3M",
     "ACT/360", "ModifiedFollowing", "CHE"),
    ("CHF:>1Y", "CHF", 2, "1Y", "30/360", "ModifiedFollowing", "LIBOR", "6M",
     "ACT/360", "ModifiedFollowing", "CHE")
]

row = collections.namedtuple("Row", labels[1:])

def load():
    _conventions = {}
    for line in data:
        _conventions[line[0]] = row(line[1:])
    return _conventions

conventions = load()

def help():
    table = tabulate.tabulate(data, headers=labels_short)
    return table

def params(market):
    return conventions[market]

