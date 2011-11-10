import pandas
import dateutil
import re
import datetime
import numpy as np
from pandas import DataFrame
from pandas.stats.interface import ols

option_data_file = \
    'data/SPX-Options-24jan2011.csv'

def ExpiryMonth(s):
    CallMonths = {"A":1, "B":2, "C":3, "D":4, "E":5, "F":6, 
    "G":7, "H":8, "I":9, "J":10, "K":11, "L":12}
    PutMonths = {"M":1, "N":2, "O":3, "P":4, "Q":5, "R":6, 
    "S":7, "T":8, "U":9, "V":10, "W":11, "X":12}
  
    try:
        m = CallMonths[s]
    except KeyError:
        m = PutMonths[s]
    
    return m

spx_symbol = re.compile("\\(SPX(1[0-9])([0-9]{2})([A-Z])([0-9]{3,4})-E\\)")

def parseSPX(s): 
    tokens = spx_symbol.split(s)
    
    if len(tokens) == 1:
        return {'dtExpiry': None, 'strike': -1}

    y = 2000 + int(tokens[1])
    d = int(tokens[2])
    m = ExpiryMonth(tokens[3])
    strike = float(tokens[4])

    dtExpiry = datetime.date(y, m, d)
    
    return ({'dtExpiry': dtExpiry, 'strike': strike})

def make_SPX_df(option_data_file):
    
    # read two lines for spot price and calculation date
    fid = open(option_data_file)
    lineOne = fid.readline()
    spot = eval(lineOne.split(',')[1])
    
    lineTwo = fid.readline()
    dt = lineTwo.split('@')[0]
    dtTrade = dateutil.parser.parse(dt).date()
    
    print('Dt Calc: %s Spot: %f' % (dtTrade, spot))
    fid.close()
    
    # read all option price records as a data frame
    
    df = pandas.io.parsers.read_csv(option_data_file, header=2, \
         skiprows=(0,1), sep=',')
    
    # split and stack calls and puts
    call_df = df[df.columns[0:7]]
    call_df = call_df.rename(columns={'Calls':'Spec'}) 
    call_df['Type'] = 'C'
    
    put_df = df[df.columns[7:14]]
    put_df = put_df.rename(columns = {'Puts':'Spec',  'Last Sale.1':'Last Sale', 
    'Net.1':'Net', 'Bid.1':'Bid',
    'Ask.1':'Ask', 'Vol.1':'Vol', 'Open Int.1':'Open Int'}) 
    put_df['Type'] = 'P'
        
    df_all = call_df.append(put_df,  ignore_index=True)
    
    # parse Calls and Puts columns for strike and contract month
    # insert into data frame
    cp = [parseSPX(s) for s in df_all['Spec']]
    df_all['Strike'] = [x['strike'] for x in cp]
    df_all['dtExpiry'] = [x['dtExpiry'] for x in cp]
    
    df_all = df_all[df_all['Strike'] > 0]
    df_all['dtTrade'] = dtTrade
    
    return (spot, df_all)

(spot, optionDataFrame) = make_SPX_df(option_data_file)

# def ImpliedVolTable(spot,  optionDataFrame, nMinQuotes=6, tMin=1/12, QDMin=.2,
#                    QDMax=.8):

nMinQuotes=6; tMin=1.0/12; QDMin=.2; QDMax=.8

    # for each expiry, compute implied forward and ATM vol: 
    # can do better here: use Shimko's regression method
    # to get implied dividend yield
    # calculation needed for Quick Delta calculation later on 

grouped = optionDataFrame.groupby('dtExpiry') 

for spec, group in grouped:
    print('processing group %s' % spec)

    # implied vol for this type/expiry group
    # exclude groups with too few data points 
    # or too short maturity
    
    dtTrade = group['dtTrade'][0]
    dtExpiry = group['dtExpiry'][0]
    daysToExpiry = (dtExpiry-dtTrade).days
    timeToMaturity = daysToExpiry/365.0
    if timeToMaturity < tMin:
        continue
            
    # compute implied interest rate and dividend yield
    # shimko's method
    
    # valid call and put quotes
    df_call = group[(group['Type'] == 'C') & (group['Bid']>0) \
                    & (group['Ask']>0)]
    df_put = group[(group['Type'] == 'P') &  (group['Bid']>0) \
                    & (group['Ask']>0)]
    if (len(df_call) == 0) | (len(df_put) == 0):
        continue
        
    df_call['PremiumC'] = (df_call['Bid']+df_call['Ask'])/2
    
    df_C = DataFrame.filter(df_call, items=['Strike', 'PremiumC'])
                    
    
    df_put['PremiumP'] = (df_put['Bid']+df_put['Ask'])/2
    
    to_join = DataFrame(df_put['PremiumP'], index=df_put['Strike'],
            columns=['PremiumP']) 

    # use 'inner' join because some strikes are not quoted for C and P
    df_all = df_C.join(to_join, on='Strike', how='inner')
    
    df_all['C-P'] = df_all['PremiumC'] - df_all['PremiumP']
    
    model = ols(y=df_all['C-P'], x=df_all.ix[:,'Strike'])
    b = model.beta 
    
    # intercept is last coef!
    iRate = -np.log(-b[0])/timeToMaturity
    dRate = np.log(spot/b[1])/timeToMaturity

    print('int rate: %f div yield: %f' % (iRate, dRate))

    # price and volatility at implied forward
    
    Fwd = spot * np.exp((iRate-dRate)*timeToMaturity)
    
    
    
    
    
    #
