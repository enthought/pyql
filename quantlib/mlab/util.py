"""
 Copyright (C) 2013, Enthought Inc
 Copyright (C) 2013, Patrick Henaff

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
"""

import inspect
import numpy as np
from numbers import Number
from datetime import date 

def common_shape(frame):
    """
    Inspect the input arguments to a function and
    verify that the shapes are compatible, in a matlab sense:
    either scalar or arrays of identical shapes
    """

    args, _, _, values = inspect.getargvalues(frame)

    # all non-scalar arguments must have the same shape, do not care if
    # it is a numpy type or not

    values = dict([(k, values[k]) for k in args])
    the_shape = None
    res = {}
    for a in args:
        value = values[a]

        if isinstance(value, Number) or \
           isinstance(value, basestring) or \
           isinstance(value, date):
            res[a] = ('scalar', None)
        else:
            if(the_shape is None):
                the_shape = np.shape(value)
                res[a] = ('array', the_shape)
            elif(the_shape == np.shape(value)):
                res[a] = ('array', the_shape)
            else:
                raise ValueError('Wrong shape for argument %s. \
                Excepting a scalar or array of shape %s' % \
                                 (a, str(the_shape)))

    return (the_shape, res, values)


def array_call(foo, shape, values):
    """
    Call function foo with all elements in array arguments
    return an output of same shape as array input elements
    """

    array_vars = [k for k, v in shape.items() if v[0] == 'array']
    scalar_vars = [k for k, v in shape.items() if v[0] == 'scalar']
    the_shape = shape[array_vars[0]][1]
    res = list()
    for key in array_vars:
        values[key] = np.ravel(values[key])

    nb_items = len(values[array_vars[0]])

    input_args = dict((key, 0) for key in shape)
    for key in scalar_vars:
        input_args[key] = values[key]

    for i in range(nb_items):
        for key in array_vars:
            input_args[key] = values[key][i]
        res.append(foo(**input_args))

    return res
