import collections
from quantlib.util.prettyprint import prettyprint

class DataStore(object):
    _labels = None
    _data = None
    _labels_short = None

    @classmethod
    def match(**kwargs):
        """
        Match all records on keys
        """


class SwapData(object):
    _labels = ["market",
               "currency",
                "fixing_days",
                "fixed_leg_period",
                "fixed_leg_daycount",
                "floating_leg_reference",
                "floating_leg_period",
                "floating_leg_daycount",
                "calendar"]

    # column labels for pretty printing
    _labels_short = ["market",
                     "currency",
                "fixing",
                "fx per",
                "fx d/c",
                "fl ref",
                "fl per",
                "fl d/c",
                "calendar"]


    _data = [("USD(NY)",  "USD",  2, "6M", "30/360",  "LIBOR",   "3M", "ACT/360", "TARGET"),
          ("USD(LONDON)", "USD",  2, "1Y", "ACT/360", "LIBOR",   "3M", "ACT/360", "TARGET"),
          ("EUR:1Y",      "EUR",  2, "1Y", "30/360",  "Euribor", "3M", "ACT/360", "TARGET"),
          ("EUR:>1Y",     "EUR",  2, "1Y", "30/360",  "Euribor", "6M", "ACT/360", "TARGET"),
          ("GBP:1Y",      "GBP",  0, "1Y", "ACT/365", "LIBOR",   "3M", "ACT/365", "GBR"),
          ("GBP:>1Y",     "GBP",  0, "6M", "ACT/365", "LIBOR",   "6M", "ACT/365", "GBR"),
          ("JPY(Tibor)",  "JPY",  2, "6M", "ACT/365", "Tibor",   "3M", "ACT/365", "JPN"),
          ("JPY(Libor)",  "JPY",  2, "6M", "ACT/365", "LIBOR",   "6M", "ACT/360", "JPN"),
          ("CHF:1Y",      "CHF",  2, "1Y", "30/360",  "LIBOR",   "3M", "ACT/360", "CHE"),
          ("CHF:>1Y",     "CHF",  2, "1Y", "30/360",  "LIBOR",   "6M", "ACT/360", "CHE")
          ]

    Row = collections.namedtuple("Row", _labels[1:])
    _dic = {}
    for line in _data:
        row = Row._make(line[1:])
        _dic[line[0]] = row

    @classmethod
    def help(self):
        _data_t = map(list, zip(*self._data))
        return prettyprint(self._labels_short, 'ssissssss', _data_t)

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

if __name__ == '__main__':
    params = {"currency":"USD",
              "floating_leg_reference":"LIBOR",
              "floating_leg_period":"3M"}

    row = SwapData.match(params)
