# minimal quantlib/cloud test

import cloud

from quantlib.quotes import SimpleQuote

def quote_test(q1):
	quote_1 = SimpleQuote(value=q1)
	return quote_1.value

if __name__ == '__main__':
	
	cloud.setkey(4360)
	jid = cloud.call(quote_test, 35, _env='pyQL-clone')
	res = cloud.result(jid)
	print res
	
