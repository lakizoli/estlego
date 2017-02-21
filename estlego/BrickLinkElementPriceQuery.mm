//
//  BrickLinkElementPriceQuery.mm
//  estlego
//
//  Created by Laki, Zoltan on 2017. 02. 21..
//  Copyright © 2017. Graphisoft. All rights reserved.
//

#include "BrickLinkElementPriceQuery.hpp"

using namespace std;

NSString* BrickLinkElementPriceQuery::DownloadWebPage (NSURL* url) {
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

NSString* BrickLinkElementPriceQuery::TrimToEndOfString (NSString* str, NSString* search) {
	NSRange rangeVar = [str rangeOfString:search];
	if(rangeVar.location == NSNotFound) {
		return nil;
	}
	
	rangeVar.location += rangeVar.length;
	rangeVar.length = [str length] - rangeVar.location;
	return [str substringWithRange:rangeVar];
}

map<string, string> BrickLinkElementPriceQuery::GetPricesFromPage (NSString* pricePage) {
	NSString* lastPos = TrimToEndOfString (pricePage, @"<B>Last");
	if (lastPos == nil) {
		return map<string, string> ();
	}
	
	lastPos = TrimToEndOfString (lastPos, @"<TR BGCOLOR=\"#C0C0C0\"");
	if (lastPos == nil) {
		return map<string, string> ();
	}

	vector<string> keys { "Last6NewMin", "Last6NewAvg", "Last6NewQtyAvg", "Last6NewMax",
		"Last6UsedMin", "Last6UsedAvg", "Last6UsedQtyAvg", "Last6UsedMax",
		"CurrentNewMin", "CurrentNewAvg", "CurrentNewQtyAvg", "CurrentNewMax",
		"CurrentUsedMin", "CurrentUsedAvg", "CurrentUsedQtyAvg", "CurrentUsedMax"};
	map<string, string> res;
	
	size_t keyIndex = 0;
	for (int i = 0;i < 4; ++i) { //Last 6 Month New, Last 6 Month Used, Current New, Current Used
		lastPos = TrimToEndOfString (lastPos, @"<TD VALIGN=\"TOP\"");
		if (lastPos == nil) {
			return map<string, string> ();
		}
		
		NSRange priceBeginRange = [lastPos rangeOfString:@"Price:"];
		NSRange nextBeginRange = [lastPos rangeOfString:i == 3 ? @"<TR VALIGN=\"TOP\"" : @"<TD VALIGN=\"TOP\""];
		
		if (priceBeginRange.location != NSNotFound && nextBeginRange.location != NSNotFound && priceBeginRange.location < nextBeginRange.location) {
			for (int j = 0;j < 4;++j) { //Min, Avg, Qty Avg, Max
				lastPos = TrimToEndOfString (lastPos, @"Price:");
				if (lastPos == nil) {
					return map<string, string> ();
				}
				
				lastPos = TrimToEndOfString (lastPos, @"<B>");
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
		} else { //Price unavailable in this section
			for (int j = 0;j < 4;++j) { //Min, Avg, Qty Avg, Max
				res[keys[keyIndex++]] = "-";
			}
		}
	}
	
	return res;
}

BrickLinkElementPriceQuery::BrickLinkElementPriceQuery (const string& designID, const string& url) : _designID (designID), _url (url) {
}

bool BrickLinkElementPriceQuery::RunQuery () {
	@autoreleasepool {
		//Get price guide of the element
		NSString* page = DownloadWebPage ([NSURL URLWithString:[NSString stringWithUTF8String:_url.c_str ()]]);
		if (page == nil) {
			printf ("Cannot query bricklink price guide page of the element with design ID: %s\n", _designID.c_str ());
			return false;
		}
		
		map<string, string> prices = GetPricesFromPage (page);
		if (prices.size () <= 0) {
			printf ("Cannot parse prices from price guide page of the element with design ID: %s\n", _designID.c_str ());
			return false;
		}
		
		_prices = BrickLinkElementPrices (prices);
	}
	
	return true;
}
