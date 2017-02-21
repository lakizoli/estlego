//
//  EstimateOutput.hpp
//  estlego
//
//  Created by Laki, Zoltan on 2017. 02. 21..
//  Copyright © 2017. Graphisoft. All rights reserved.
//

#ifndef EstimateOutput_hpp
#define EstimateOutput_hpp

#include "PriceRecord.hpp"

enum class EstimateTypes {
	Minimal,
	Average
};

class EstimateOutput {
	std::ostream& _out;
	std::string _setNumber;
	std::map<std::string, int> _inventory;
	std::map<std::string, PriceRecord> _prices;
	EstimateTypes _type;
	std::string _tag;

public:
	EstimateOutput (std::ostream& output, const std::string& setNumber, const std::map<std::string, int>& inventory, const std::map<std::string, PriceRecord>& prices, EstimateTypes type, const std::string& tag);
	
	void Dump ();
};

#endif /* EstimateOutput_hpp */
