import re
import numpy
from math import floor, log10
import operator

def abswithnone(x):
    if x is None:
        return 0
    elif numpy.isnan(x):
        return 0
    else:
        return abs(x)

def lenwithnone(x):
    try:
        return len(x)
    except TypeError:
        return 0

def prettyprint(cLab, cTyp, cTmp):
    """
    PRETTYPRINT
    formatted display of table

    prettyprint(labels, types, data)
    labels: array of labels, or char array
    types:
    - i: integer
    - v: 2 dec (e.g. dollar value)
    - p: 4 dec (dollar price)
    - d: date (normalDate or scalar() value)
    - s: string
    data: array of column vectors
    """

    if isinstance(cLab, (tuple, list)):
        cLabels = cLab
    else:
        p = re.compile(r'\W+')
        cLabels = p.split(cLab)

    nbColumns = len(cLabels)

    if len(cTyp) != nbColumns:
        raise ValueError(
            'dimension mismatch: %d labels, %d types.' % (nbColumns, len(cTyp))
        )

    if isinstance(cTyp, (tuple, list)):
        cTypes = cTyp
    else:
        cTypes = []
        for c in cTyp:
            cTypes.append(c)

    # verify types
    legalTypes = 'ivpdcs'
    for t in cTypes:
        if t not in legalTypes:
            raise ValueError(
                'Data type %s not found. legal types are: %s' % (t,  legalTypes)
            )

    cValues = cTmp

    if len(cValues) != nbColumns:
        raise ValueError(
            'dimension mismatch: %d labels, %d data columns.' % (nbColumns, len(cValues))
        )

    nbRows = max(map(lambda x:len(x), cValues))

    dash = '-'
    space = ' '
    s1 = ''
    s2 = ''
    rows = []
    rows.append(s1)
    rows.append(s2)
    for i in range(nbRows):
        rows.append('')

    for (label, fcode, values) in map(None, cLabels, cTypes, cValues):
        # determine the width of this field
        # as the max of:
        # - width of data
        # - width of label

        w2 = len(label)
        if fcode == 'i':
            # integers
            w1 = floor(max(1,log10(1.0+max(map(abswithnone, values)))))+2
            sFormat = ' %%%dd ' % max(w1, w2)
        elif fcode == 'v':
            # doubles representing a quantity with 2 decimal places (ex: value)
            deci = 2;
            try:
                w1 = floor(max(1,log10(1.0+max(map(abswithnone, values))))) + 3 + deci
            except OverflowError as e:
                raise Exception("values="+values.__str__() + "\n" + e.__str__())
            sFormat = ' %%%d.%df ' % (max(w1, w2), deci)
        elif fcode == 'p':
            # doubles representing a quantity with 4 decinal places (ex: price)
            deci = 4
            try:
##                print map(abswithnone, values)
                w1 = floor(max(1,log10(1.0+max(map(abswithnone, values))))) + 3 + deci
            except ValueError:
                ## TODO: this is here because of a bug when values is all numpy.nan
                w1 = 10
            except OverflowError:
                raise Exception("values="+values.__str__()+"\n"+e.__str__())
            sFormat = ' %%%d.%df ' % (max(w1, w2), deci)
        elif fcode == 'd':
            # a date
            w1 = 9
            sFormat = ' %%%ds ' % max(w1, w2)
        elif fcode == 'c':
            # a date
            w1 = 6
            sFormat = ' %%%ds ' % max(w1, w2)
            
        elif fcode == 's':
            # a string
            w1 = max(map(lenwithnone, values))
            sFormat = ' %%%ds ' % max(w1, w2)

        width = max(w1, w2)
        fmt = ' %%%ds ' % width
        s1 += fmt % label
        s2 += fmt % (dash*int(width))
        
        # dates in scalar form must be translated back into normal dates
        if fcode == 'd' and isinstance(values[0], int):
            for i in range(min(len(values), nbRows)):
                rows[i+2] += sFormat % normalDateFromScalar(values[i])
        else:
            for i in range(min(len(values), nbRows)):
                if values[i] is not None:
                    rows[i+2] += sFormat % values[i]
                else:
                    rows[i+2] += space*int(width+2)
        if nbRows>len(values):
            for i in range(len(values), nbRows):
                rows[i+2] += space*int(width+2)

    rows[0] = s1
    rows[1] = s2
    
    str = ''
    for r in rows:
        str += r + '\n'

    return str

def prettyprinttranspose(cLab, cTyp, cTmp):
    """
    PRETTYPRINTTRANSPOSE
    formatted display of table transposed

    prettyprinttranspose(labels, types, data)
    labels: array of labels, or char array
    types: 
    - i: integer
    - v: 2 dec (e.g. dollar value)
    - p: 4 dec (dollar price)
    - d: date (normalDate or scalar() value)
    - s: string
    data: array of column vectors
    """

    if isinstance(cLab, (tuple, list)):
        cLabels = cLab
    else:
        p = re.compile(r'\W+')
        cLabels = p.split(cLab)

    nbColumns = len(cLabels)

    if len(cTyp) != nbColumns:
        raise ValueError('dimension mismatch: %d labels, %d types.' % (nbColumns, len(cTyp)))

    if isinstance(cTyp, (tuple, list)):
        cTypes = cTyp
    else:
        cTypes = []
        for c in cTyp:
            cTypes.append(c)

    # verify types
    legalTypes = 'ivpdcs'
    for t in cTypes:
        if t not in legalTypes:
            raise ValueError('Data type %s not found. legal types are: %s' % (t,  legalTypes))

    cValues = cTmp

    if len(cValues) != nbColumns:
        raise ValueError('dimension mismatch: %d labels, %d data columns.' % (nbColumns, len(cValues)))

    # Convert format to string and add labels
    sValues = [[c[1]+' |']+[' '+prettyprintformatter(r,c[2]) for r in c[0]] for c in zip(cValues,cLabels,cTypes)]
    cMax = max([len(c) for c in sValues])
    
    # fill unused end of columns
    sValues = [c+[' ']*(cMax-len(c)) for c in sValues]
    
    # get lengths of all strings
    sLen = [[len(r) for r in c] for c in sValues]
    
    # get max lengths of rows 
    sMaxRowLen=reduce(lambda x,y: [max(z) for z in zip(x,y)],sLen)
    
    # add spaces to fill to max length of rows
    sValues = [[' '*(r[1]-len(r[0]))+r[0] for r in zip(c,sMaxRowLen)] for c in sValues]
    return reduce(operator.add,[ reduce(operator.add,c)+"\n" for c in sValues])


def prettyprintformatter(value,fcode):
    if value is None:
        return "none"
    elif fcode == 'i':
        return "%d" % value
    elif fcode == 'v':
        return "%.2f" % value
    elif fcode == 'p':
        return "%.2f" % value
    elif fcode == 'd':
        return str(ND(value))
    elif fcode == 'c':
        return str(ND(value))
    elif fcode == 's':
        return value.__str__() #make sure you return a string..in case someone is sending int as string accidentially.
    else:
        raise ValueError('Data type %s not found' % fcode)

