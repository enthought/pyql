import urllib
import pandas
from pandas.io.parsers import read_csv

fname = 'data/frb_h15.csv'

def get_frb_url(dtStart, dtEnd):
    """
    Federal Reserve Board URL
    Construct this URL at 'http://www.federalreserve.gov/datadownload
    """
    
    url = 'http://www.federalreserve.gov/datadownload/Output.aspx?rel=H15&series=8f47c9df920bbb475f402efa44f35c29&lastObs=&from=%s&to=%s&filetype=csv&label=include&layout=seriescolumn' % (dtStart.strftime('%m/%d/%Y'), dtEnd.strftime('%m/%d/%Y'))
    return url

if False:
    url = get_frb_url(dtStart=date(2000,1,1), dtEnd=date(2011,12,31))
    frb_site = urllib.urlopen(url)
    text = frb_site.read().strip()

    f = open(fname, 'w')
    f.write(text)
    f.close()


def dataconverter(s):
    """
    FRB data file has 
    - numeric cells
    - empty cells
    - cells with 'NC' or 'ND'
    """
    try:
        res = float(s)
    except:
        res = np.nan
    return res

# simpler labels

columns_dic = {"RIFLDIY01_N.B":'Swap1Y',
               "RIFLDIY02_N.B":'Swap2Y',
               "RIFLDIY03_N.B":'Swap3Y',
               "RIFLDIY04_N.B":'Swap4Y',
               "RIFLDIY05_N.B":'Swap5Y',
               "RIFLDIY07_N.B":'Swap7Y',
               "RIFLDIY10_N.B":'Swap10Y',
               "RIFLDIY30_N.B":'Swap30Y',
               "RILSPDEPM01_N.B":'Libor1M',
               "RILSPDEPM03_N.B":'Libor3M',
               "RILSPDEPM06_N.B":'Libor6M'}

# the first column to be converted is the first data column,
# excluding the index column (0)

dc_dict = {i: dataconverter for i in range(0,len(columns_dic.keys()))}

df_libor = read_csv('data/frb_h15.csv', sep=',', header=True,
                    index_col=0, parse_dates=True,
                    converters=dc_dict,
                    skiprows=[0,1,2,3,4])

df_libor = df_libor.rename(columns=columns_dic)

def good_row(z):
    """
    Retain days with no gaps in data
    """
    
    try:
        res = not any([(math.isnan(x) or (x == 0)) for x in z])
    except:
        res = False
    return res

good_rows = df_libor.apply(good_row, axis=1)
df_libor = df_libor[good_rows]

df_libor.save('data/df_libor.pkl')





