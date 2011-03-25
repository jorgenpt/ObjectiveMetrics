//
//  DMCommon.h
//  CocoaMetrics
//
//  Created by Jørgen P. Tjernø on 3/22/11.
//  Copyright 2011 devSoft. All rights reserved.
//

#import "SUHost.h"

@interface DMCommon : NSObject

+ (SUHost *)sharedAppHost;
+ (SUHost *)sharedFrameworkHost;

@end
