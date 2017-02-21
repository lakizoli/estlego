//
//  BrickLinkElementListQuery.mm
//  estlego
//
//  Created by Laki, Zoltan on 2017. 02. 20..
//  Copyright © 2017. Graphisoft. All rights reserved.
//

#include "BrickLinkElementListQuery.hpp"

using namespace std;

NSString* BrickLinkElementListQuery::DownloadWebPage (NSURL* url) {
	__block NSString* result = nil;
	__block volatile BOOL callEnded = NO;
	NSURLSession* defaultSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
	NSURLSessionDataTask* dataTask = [defaultSession dataTaskWithURL:url completionHandler:
									  ^(NSData* _Nullable data, NSURLResponse* _Nullable response, NSError* _Nullable error) {
										  if (error == nil) {
											  result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
										  }
										  
										  callEnded = YES;
									  }];
	[dataTask resume];
	
	while (!callEnded) {
		[NSThread sleepForTimeInterval:0.1];
	}
	
	return result;
}

NSString* BrickLinkElementListQuery::TrimToEndOfString (NSString* str, NSString* search) {
	NSRange rangeVar = [str rangeOfString:search];
	if(rangeVar.location == NSNotFound) {
		return nil;
	}
	
	rangeVar.location += rangeVar.length;
	rangeVar.length = [str length] - rangeVar.location;
	return [str substringWithRange:rangeVar];
}

