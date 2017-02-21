//
//  PriceRecord.hpp
//  estlego
//
//  Created by Laki, Zoltan on 2017. 02. 21..
//  Copyright © 2017. Graphisoft. All rights reserved.
//

#ifndef PriceRecord_hpp
#define PriceRecord_hpp

class PriceRecord {
	double _minPrice;
	double _avgPrice;
	double _qtyAvgPrice;
	double _maxPrice;
	
	static double ConvertPrice (const std::string& price);
	
public:
	PriceRecord (const std::string& minPrice, const std::string& avgPrice, const std::string& qtyAvgPrice, const std::string& maxPrice);
	
	double GetMin () const { return _minPrice; }
	double GetAvg () const { return _avgPrice; }
	double GetQtyAvg () const { return _qtyAvgPrice; }
	double GetMax () const { return _maxPrice; }
};

#endif /* PriceRecord_hpp */
