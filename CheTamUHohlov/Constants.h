//
//  Constants.h
//  CheTamUHohlov
//
//  Created by Roman.Safin on 1/7/16.
//  Copyright © 2016 Roman.Safin. All rights reserved.
//

#ifndef Constants_h
#define Constants_h
#define LinkToData @"http://nbu1.bank.gov.ua/NBUStatService/v1/statdirectory/exchange?json"
#define MainTableName @"CurrencyRate"
#define DBName @"DiziDB.sqlite"
#define NotificationAboutLoadingData @"NotificationReceivedDataFromServer"

#define TestLinkToData @"https://query.yahooapis.com/v1/public/yql?q=select+*+from+yahoo.finance.xchange+where+pair+=+%22USDRUB,EURRUB%22&format=json&env=store%3A%2F%2Fdatatables.org%2Falltableswithkeys&callback=" //test yahoo

#endif /* Constants_h */
