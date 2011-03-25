//
//  DMCommon.m
//  ObjectiveMetrics
//
//  Created by Jørgen P. Tjernø on 3/22/11.
//  Copyright 2011 devSoft. All rights reserved.
//

#import "DMCommon.h"

#import "NSString+DMUUID.h"

static SUHost *sharedAppHost = nil;
static SUHost *sharedFrameworkHost = nil;

@implementation DMCommon

+ (SUHost *)sharedAppHost
{
    if (!sharedAppHost)
        sharedAppHost  = [[SUHost alloc] initWithBundle:[NSBundle mainBundle]];
    return [[sharedAppHost retain] autorelease];
}

+ (SUHost *)sharedFrameworkHost
{
    if (!sharedFrameworkHost)
        sharedFrameworkHost = [[SUHost alloc] initWithBundle:[NSBundle bundleWithIdentifier:@"no.devsoft.ObjectiveMetrics"]];
    return [[sharedFrameworkHost retain] autorelease];
}

@end
