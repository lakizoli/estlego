//
//  PriceRecord.cpp
//  estlego
//
//  Created by Laki, Zoltan on 2017. 02. 21..
//  Copyright © 2017. Graphisoft. All rights reserved.
//

#include "PriceRecord.hpp"

using namespace std;

double PriceRecord::ConvertPrice (const string& price) {
	if (price == "-") {
		return 0.0;
	}
	
	string num;
	copy_if (price.begin (), price.end (), back_inserter (num), [] (char ch) -> bool { return isnumber (ch) || ch == '.'; });
	if (num.empty ()) {
		return 0.0;
	}
	
	return atof (num.c_str ());
}

PriceRecord::PriceRecord (const string& minPrice, const string& avgPrice, const string& qtyAvgPrice, const string& maxPrice) {
	_minPrice = ConvertPrice (minPrice);
	_avgPrice = ConvertPrice (avgPrice);
	_qtyAvgPrice = ConvertPrice (qtyAvgPrice);
	_maxPrice = ConvertPrice (maxPrice);
}