#  # ATM price and vol
#  Price <- approx(strikeC, PremiumC, Fwd)$y
#  vol <- GBSVolatility(Price, TypeFlag="c", S=spot,
#        X=Fwd, r=iRate, b=iRate-iDiv,
#        Time=ttm, tol=1e-4, maxiter=500)
#
#  ATMVol[as.character(dt)] <- vol
#  ZERO[as.character(dt)] <- iRate
#  DIV[as.character(dt)] <- iDiv
#  FWD[as.character(dt)] <- Fwd
#
#  print(paste('Time:', round(ttm,2), 'Fwd:', round(Fwd,2), 'ATMVol:', round(vol,3)))
#}
#
## now go through entire file again, only OTM options
#
#IVBid = as.numeric(rep(NA, n))
#IVAsk = as.numeric(rep(NA, n))
#T <- rep(0, n)
#QuickDelta <- rep(0, n)
#ATMV <- rep(0, n)
#FRWD <- rep(0, n)
#IR <- rep(0, n)
#IDiv <- rep(0, n)
#LOGM <- rep(0, n)
#
#for(i in seq(1,n)) {
#  dtExp <- OptionDataFrame$dtExpiry[i]
#  
#  fwd <- FWD[[as.character(dtExp)]] 
#  if(is.null(fwd)){next}
#
#  ttm = tDiff(dtTrade, dtExp)
#
#  strike <- OptionDataFrame$strike[i]
#  TypeFlag <- OptionDataFrame$CP[i]
#
#  isOTM = (((TypeFlag == "C") & (strike>fwd)) | ((TypeFlag == "P") & (strike<fwd)))  
#
#  if(isOTM) {
#    bid <- OptionDataFrame$bid[i]
#    ask <- OptionDataFrame$ask[i]
#    ttm <- tDiff(dtTrade, OptionDataFrame$dtExpiry[i])
#
#    # QD computed with ATM vol 
#    QD <- pnorm(log(fwd/strike)/(ATMVol[[as.character(dtExp)]]*sqrt(ttm)))
#     
#    if((QD>=QDMin) & (QD<=QDMax)) {
#
#      iRate <- ZERO[[as.character(dtExp)]]
#      iDiv <- DIV[[as.character(dtExp)]]
#
#      IVBid[i] <- GBSVolatility(bid, TypeFlag=tolower(TypeFlag), S=spot,
#        X=strike, r=iRate, b=iRate-iDiv,
#        Time=ttm, tol=1e-4, maxiter=500)
#      IVAsk[i] <- GBSVolatility(ask, TypeFlag=tolower(TypeFlag), S=spot,
#        X=strike, r=iRate, b=iRate-iDiv,
#        Time=ttm, tol=1e-4, maxiter=500)
#
#      T[i] <- ttm
#      QuickDelta[i] <- QD
#      ATMV[i] <- ATMVol[[as.character(dtExp)]]
#      FRWD[i] <- fwd
#      IR[i] <- iRate
#      IDiv[i] <- iDiv
#      LOGM[i] <- log(strike/fwd)
#    }
#  }
#}
#
## only keep expiries with more than nMinQuotes
#
#for(i in seq_along(dtE)) {
#  indx <- (OptionDataFrame$dtExpiry == dtE[i])
#  ImpVol <- (IVBid[indx] + IVAsk[indx])/2
#  if(sum(!is.na(ImpVol)) < nMinQuotes) {
#    IVBid[indx] = NA
#    IVAsk[indx] = NA
#  }
#}
#  
## the output data structure
## - table of computed IV
## do not use removeNA on a data.frame: 
## it converts all entries to strings!
#
#indx = !(is.na(IVBid) | is.na(IVAsk)) 
#
#data.frame(OptionDataFrame[indx,], IVBid=IVBid[indx], IVAsk=IVAsk[indx], IR=IR[indx], IDIV=IDiv[indx], ATMVol=ATMV[indx], 
#                        Fwd=FRWD[indx], QuickDelta=QuickDelta[indx], T=T[indx], LOGM=LOGM[indx])
#}

