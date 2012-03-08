#include "CsvHelper.hpp"

/******************************************************************************/
/* void readCSV()
 *
 * Function to read a line from a comma-separated value text file and interpret
 * the entries.  Assumes that there are three potential data types - string,
 * long/integer, and double/float.  The entries are stored in separate vectors
 * that are passed to the function by reference.
 *
 * Arguments:
 *
 * 		fstream& infile		-file stream from which to read.  must already be
 * 							open with read access
 *
 * vector<string>& stringArray	-vector of strings in which to store the strings
 * 							that are found in the line
 *
 * vector<double>& doubleArray	-vector of doubles in which to store the doubles
 * 							or floats that are found in the line
 *
 * vector<long>& longArray	-vector of longs in which to store the longs or ints
 * 							that are found in the line
 *
 * vector<long>& order		-vector of longs in which to store the ordering of
 * 							elements in the original line.  0=long, 1=double,
 * 							2=string.
 *
 * The ordering of the original elements can be reconstructed and outputted
 * using:
 *
 * 	vector<string>::iterator striter=stringArray.begin();
	vector<double>::iterator dbliter=doubleArray.begin();
	vector<long>::iterator longiter=longArray.begin();
	for (long i=0; i<order.size(); ++i) {
		if (order.at(i)==0) {
			cout << *longiter << endl;
			longiter++;
		} else if (order.at(i)==1) {
			cout << *dbliter << endl;
			dbliter++;
		} else if (order.at(i)==2) {
			cout << *striter << endl;
			striter++;
		}
	}
 *
 * The function stores entries in the line from the CSV file based their data
 * type, which is decided with a few simple rules:
 *
 * If an entry contains only numerical characters, it is considered to be an
 * integer (stored as long integers).  Floating point numbers (stored as
 * doubles) must consist entirely of numerical characters, except for a single
 * period located anywhere within the entry.  Any entry containing more than one
 * period, or any other non-numerical characters, is stored as a string (sorry,
 * no support for hex numbers).
 *
 * Dependencies:  requires the string, vector, and fstream standard C++ headers.
 */

void write2DtoCsv(std::vector<std::vector<double> > &x, const char* filename, bool byRow) {
           ofstream myfile;

          myfile.open (filename, ios::out|ios::trunc); // this is the default

        int nbRows = x.size();
        int nbCols = x[0].size();

        if(byRow) {
          for(int i=0; i<nbRows; ++i) {
              for(int j=0; j<nbCols-1; ++j)
                  myfile << x[i][j] << ",";
              myfile << x[i][nbCols-1] << std::endl;
          };
        } else {
          for(int j=0; j<nbCols; ++j) {
              for(int i=0; i<nbRows-1; ++i)
                  myfile << x[i][j] << ",";
              myfile << x[nbRows-1][j] << std::endl;
          };
        };

        myfile.close();
}

void readCSV(std::string buffer,
             std::vector<std::string>& stringArray,
             std::vector<double>& doubleArray,
             std::vector<long>& longArray,
             std::vector<long>& order)
{


    //	read through buffer searching for commas or end of string. the start of
    //	each entry is the first element of the string (first word), or the
    //	position after the last comma encountered (all other words).  the end
    //	of the entry is the last element of the string (last word), or the
    //	position before the next comma (all other words)
    std::string temp;
    unsigned long start=0;
    unsigned long end=0;
    while (end<=buffer.size())
    {

        //	increment end counter
        end++;

        //	check if position of 'end' in the string a comma, past the end of
        //	the string, or just another character.  if at a non-comma character,
        //	skip to the start of the next loop
        if (end<buffer.size() && buffer[end]!=',')
        {
            continue;
        }

        //	assign comma-free token to a temporary string
        temp.assign(buffer,start,end-start);


        //	run through each character of the token to determine if it is a
        //	string, floating-point, or integer, based on number of periods and
        //	presence of non-numeric characters
        int containsPeriod=0;
        int containsAlpha=0;

        for (long i=0; i<(long)temp.size(); ++i)
        {
            if (temp[i]=='.')
            {
                //	token contains a '.' character - either a string or a floating point
                containsPeriod++;
            }
            else if ( temp[i]<48 || 57<temp[i] )
            {
                //	token contains non-numeric characters - string (sorry no hex)
                containsAlpha++;
            }
        }


        //	based on alphabetical/numerical content and the presence of period/
        //	decimals, determine whether the entry is an integer, floating-point
        //	number, or a string
        if (containsAlpha==0 && containsPeriod==0)
        {
            longArray.push_back(atoi(temp.c_str()));
            order.push_back(0);

        }
        else if (containsPeriod==1 && containsAlpha==0)
        {
            doubleArray.push_back(atof(temp.c_str()));
            order.push_back(1);
        }
        else
        {
            stringArray.push_back(temp);
            order.push_back(2);
        }


        //	set the start and end to the proper next position
        end++;
        start=end;
    }
}

