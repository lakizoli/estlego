//
//  Config.hpp
//  estlego
//
//  Created by Laki, Zoltan on 2017. 02. 20..
//  Copyright © 2017. Graphisoft. All rights reserved.
//

#ifndef Config_hpp
#define Config_hpp

enum Price {
	Price_None =			0x0000,

	Price_MinimalNew =		0x0001,
	Price_AverageNew =		0x0002,
	Price_MinimalUsed =		0x0004,
	Price_AverageUsed =		0x0008,
};

class Config {
	bool _valid;
	int _calculationPrices;
	std::vector<std::string> _setNumbers;
	
public:
	Config (int argc, const char * argv[]);
	
	int DumpUsage () const;
	operator bool () const { return _valid; }
	
	int GetCalculationPrices () const { return _calculationPrices; }
	const std::vector<std::string>& GetSetNumbers () const { return _setNumbers; }
};

#endif /* Config_hpp */
