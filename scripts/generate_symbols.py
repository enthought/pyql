""" Symbol management to generate .def file. """
import glob
import os
from subprocess import check_output

def get_symbol_from_obj_file(object_file):
    
    command = ['nm', '-g', '--defined-only', object_file]
    
    result = check_output(command, shell=False)
    
    for line in result.split('\n'):
        idx = line.find('?')
        stat = line[idx-2:idx].strip()
        if stat == 'w':
            print 'Skipping ', line
            continue
        mangled_symbol =  line[idx:].strip()
        if len(mangled_symbol) > 0:
            if 'QuantLib' in mangled_symbol and 'AVError' not in mangled_symbol:
                yield mangled_symbol
            elif '?assertion_failed@boost' in mangled_symbol:
                yield mangled_symbol
            
def process_directory(directory_name):
    for object_file in glob.glob(os.path.join(directory_name, '*.obj')):
        for symbol in get_symbol_from_obj_file(object_file):
            yield symbol
    
HEADER = """LIBRARY	"QuantLib"
EXPORTS
"""

def test():
    test_directory = r"C:\dev\QuantLib-1.4\build\vc90\Win32\Release"
    test_file = os.path.join(test_directory, "zigguratrng.obj")
    output_file = r'C:\dev\pyql\symbols_win32.def'
    
    for obj in get_symbol_from_obj_file(test_file):
        print obj
    
    with open(output_file, 'w') as fh:
        fh.write(HEADER)
        for symbol in process_directory(test_directory):
            fh.write('	 {}\n'.format(symbol))
    

if __name__ == '__main__':
   test()
    