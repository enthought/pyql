Developer's corner
==================


Debugging with gdb
------------------

When running into segfault, the easiest way to debug things is to use gdb. Here
is a example trying to debug a segfault while accessing the implied_quote
property of a SwapRateHelper::

    gdb python
    (gdb) run quantlib/test/test_rate_helpers.py
    Starting program: /Library/Frameworks/Python.framework/Versions/7.0/bin/python quantlib/test/test_rate_helpers.py
    Reading symbols for shared libraries ++. done

    Program received signal SIGTRAP, Trace/breakpoint trap.
    0x8fe01030 in __dyld__dyld_start ()
    (gdb) continue
    ...
    Reading symbols for shared libraries . done
    terminate called after throwing an instance of 'QuantLib::Error'
    what():  term structure not set

    Program received signal SIGABRT, Aborted.
    0x915b4c5a in __kill ()
        
    
