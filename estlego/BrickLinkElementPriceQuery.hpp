//
//  BrickLinkElementPriceQuery.hpp
//  estlego
//
//  Created by Laki, Zoltan on 2017. 02. 21..
//  Copyright © 2017. Graphisoft. All rights reserved.
//

#ifndef BrickLinkElementPriceQuery_hpp
#define BrickLinkElementPriceQuery_hpp

#import <Foundation/Foundation.h>

class BrickLinkElementPrices {
	std::map<std::string, std::string> _prices;
	
public:
	BrickLinkElementPrices () {}
	BrickLinkElementPrices (const std::map<std::string, std::string>& prices) : _prices (prices) {}
	
	const std::string& GetLast6NewMin () const { return _prices.find ("Last6NewMin")->second; }
	const std::string& GetLast6NewAvg () const { return _prices.find ("Last6NewAvg")->second; }
	const std::string& GetLast6NewQtyAvg () const { return _prices.find ("Last6NewQtyAvg")->second; }
	const std::string& GetLast6NewMax () const { return _prices.find ("Last6NewMax")->second; }
	
	const std::string& GetLast6UsedMin () const { return _prices.find ("Last6UsedMin")->second; }
	const std::string& GetLast6UsedAvg () const { return _prices.find ("Last6UsedAvg")->second; }
	const std::string& GetLast6UsedQtyAvg () const { return _prices.find ("Last6UsedQtyAvg")->second; }
	const std::string& GetLast6UsedMax () const { return _prices.find ("Last6UsedMax")->second; }
	
	const std::string& GetCurrentNewMin () const { return _prices.find ("CurrentNewMin")->second; }
	const std::string& GetCurrentNewAvg () const { return _prices.find ("CurrentNewAvg")->second; }
	const std::string& GetCurrentNewQtyAvg () const { return _prices.find ("CurrentNewQtyAvg")->second; }
	const std::string& GetCurrentNewMax () const { return _prices.find ("CurrentNewMax")->second; }
	
	const std::string& GetCurrentUsedMin () const { return _prices.find ("CurrentUsedMin")->second; }
	const std::string& GetCurrentUsedAvg () const { return _prices.find ("CurrentUsedAvg")->second; }
	const std::string& GetCurrentUsedQtyAvg () const { return _prices.find ("CurrentUsedQtyAvg")->second; }
	const std::string& GetCurrentUsedMax () const { return _prices.find ("CurrentUsedMax")->second; }
};

class BrickLinkElementPriceQuery {
	std::string _designID;
	std::string _url;
	BrickLinkElementPrices _prices;

	static NSString* DownloadWebPage (NSURL* url);
	static NSString* TrimToEndOfString (NSString* str, NSString* search);
	static std::map<std::string, std::string> GetPricesFromPage (NSString* pricePage);

public:
	BrickLinkElementPriceQuery (const std::string& designID, const std::string& url);
	
	bool RunQuery ();
	
	const std::string& GetDesignID () const { return _designID; }
	const BrickLinkElementPrices& GetPrices () const { return _prices; }
};

#endif /* BrickLinkElementPriceQuery_hpp */
