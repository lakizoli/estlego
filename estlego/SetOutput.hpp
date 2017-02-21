//
//  SetOutput.hpp
//  estlego
//
//  Created by Laki, Zoltan on 2017. 02. 21..
//  Copyright © 2017. Graphisoft. All rights reserved.
//

#ifndef SetOutput_hpp
#define SetOutput_hpp

#include "PriceRecord.hpp"

class SetOutput {
	std::ostream& _out;
	std::string _setNumber;
	std::map<std::string, int> _inventory;
	std::map<std::string, PriceRecord> _last6NewPrices;
	std::map<std::string, PriceRecord> _last6UsedPrices;
	std::map<std::string, PriceRecord> _currentNewPrices;
	std::map<std::string, PriceRecord> _currentUsedPrices;
	
	void DumpPrice (const std::string& label, const PriceRecord& price);
	
public:
	SetOutput (std::ostream& output, const std::string& setNumber, const std::map<std::string, int>& inventory,
			   const std::map<std::string, PriceRecord>& last6NewPrices, const std::map<std::string, PriceRecord>& last6UsedPrices,
			   const std::map<std::string, PriceRecord>& currentNewPrices, const std::map<std::string, PriceRecord>& currentUsedPrices);
	
	void Dump ();
};

#endif /* SetOutput_hpp */
