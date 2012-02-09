# plot fitted vs bid/ask vol at selected maturities

import pandas
import matplotlib.pyplot as plt
from pandas import DataFrame

def calibration_subplot(ax, group, i, model_name):
    group = group.sort_index(by='K')
    dtExpiry = group.get_value(group.index[0], 'dtExpiry')
    K = group['K']
    VB = group['VB']
    VA = group['VA']
    VM = group[model_name + '-IV']

    ax.plot(K, VA, 'b.', K,VB,'b.', K,VM,'r-')
    if i==3:
        ax.set_xlabel('Strike')
    if i==0:
        ax.set_ylabel('Implied Vol')
    ax.set_title('Expiry: %s' % dtExpiry)
    
def calibration_plot(title, df_calibration, model_name):
    df_calibration = DataFrame.filter(df_calibration,
                    items=['dtExpiry', 
                           'K', 'VB', 'VA',
                           'T', model_name+'-IV'])

    # group by maturity
    grouped = df_calibration.groupby('dtExpiry')

    all_groups = [(dt, g) for dt, g in grouped]
    
    xy = [(0,0), (0,1), (1,0), (1,1)]

    for k in range(0, len(all_groups),4):
        if (k+4) >= len(all_groups):
            break
        plt.figure()
        fig, axs = plt.subplots(2, 2, sharex=True, sharey=True)

        for i in range(4):
            x,y = xy[i]
            calibration_subplot(axs[x,y], all_groups[i+k][1],i, model_name)
        fig.suptitle(title, fontsize=12, fontweight='bold')
        fig.show()

# heston model
df_calibration = \
  pandas.load('data/df_calibration_output_heston.pkl')
dtTrade = df_calibration['dtTrade'][0]
title = 'Heston Model (%s)' % dtTrade
calibration_plot(title, df_calibration, 'Heston')

if False:
    # bates model
    df_calibration = \
                   pandas.load('data/df_calibration_output_bates.pkl')
    dtTrade = df_calibration['dtTrade'][0]
    title = 'Bates Model (%s)' % dtTrade
    calibration_plot(title, df_calibration, 'Bates')

    # det jump
    df_calibration = \
      pandas.load('data/df_calibration_output_batesdetjump.pkl')
    dtTrade = df_calibration['dtTrade'][0]
    title = 'Bates Det Jump Model (%s)' % dtTrade
    calibration_plot(title, df_calibration, 'BatesDetJump')

    # double exp
    df_calibration = \
      pandas.load('data/df_calibration_output_batesdoubleexp.pkl')
    dtTrade = df_calibration['dtTrade'][0]
    title = 'Bates Double Exp Model (%s)' % dtTrade
    calibration_plot(title, df_calibration, 'BatesDoubleExp')

    # double exp det jump
    df_calibration = \
      pandas.load('data/df_calibration_output_batesdoubleexpdetjump.pkl')
    dtTrade = df_calibration['dtTrade'][0]
    title = 'Bates Double Exp Det Jump Model (%s)' % dtTrade
    calibration_plot(title, df_calibration, 'BatesDoubleExpDetJump')
