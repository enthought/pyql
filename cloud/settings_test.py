# simple example to demonstrate the use of Settings()

import cloud

from quantlib.quotes import SimpleQuote
from quantlib.settings import Settings
from quantlib.termstructures.yields.api import FlatForward
from quantlib.time.api import Actual360, Date, NullCalendar, TARGET

def settings_test():
	calendar = TARGET()
	settings = Settings()
	
	date_today      = Date(6,9,2011)
	date_payment    = Date(6,10,2011)
	settlement_days = 2
	
	settings.evaluation_date = date_today
	quote = SimpleQuote(value=0.03)
	
	term_structure = FlatForward(
	    settlement_days = settlement_days,
	    quote           = quote,
	    calendar        = NullCalendar(),
	    daycounter      = Actual360()
	)
	
	df_1 = term_structure.discount(date_payment)
	
	date_today = Date(19,9,2011)
	settings.evaluation_date = date_today
	
	date_payment = Date(19,10,2011)
	df_2 = term_structure.discount(date_payment)
		
	return [df_1, df_2]

if __name__ == '__main__':
	
	# local calculation
	df_1, df_2 = settings_test()
	# df_1 and df_2 should be identical:
	print('local -- df_1: %f df_2 %f difference (should be 0.0): %f' % (df_1, df_2, df_2-df_1))

	# cloud
	cloud.setkey(4360)
	jid = cloud.call(settings_test, _env='pyQL-clone')
	df_1, df_2 = cloud.result(jid)
	print('cloud -- df_1: %f df_2 %f difference (should be 0.0): %f' % (df_1, df_2, df_2-df_1))
	
