//
//  BrickLinkElementListQuery.hpp
//  estlego
//
//  Created by Laki, Zoltan on 2017. 02. 20..
//  Copyright © 2017. Graphisoft. All rights reserved.
//

#ifndef BrickLinkElementListQuery_hpp
#define BrickLinkElementListQuery_hpp

#import <Foundation/Foundation.h>

class BrickLinkSetPrices {
	std::map<std::string, std::string> _prices;
	
public:
	BrickLinkSetPrices () {}
	BrickLinkSetPrices (const std::map<std::string, std::string>& prices) : _prices (prices) {}
	
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

class BrickLinkInventoryItem {
	std::string _imgUrl;
	int _count;
	std::string _designID;
	std::string _itemUrl;
	std::string _priceGuideUrl;
	
public:
	BrickLinkInventoryItem (const std::string& imgUrl, int count, const std::string& designID, const std::string& itemUrl, const std::string& priceGuideUrl) : _imgUrl (imgUrl), _count (count), _designID (designID), _itemUrl (itemUrl), _priceGuideUrl (priceGuideUrl) {}
	
	const std::string& GetImgUrl () const { return _imgUrl; }
	int GetCount () const { return _count; }
	const std::string& GetDesignID () const { return _designID; }
	const std::string& GetItemUrl () const { return _itemUrl; }
	const std::string& GetPriceGuideUrl () const { return _priceGuideUrl; }
};

class BrickLinkElementListQuery {
	std::string _setNumber;
	int _setID;
	BrickLinkSetPrices _prices;
	std::vector<BrickLinkInventoryItem> _inventory;
	
	static NSString* DownloadWebPage (NSURL* url);
	static NSString* TrimToEndOfString (NSString* str, NSString* search);
	static int GetSetIDFromPage (NSString* idPage);
	static std::map<std::string, std::string> GetPricesFromPage (NSString* pricePage);
	static std::vector<BrickLinkInventoryItem> GetInventoryListFromPage (NSString* invPage);

public:
	BrickLinkElementListQuery (const std::string& setNumber) : _setNumber (setNumber) {}
	
	bool RunQuery ();
	
	int GetSetID () const { return _setID; }
	const std::string& GetSetNumber () const { return _setNumber; }
	const BrickLinkSetPrices& GetPrices () const { return _prices; }
	const std::vector<BrickLinkInventoryItem>& GetInventory () const { return _inventory; }
};

#endif /* BrickLinkElementListQuery_hpp */
