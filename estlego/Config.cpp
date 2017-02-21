//
//  Config.cpp
//  estlego
//
//  Created by Laki, Zoltan on 2017. 02. 20..
//  Copyright © 2017. Graphisoft. All rights reserved.
//

#include "Config.hpp"

using namespace std;

Config::Config (int argc, const char * argv[]) : _valid (false), _calculationPrices (Price_None) {
	for (int i = 1;i < argc;++i) {
		string argType = argv[i];
		if (argType == "-s") {
			if (i >= argc - 1) {
				printf ("Error: set number not found after -s parameter!\n");
				return;
			}
			
			++i;
			_setNumbers.push_back (argv[i]); //Store set number
		} else if (argType == "-sf") {
			if (i >= argc - 1) {
				printf ("Error: set file path not found after -sf parameter!\n");
				return;
			}
			
			++i;
			ifstream sets (argv[i]);
			if (!sets) {
				printf ("Error: cannot read set file at path: %s\n", argv[i]);
				return;
			}
			
			for (string line; getline (sets, line);) {
				_setNumbers.push_back (line);
			}
		} else if (argType == "-minnew") {
			_calculationPrices |= Price_MinimalNew;
		} else if (argType == "-avgnew") {
			_calculationPrices |= Price_AverageNew;
		} else if (argType == "-minused") {
			_calculationPrices |= Price_MinimalUsed;
		} else if (argType == "-avgused") {
			_calculationPrices |= Price_AverageUsed;
		}
	}
	
	if (_setNumbers.size () <= 0) {
		printf ("Error: no set number specified!\n");
	}
	
	if (_calculationPrices == Price_None) {
		printf ("Error: no price specified!\n");
	}
	
	_valid = _calculationPrices != Price_None && _setNumbers.size () > 0;
}

int Config::DumpUsage () const {
	printf ("\n"
			"Usage:\n"
			"    estlego <options>\n"
			"\n"
			"Options:\n"
			"    -s <set number>: specify single set with number\n"
			"    -sf <file path>: specify multiple set in file (one set number per line in a text file)\n"
			"    -minnew: add minimal new prices to estimation\n"
			"    -avgnew: add average new prices to estimation\n"
			"    -minused: add minimal used prices to estimation\n"
			"    -avgused: add average used prices to estimation\n"
			"\n");
	
	return 1;
}
