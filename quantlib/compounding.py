#Compounding style
Simple = 0                 # 1+rt
Compounded = 1             # (1+r)^t
Continuous = 2             # e^{rt}
SimpleThenCompounded = 3   # Simple up to the first period then Compounded


def compounding_from_name(name):
    dic = {'Simple': Simple,
           'Compounded': Compounded,
           'Continuous': Continuous,
           'SimpleThenCompounded': SimpleThenCompounded}

    try:
        cp = dic[name]
        return cp
    except ValueError:
        print('Compounding style %s is unknown' % name)
