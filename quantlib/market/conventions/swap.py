import collections

import tabulate

class SwapData(object):
    _labels = ["market",
               "currency",
               "settlement_days",
               "fixed_leg_period",
               "fixed_leg_daycount",
               "fixed_leg_convention",
               "floating_leg_reference",
               "floating_leg_period",
               "floating_leg_daycount",
               "floating_leg_convention",
               "calendar"]

    # column labels for pretty printing
    _labels_short = ["market", "currency", "settle", "fx per",
                     "fx d/c", "fx conv",
                     "fl ref", "fl per", "fl d/c", "fl conv",
                     "calendar"]

    _data = [
        ("USD(NY)", "USD", 2, "6M", "30/360", "ModifiedFollowing",
         "LIBOR", "3M", "ACT/360", "ModifiedFollowing", "TARGET"),
        ("USD(LONDON)", "USD", 2, "1Y", "ACT/360", "ModifiedFollowing",
         "LIBOR", "3M", "ACT/360", "ModifiedFollowing", "TARGET"),
        ("EUR:1Y", "EUR", 2, "1Y", "30/360", "Unadjusted",
         "Euribor", "3M", "ACT/360", "ModifiedFollowing", "TARGET"),
        ("EUR:>1Y", "EUR", 2, "1Y", "30/360", "Unadjusted",
         "Euribor", "6M", "ACT/360", "ModifiedFollowing", "TARGET"),
        ("GBP:1Y", "GBP", 0, "1Y", "ACT/365", "ModifiedFollowing",
         "LIBOR", "3M", "ACT/365", "ModifiedFollowing", "GBR"),
        ("GBP:>1Y", "GBP", 0, "6M", "ACT/365", "ModifiedFollowing",
         "LIBOR", "6M", "ACT/365", "ModifiedFollowing", "GBR"),
        ("JPY(Tibor)", "JPY", 2, "6M", "ACT/365", "ModifiedFollowing",
         "Tibor", "3M", "ACT/365", "ModifiedFollowing", "JPN"),
        ("JPY(Libor)", "JPY", 2, "6M", "ACT/365", "ModifiedFollowing",
         "LIBOR", "6M", "ACT/360", "ModifiedFollowing", "JPN"),
        ("CHF:1Y", "CHF", 2, "1Y", "30/360", "ModifiedFollowing",
         "LIBOR", "3M", "ACT/360", "ModifiedFollowing", "CHE"),
        ("CHF:>1Y", "CHF", 2, "1Y", "30/360", "ModifiedFollowing",
         "LIBOR", "6M", "ACT/360", "ModifiedFollowing", "CHE")
    ]

    Row = collections.namedtuple("Row", _labels[1:])
    _dic = {}
    for line in _data:
        row = Row._make(line[1:])
        _dic[line[0]] = row

    @classmethod
    def help(self):
        table = tabulate.tabulate(self._data, headers=self._labels_short)
        return table

    @classmethod
    def params(self, market):
        return self._dic[market]

    @classmethod
    def match(self, params):
        """
        Returns the row(s) that match the parameters
        """

        res = []
        for k, v in self._dic.items():
            row = vars(v)
            is_match = all([params[kp] == row[kp] for kp in params])
            if is_match:
                res.append(row)
        return res