int BrickLinkElementListQuery::GetSetIDFromPage (NSString* idPage) {
	NSString* eqBegin = TrimToEndOfString (idPage, @"_var_item");
	if (eqBegin == nil) {
		return 0;
	}
	
	NSString* itemEnd = TrimToEndOfString (eqBegin, @"idItem");
	if (itemEnd == nil) {
		return 0;
	}
	
	NSString* itemSepEnd = TrimToEndOfString (itemEnd, @":");
	if (itemSepEnd == nil) {
		return 0;
	}
	
	NSString* valueString = [itemSepEnd stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	if (itemSepEnd == nil) {
		return 0;
	}
	
	return atoi ([valueString UTF8String]);
}

map<string, string> BrickLinkElementListQuery::GetPricesFromPage (NSString* pricePage) {
	NSString* contentBegin = TrimToEndOfString (pricePage, @"_idMainPGContents");
	if (contentBegin == nil) {
		return map<string, string> ();
	}
	
	vector<string> keys { "Last6NewMin", "Last6NewAvg", "Last6NewQtyAvg", "Last6NewMax",
		"Last6UsedMin", "Last6UsedAvg", "Last6UsedQtyAvg", "Last6UsedMax",
		"CurrentNewMin", "CurrentNewAvg", "CurrentNewQtyAvg", "CurrentNewMax",
		"CurrentUsedMin", "CurrentUsedAvg", "CurrentUsedQtyAvg", "CurrentUsedMax"};
	map<string, string> res;
	
	NSString* lastPos = contentBegin;
	size_t keyIndex = 0;
	for (int i = 0;i < 4; ++i) { //Last 6 Month New, Last 6 Month Used, Current New, Current Used
		lastPos = TrimToEndOfString (lastPos, @"pcipgSummaryTable");
		if (lastPos == nil) {
			return map<string, string> ();
		}

		for (int j = 0;j < 4;++j) { //Min, Avg, Qty Avg, Max
			lastPos = TrimToEndOfString (lastPos, @"Price:");
			if (lastPos == nil) {
				return map<string, string> ();
			}
			
			lastPos = TrimToEndOfString (lastPos, @"<b>");
			if (lastPos == nil) {
				return map<string, string> ();
			}
			
			NSRange priceRange = [lastPos rangeOfString:@"</"];
			NSString* price = [lastPos substringWithRange:{0, priceRange.location}];
			if (price == nil) {
				return map<string, string> ();
			}
			
			res[keys[keyIndex++]] = [price UTF8String];
		}
	}
	
	return res;
}

vector<BrickLinkInventoryItem> BrickLinkElementListQuery::GetInventoryListFromPage (NSString* invPage) {
	NSString* contentBegin = TrimToEndOfString (invPage, @"_idMainINVContents");
	if (contentBegin == nil) {
		return vector<BrickLinkInventoryItem> ();
	}
	
	vector<BrickLinkInventoryItem> res;
	bool firstExtraFound = false;
	
	NSString* lastPos = contentBegin;
	while (lastPos) {
		//Get class of row
		lastPos = TrimToEndOfString (lastPos, @"<TR");
		if (lastPos == nil) {
			return vector<BrickLinkInventoryItem> ();
		}
		
		lastPos = TrimToEndOfString (lastPos, @"class=\"");
		if (lastPos == nil) {
			return vector<BrickLinkInventoryItem> ();
		}
		
		NSRange range = [lastPos rangeOfString:@"\""];
		NSString* val = [lastPos substringWithRange:{0, range.location}];
		if (val == nil) {
			return vector<BrickLinkInventoryItem> ();
		}
		
		if ([val compare:@"pciinvExtraHeader"] == NSOrderedSame) {
			if (!firstExtraFound) {
				firstExtraFound = true;
				continue;
			}
			
			//End of minifigs found!
			break;
		} else if ([val compare:@"pciinvItemTypeHeader"] == NSOrderedSame) { //We found the minifigs header! So jump to the next item in the list...
			continue;
		} else if ([val compare:@"pciinvSummaryTypeHeader"] == NSOrderedSame) { //We found the summary table! So we ended here...
			//End of table found
			break;
		}
		
		//Check the row begin
		val = TrimToEndOfString (val, @"pciinvItemRow");
		if (val == nil) { //Ignore non item rows
			continue;
		}
		
		//Get thumbnail url
		lastPos = TrimToEndOfString (lastPos, @"</TD>");
		if (lastPos == nil) {
			return vector<BrickLinkInventoryItem> ();
		}
		
		lastPos = TrimToEndOfString (lastPos, @"src=\"");
		if (lastPos == nil) {
			return vector<BrickLinkInventoryItem> ();
		}
		
		range = [lastPos rangeOfString:@"\""];
		val = [lastPos substringWithRange:{0, range.location}];
		if (val == nil) {
			return vector<BrickLinkInventoryItem> ();
		}
		
		string imgUrl ([val UTF8String]);
		
		//Get count
		lastPos = TrimToEndOfString (lastPos, @"<TD>");
		if (lastPos == nil) {
			return vector<BrickLinkInventoryItem> ();
		}
		
		range = [lastPos rangeOfString:@"</TD>"];
		val = [lastPos substringWithRange:{0, range.location}];
		if (val == nil) {
			return vector<BrickLinkInventoryItem> ();
		}
		
		int count = atoi ([val UTF8String]);
		
		//Get item url
		lastPos = TrimToEndOfString (lastPos, @"href=\"");
		if (lastPos == nil) {
			return vector<BrickLinkInventoryItem> ();
		}

		range = [lastPos rangeOfString:@"\""];
		val = [lastPos substringWithRange:{0, range.location}];
		if (val == nil) {
			return vector<BrickLinkInventoryItem> ();
		}

		string itemUrl ([val UTF8String]);

		//Get design id
		lastPos = TrimToEndOfString (lastPos, @">");
		if (lastPos == nil) {
			return vector<BrickLinkInventoryItem> ();
		}
		
		range = [lastPos rangeOfString:@"</A>"];
		val = [lastPos substringWithRange:{0, range.location}];
		if (val == nil) {
			return vector<BrickLinkInventoryItem> ();
		}
		
		string designID ([val UTF8String]);
		
		//Get price guid url
		lastPos = TrimToEndOfString (lastPos, @"</TD>");
		if (lastPos == nil) {
			return vector<BrickLinkInventoryItem> ();
		}
		
		lastPos = TrimToEndOfString (lastPos, @"</TD>");
		if (lastPos == nil) {
			return vector<BrickLinkInventoryItem> ();
		}
		
		lastPos = TrimToEndOfString (lastPos, @"href=\"");
		if (lastPos == nil) {
			return vector<BrickLinkInventoryItem> ();
		}
		
		range = [lastPos rangeOfString:@"\""];
		val = [lastPos substringWithRange:{0, range.location}];
		if (val == nil) {
			return vector<BrickLinkInventoryItem> ();
		}
		
		string priceGuideUrl ([val UTF8String]);
		
		//Store item in list
		res.emplace_back (imgUrl, count, designID, itemUrl, priceGuideUrl);
	}

	return res;
}

bool BrickLinkElementListQuery::RunQuery () {
	@autoreleasepool {
		//Get page to determine bricklink id of the set
		//http://www.bricklink.com/v2/catalog/catalogitem.page?S=375-2
		NSString* formatUrl = [NSString stringWithFormat:@"http://www.bricklink.com/v2/catalog/catalogitem.page?S=%s", _setNumber.c_str ()];
		NSString* page = DownloadWebPage ([NSURL URLWithString:formatUrl]);
		if (page == nil) {
			printf ("Cannot query bricklink page of the set: %s\n", _setNumber.c_str ());
			return false;
		}
		
		_setID = GetSetIDFromPage (page);
		if (_setID <= 0) {
			printf ("Cannot parse set id from bricklink page of the set: %s\n", _setNumber.c_str ());
			return false;
		}
		
		//Get price guide of the page (full set price)
		//http://www.bricklink.com/v2/catalog/catalogitem_pgtab.page?idItem=4351
		formatUrl = [NSString stringWithFormat:@"http://www.bricklink.com/v2/catalog/catalogitem_pgtab.page?idItem=%d", _setID];
		page = DownloadWebPage ([NSURL URLWithString:formatUrl]);
		if (page == nil) {
			printf ("Cannot query bricklink price guide page of the set: %s\n", _setNumber.c_str ());
			return false;
		}

		map<string, string> prices = GetPricesFromPage (page);
		if (prices.size () <= 0) {
			printf ("Cannot parse prices from price guide page of the set: %s\n", _setNumber.c_str ());
			return false;
		}
		
		_prices = BrickLinkSetPrices (prices);
		
		//Get inventory of the page (inventory set)
		//http://www.bricklink.com/v2/catalog/catalogitem_invtab.page?idItem=4351
		formatUrl = [NSString stringWithFormat:@"http://www.bricklink.com/v2/catalog/catalogitem_invtab.page?idItem=%d", _setID];
		page = DownloadWebPage ([NSURL URLWithString:formatUrl]);
		if (page == nil) {
			printf ("Cannot query bricklink inventory page of the set: %s\n", _setNumber.c_str ());
			return false;
		}
		
		_inventory = GetInventoryListFromPage (page);
		if (_inventory.size () <= 0) {
			printf ("Cannot parse bricklink inventory page of the set: %s\n", _setNumber.c_str ());
			return false;
		}
		
		return true;
	}
}
