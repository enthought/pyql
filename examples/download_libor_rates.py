"""
 Copyright (C) 2011, Enthought Inc
 Copyright (C) 2011, Patrick Henaff

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
"""

# This script shows how to download libor data
# (deposits and swap rates) from the FRB data repository
# and build a pandas time series of rates

import logging
import numpy as np
import os
import urllib

from pandas.io.parsers import read_csv
from datetime import date

logger = logging.getLogger(__name__)


FRB_DATE_FORMAT = '%m/%d/%Y'
FRB_URL = 'http://www.federalreserve.gov/datadownload/Output.aspx?' \
           'rel=H15&series=8f47c9df920bbb475f402efa44f35c29&lastObs=&' \
           'from=%s&to=%s&filetype=csv&label=include&layout=seriescolumn'


def get_frb_url(start, end):
    """
    Federal Reserve Board URL
    Construct this URL at 'http://www.federalreserve.gov/datadownload
    """

    url = FRB_URL % (
        start.strftime(FRB_DATE_FORMAT), end.strftime(FRB_DATE_FORMAT)
    )
    return url


def good_row(z):
    """
    Retain days with no gaps (0 or NaN) in data
    """

    try:
        nans = np.isnan(z)
        zeros = z == 0
        mask = nans | zeros
        isnan_or_has_zero = mask.values.any()

        res = not isnan_or_has_zero
    except Exception as exc:
        logger.exception(exc)
        res = False
    return res


def load_frb_data(target_file='data/frb_h15.csv'):
    """ Load the FRB dataset from the target file if it exists or download
    the dataset from the web.

    """

    if not os.path.isfile(target_file):
        logger.info('Downloading FRB data')
        url = get_frb_url(start=date(2000, 1, 1),
                          end=date(2011, 12, 31))
        frb_site = urllib.urlopen(url)
        text = frb_site.read().strip()

        with open(target_file, 'w') as f:
            f.write(text)

        logger.info('Dataset saved in %s', target_file)
    else:
        logger.info('Using cached dataset in %s', target_file)

    return target_file

if __name__ == '__main__':

    logging.basicConfig(level=logging.INFO)

    fname = load_frb_data()

    # simpler labels
    columns_dic = {
        "RIFLDIY01_N.B": 'Swap1Y',
        "RIFLDIY02_N.B": 'Swap2Y',
        "RIFLDIY03_N.B": 'Swap3Y',
        "RIFLDIY04_N.B": 'Swap4Y',
        "RIFLDIY05_N.B": 'Swap5Y',
        "RIFLDIY07_N.B": 'Swap7Y',
        "RIFLDIY10_N.B": 'Swap10Y',
        "RIFLDIY30_N.B": 'Swap30Y',
        "RILSPDEPM01_N.B": 'Libor1M',
        "RILSPDEPM03_N.B": 'Libor3M',
        "RILSPDEPM06_N.B": 'Libor6M'
    }

    # Parse the file: skip the first 5 rows, headers are on row 6,
    # ND and NC indicate missing values, first column is the index and contains
    # dates
    df_libor = read_csv(
        fname,  header=5,  skiprows=range(5), na_values=['ND', 'NC'],
        index_col=0, parse_dates=True
    )

    # Convert column names to simple labels
    df_libor = df_libor.rename(columns=columns_dic)

    good_rows = df_libor.apply(good_row, axis=1)
    
    df_libor_clean = df_libor[good_rows]

    df_libor_clean.save('data/df_libor.pkl')
