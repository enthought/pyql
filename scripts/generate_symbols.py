""" Symbol management to generate .def file. """
import glob
import os
import six
import subprocess

def symbol_generator_from_obj_file(object_file):
    
    command = ['nm', '--extern-only', '--defined-only', object_file]
    
    # don't show a window when executing the subprocess
    startupinfo = subprocess.STARTUPINFO()
    startupinfo.dwFlags |= subprocess.STARTF_USESHOWWINDOW
    
    nm_result = subprocess.check_output(command, startupinfo=startupinfo)
    
    def _is_ql_symbols(symb):
        # Includes all the symbols containing QuantLib except the ones with 
        # AVError and all the scalar deleting destructor (prefixed with _G)
        # and all the vector deleting destructor (prefixed with a _E)
        # and ?AVError (not yet sure what cause the problem :
        # (Error 1 error LNK2001: unresolved external symbol 
        # "??_R0?AVError@QuantLib@@@8??0Error@QuantLib@@QAE@ABV01@@Z20"
        # (??_R0?AVError@QuantLib@@@8??0Error@QuantLib@@QAE@ABV01@@Z20)
        # QuantLib.exp	QuantLib
        # )
        # See http://en.wikipedia.org/wiki/Visual_C%2B%2B_name_mangling for
        # reference
        return (
            'QuantLib' in symb and 
            '?AVError' not in symb and
            '??_G' not in symb and
            '??_E' not in symb
        )
        
    def _is_boost_assertion(symb):
        return '?assertion_failed@boost' in mangled_symbol

    for line in six.text_type(nm_result, 'ascii').split('\n'):
        # Example line: 
        # 0000000000000000 R ?value@?$integral_constant@_N$00@tr1@std@@2_NB
        # Find the symbol location in the line
        idx = line.find('?')
        
        # Get the symbol type
        stat = line[idx-2:idx].strip()
        if stat == 'w': # skip weak symbols
            continue
            
        mangled_symbol =  line[idx:].strip()
        
        if len(mangled_symbol) > 0:
            if _is_ql_symbols(mangled_symbol) or _is_boost_assertion(mangled_symbol):
                yield mangled_symbol
            
def process_directory(directory_name):
    for object_file in glob.glob(os.path.join(directory_name, '*.obj')):
        for symbol in symbol_generator_from_obj_file(object_file):
            yield symbol
    
HEADER = """LIBRARY	"QuantLib"
EXPORTS
"""

def test():
    test_directory = r"C:\dev\QuantLib-1.4\build\vc90\x64\Release"
    test_file = os.path.join(test_directory, "zeroyieldstructure.obj")

    for obj in symbol_generator_from_obj_file(test_file):
        pass
    
def generate_deffile_from_dir(input_directory, output_file):
    
    with open(output_file, 'w') as fh:
        fh.write(HEADER)
        for symbol in process_directory(input_directory):
            fh.write('	 {}\n'.format(symbol))
    
def main():
    input_directory = r"C:\dev\QuantLib-1.4\build\vc100\Win32\Release"        
    output_file = r'C:\dev\pyql\symbols_win32_vc100.def'
        
    generate_deffile_from_dir(input_directory, output_file)
    print ('{} generated'.format(output_file))
    
if __name__ == '__main__':
   main() 