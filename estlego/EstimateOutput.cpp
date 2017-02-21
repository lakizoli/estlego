//
//  EstimateOutput.cpp
//  estlego
//
//  Created by Laki, Zoltan on 2017. 02. 21..
//  Copyright © 2017. Graphisoft. All rights reserved.
//

#include "EstimateOutput.hpp"

using namespace std;

EstimateOutput::EstimateOutput (ostream& output, const string& setNumber, const map<string, int>& inventory, const map<string, PriceRecord>& prices, EstimateTypes type, const std::string& tag) :
	_out (output),
	_setNumber (setNumber),
	_inventory (inventory),
	_prices (prices),
	_type (type),
	_tag (tag)
{
}

void EstimateOutput::Dump () {
	_out << "{\"set\":\"" << _setNumber << "\"";
	switch (_type) {
		default:
		case EstimateTypes::Minimal:
			_out << ",\"type\":\"minimal\"";
			break;
		case EstimateTypes::Average:
			_out << ",\"type\":\"average\"";
			break;
	}
	_out << ",\"tag\":\"" << _tag << "\"";
	_out << ",\"inventory\":[";
	
	vector<string> sortedDesignIDs;
	transform (_inventory.begin (), _inventory.end (), back_inserter (sortedDesignIDs), [] (const pair<string, int>& item) -> string { return item.first; });
	sort (sortedDesignIDs.begin (), sortedDesignIDs.end (), [&] (const string& d1, const string& d2) -> bool {
		auto it1 = _prices.find (d1);
		double price1 = 0;

		auto it2 = _prices.find (d2);
		double price2 = 0;
		
		switch (_type) {
			default:
			case EstimateTypes::Minimal:
				if (it1 != _prices.end ()) {
					price1 = it1->second.GetMin ();
				}
				
				if (it2 != _prices.end ()) {
					price2 = it2->second.GetMin ();
				}
				break;
			case EstimateTypes::Average:
				if (it1 != _prices.end ()) {
					price1 = it1->second.GetAvg ();
				}
				
				if (it2 != _prices.end ()) {
					price2 = it2->second.GetAvg ();
				}
				break;
		}
		
		auto itCount1 = _inventory.find (d1);
		int count1 = itCount1 == _inventory.end () ? 0 : itCount1->second;
		
		auto itCount2 = _inventory.find (d2);
		int count2 = itCount2 == _inventory.end () ? 0 : itCount2->second;
		
		return price1*count1 > price2*count2; //sort backward
	});
	
	double sumPrice = 0;
	bool first = true;
	for (const string& designID : sortedDesignIDs) {
		if (!first) {
			_out << ",";
		}
		first = false;
		
		_out << "{";
		
		_out << "\"designid\":\"" << designID << "\"";
		_out << ",\"count\":" << _inventory[designID];

		auto itPrice = _prices.find (designID);
		double price = 0;
		if (itPrice != _prices.end ()) {
			switch (_type) {
				default:
				case EstimateTypes::Minimal:
					price = itPrice->second.GetMin ();
					break;
				case EstimateTypes::Average:
					price = itPrice->second.GetAvg ();
					break;
			}
		}
		
		_out << ",\"itemprice\":" << price;
		
		double fullPrice = price * _inventory[designID];
		_out << ",\"fullprice\":" << fullPrice;
		
		sumPrice += fullPrice;
		
		_out << "}";
	}
	_out << "]";
	
	_out << ",\"setprice\":" << sumPrice;
	_out << "}";
}
