//
//  Constants.h
//  CheTamUHohlov
//
//  Created by Roman.Safin on 1/7/16.
//  Copyright © 2016 Roman.Safin. All rights reserved.
//

#ifndef Constants_h
#define Constants_h
#define LinkToGovData @"http://bank.gov.ua/NBUStatService/v1/statdirectory/exchange?json"
#define LinkToYahooData @"https://query.yahooapis.com/v1/public/yql?q=select+*+from+yahoo.finance.xchange+where+pair+=+%22USDRUB,EURRUB%22&format=json&env=store%3A%2F%2Fdatatables.org%2Falltableswithkeys&callback="
#define LinkToGovDataOnDate @"http://bank.gov.ua/NBUStatService/v1/statdirectory/exchange?date=20160129&json"
#define TableNameWithGovData @"CurrencyRate"
#define TableNameWithYahooData @"yahooCurrencyRate"
#define DBName @"DiziDB.sqlite"
#define NotificationAboutLoadingGovData @"NotificationReceivedDataFromGovServer"
#define NotificationAboutLoadingYahooData @"NotificationReceivedDataFromYahooServer"

#endif /* Constants_h */
