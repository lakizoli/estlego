//
//  SetOutput.cpp
//  estlego
//
//  Created by Laki, Zoltan on 2017. 02. 21..
//  Copyright © 2017. Graphisoft. All rights reserved.
//

#include "SetOutput.hpp"

using namespace std;

void SetOutput::DumpPrice (const string& label, const PriceRecord& price) {
	_out << ",\"" << label << "\":{";
	_out << "\"min\":" << price.GetMin ();
	_out << ",\"avg\":" << price.GetAvg ();
	_out << ",\"qtyavg\":" << price.GetQtyAvg ();
	_out << ",\"max\":" << price.GetMax ();
	_out << "}";
}

SetOutput::SetOutput (std::ostream& output, const std::string& setNumber, const std::map<std::string, int>& inventory,
					  const std::map<std::string, PriceRecord>& last6NewPrices, const std::map<std::string, PriceRecord>& last6UsedPrices,
					  const std::map<std::string, PriceRecord>& currentNewPrices, const std::map<std::string, PriceRecord>& currentUsedPrices) :
	_out (output),
	_setNumber (setNumber),
	_inventory (inventory),
	_last6NewPrices (last6NewPrices),
	_last6UsedPrices (last6UsedPrices),
	_currentNewPrices (currentNewPrices),
	_currentUsedPrices (currentUsedPrices)
{
}

void SetOutput::Dump () {
	_out << "{\"set\":\"" << _setNumber << "\", \"inventory\":[";
	
	bool first = true;
	for (auto it : _inventory) {
		if (!first) {
			_out << ",";
		}
		first = false;
		
		_out << "{";
		
		_out << "\"designid\":\"" << it.first << "\"";
		_out << ",\"count\":" << it.second;
		
		auto itPrice = _last6NewPrices.find (it.first);
		if (itPrice != _last6NewPrices.end ()) {
			DumpPrice ("last6NewPrice", itPrice->second);
		}
		
		itPrice = _last6UsedPrices.find (it.first);
		if (itPrice != _last6UsedPrices.end ()) {
			DumpPrice ("last6UsedPrice", itPrice->second);
		}
		
		itPrice = _currentNewPrices.find (it.first);
		if (itPrice != _currentNewPrices.end ()) {
			DumpPrice ("currentNewPrice", itPrice->second);
		}

		itPrice = _currentUsedPrices.find (it.first);
		if (itPrice != _currentUsedPrices.end ()) {
			DumpPrice ("currentUsedPrice", itPrice->second);
		}

		_out << "}";
	}
	
	_out << "]}";
}