void readCSV_HestonParams(std::istream &input, std::vector<HESTONPARAMS> &output)
{
    std::string csvLine;
    // read every line from the stream, skip header
    // std::getline(input, csvLine);
    while ( std::getline(input, csvLine) )
    {
        std::istringstream csvStream(csvLine);
        std::vector<std::string> csvRow;
        std::string csvElement;
        // read every element from the line that is seperated by commas
        // and put it into the vector or strings
        while ( std::getline(csvStream, csvElement, ',') )
        {
            csvRow.push_back(csvElement);
        }

        output.push_back(HestonParams(csvRow));
    }
}


void readCSV_RD(std::istream &input, std::vector<RD> &output)
{
    std::string csvLine;
    // read every line from the stream, skip header
    std::getline(input, csvLine);
    while ( std::getline(input, csvLine) )
    {
        std::istringstream csvStream(csvLine);
        std::vector<std::string> csvRow;
        std::string csvElement;
        // read every element from the line that is seperated by commas
        // and put it into the vector or strings
        while ( std::getline(csvStream, csvElement, ',') )
        {
            csvRow.push_back(csvElement);
        }


        output.push_back(RateDiv(csvRow));
    }
}

ostream &operator<<(ostream &out, RD &p) {
    out << "T " << p.T << " R " << p.R << " D " << p.D;
    return out;
}

void readCSV_Calib(std::istream &input, std::vector<CALIB> &output)
{
    std::string csvLine;
    // read every line from the stream
    std::getline(input, csvLine);
    while ( std::getline(input, csvLine) )
    {
        std::istringstream csvStream(csvLine);
        std::vector<std::string> csvRow;
        std::string csvElement;
        // read every element from the line that is seperated by commas
        // and put it into the vector or strings
        while ( std::getline(csvStream, csvElement, ',') )
        {
            csvRow.push_back(csvElement);
        }


        output.push_back(Calib(csvRow));
    }
}

ostream &operator<<(ostream &out, CALIB &p) {
    out << "T " << p.T << " " << p.PA;
    return out;
}

template <typename T>
void readCSV_T(std::istream &input, std::vector<T> &output)
{
    std::string csvLine;
    // read every line from the stream
    while ( std::getline(input, csvLine) )
    {
        std::istringstream csvStream(csvLine);
        std::vector<std::string> csvRow;
        std::string csvElement;
        // read every element from the line that is seperated by commas
        // and put it into the vector or strings
        while ( std::getline(csvStream, csvElement, ',') )
        {
            csvRow.push_back(csvElement);
        }


        output.push_back(T(csvRow));
    }
}


void readCSVToStr(std::istream &input, std::vector< std::vector<std::string> > &output)
{
    std::string csvLine;
    // read every line from the stream
    while ( std::getline(input, csvLine) )
    {
        std::istringstream csvStream(csvLine);
        std::vector<std::string> csvColumn;
        std::string csvElement;
        // read every element from the line that is seperated by commas
        // and put it into the vector or strings
        while ( std::getline(csvStream, csvElement, ',') )
        {
            csvColumn.push_back(csvElement);
        }
        output.push_back(csvColumn);
    }
}

