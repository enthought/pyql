import re
cimport cython


tenor_re = re.compile("([1-9]+)([DWMY]{1,1})")

def parse(tenor):
    mo = tenor_re.match(tenor)
    return (mo.group(1), mo.group(2))

    
tenor = '3M'
t = cython.typeof(tenor)
print(t)


print parse(tenor)

tenor = '12W'
print parse(tenor)


