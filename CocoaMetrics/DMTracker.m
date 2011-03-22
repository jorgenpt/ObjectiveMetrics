//
//  DMTracker.m
//  CocoaMetrics
//
//  Created by Jørgen P. Tjernø on 3/22/11.
//  Copyright 2011 devSoft. All rights reserved.
//

#import "DMTracker.h"


@implementation DMTracker

@synthesize appId;
@synthesize queue;

- (id)init
{
    self = [super init];
    if (self) {
        [self setAppId:nil];
        [self setQueue:[[[DMEventQueue alloc] init] autorelease]];
    }

    return self;
}

- (id)initWithAppId:(NSString *)theAppId
{
    self = [self init];
    if (self) {
        [self setAppId:theAppId];
    }

    return self;
}

- (void)dealloc
{
    [self setAppId:nil];
    [self setQueue:nil];
    
    [super dealloc];
}

- (void)trackEventInCategory:(NSString *)theCategory
                    withName:(NSString *)theName
{
    
}

- (void)trackEventInCategory:(NSString *)theCategory
                    withName:(NSString *)theName
                       value:(NSString *)theValue
{
    
}

- (void)trackEventInCategory:(NSString *)theCategory
                    withName:(NSString *)theName
                secondsSpent:(int)theSeconds
                   completed:(BOOL)wasCompleted
{
    
}

- (void)trackLog:(NSString *)message
{
    
}

- (void)trackCustomDataWithName:(NSString *)theName
                          value:(NSString *)theValue
{
    
}

- (void)trackCustomDataRealtimeWithName:(NSString *)theName
                                  value:(NSString *)theValue
{
    
}

- (void)trackException:(NSException *)theException
{
    
}

@end
