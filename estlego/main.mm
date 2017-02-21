//
//  main.m
//  estlego
//
//  Created by Laki, Zoltan on 2017. 02. 20..
//  Copyright © 2017. Graphisoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "Config.hpp"
#include "BrickLinkElementListQuery.hpp"
#include "BrickLinkElementPriceQuery.hpp"
#include "SetOutput.hpp"
#include "PriceRecord.hpp"
#include "EstimateOutput.hpp"

using namespace std;

int main(int argc, const char * argv[]) {
	@autoreleasepool {
		//Parse parameters
		Config cfg (argc, argv);
		if (!cfg) {
			return cfg.DumpUsage ();
		}
		
		//Do the estimation
		for (string setNumber : cfg.GetSetNumbers ()) {
			cout << "Querying the set with id: " << setNumber << endl;

			//Get element list of the set
			BrickLinkElementListQuery elementQuery (setNumber);
			if (!elementQuery.RunQuery ()) {
				cerr << "Cannot query set with number: " << setNumber << endl;
				continue;
			}
			
			//Get all prices of the set
			cout << "Querying the elements..." << endl;
			
			size_t elementCount = elementQuery.GetInventory ().size ();
			size_t elementIndex = 0;
			
			map<string, BrickLinkElementPrices> elementPrices;
			for (BrickLinkInventoryItem item : elementQuery.GetInventory ()) {
				BrickLinkElementPriceQuery priceQuery (item.GetDesignID (), item.GetPriceGuideUrl ());
				if (!priceQuery.RunQuery ()) {
					cerr << "Cannot query prices for set number: " << setNumber << ", and design ID: " << item.GetDesignID () << endl;
					continue;
				}
				
				elementPrices.emplace (priceQuery.GetDesignID (), priceQuery.GetPrices ());
				
				cout << "Element " << ++elementIndex << " of " << elementCount << "      \r";
				cout.flush ();
			}
			
			cout << endl;
			
			//Dump the set's element list
			cout << "Dump elements of set with id: " << setNumber << endl;

			map<string, int> setInventory;
			map<string, PriceRecord> last6NewPrices;
			map<string, PriceRecord> last6UsedPrices;
			map<string, PriceRecord> currentNewPrices;
			map<string, PriceRecord> currentUsedPrices;
			for (BrickLinkInventoryItem item : elementQuery.GetInventory ()) {
				setInventory.emplace (item.GetDesignID (), item.GetCount ());
				
				auto itPrice = elementPrices.find (item.GetDesignID ());
				if (itPrice != elementPrices.end ()) {
					const BrickLinkElementPrices& price = itPrice->second;
					last6NewPrices.emplace (item.GetDesignID (), PriceRecord (price.GetLast6NewMin (), price.GetLast6NewAvg (), price.GetLast6NewQtyAvg (), price.GetLast6NewMax ()));
					last6UsedPrices.emplace (item.GetDesignID (), PriceRecord (price.GetLast6UsedMin (), price.GetLast6UsedAvg (), price.GetLast6UsedQtyAvg (), price.GetLast6UsedMax ()));
					currentNewPrices.emplace (item.GetDesignID (), PriceRecord (price.GetCurrentNewMin (), price.GetCurrentNewAvg (), price.GetCurrentNewQtyAvg (), price.GetCurrentNewMax ()));
					currentUsedPrices.emplace (item.GetDesignID (), PriceRecord (price.GetCurrentUsedMin (), price.GetCurrentUsedAvg (), price.GetCurrentUsedQtyAvg (), price.GetCurrentUsedMax ()));
				}
			}
			
			SetOutput output (cout, setNumber, setInventory, last6NewPrices, last6UsedPrices, currentNewPrices, currentUsedPrices);
			output.Dump ();
			
			cout << endl;
			
			//Estimate and dump prices
			cout << "Dump estimations of set with id: " << setNumber << endl;
			
			if (cfg.GetCalculationPrices () & Price_MinimalNew) {
				EstimateOutput est (cout, setNumber, setInventory, currentNewPrices, EstimateTypes::Minimal, "new");
				est.Dump ();
				cout << endl;
			}
			
			if (cfg.GetCalculationPrices () & Price_AverageNew) {
				EstimateOutput est (cout, setNumber, setInventory, currentNewPrices, EstimateTypes::Average, "new");
				est.Dump ();
				cout << endl;
			}
			
			if (cfg.GetCalculationPrices () & Price_MinimalUsed) {
				EstimateOutput est (cout, setNumber, setInventory, currentUsedPrices, EstimateTypes::Minimal, "used");
				est.Dump ();
				cout << endl;
			}
			
			if (cfg.GetCalculationPrices () & Price_AverageUsed) {
				EstimateOutput est (cout, setNumber, setInventory, currentUsedPrices, EstimateTypes::Average, "used");
				est.Dump ();
				cout << endl;
			}
		}
	}
	
    return 0;
}
