import sys
import os

# add the root folder to PATH so the quantlib dll can be found
if sys.platform == 'win32':
    os.environ["PATH"] = os.path.abspath(os.path.dirname(__file__)) + ";" + os.environ["PATH"]
