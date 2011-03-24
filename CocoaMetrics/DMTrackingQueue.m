//
//  DMTrackingQueue.m
//  CocoaMetrics
//
//  Created by Jørgen P. Tjernø on 3/22/11.
//  Copyright 2011 devSoft. All rights reserved.
//

#import "DMTrackingQueue.h"

#import "DMCommon.h"

static NSString * const DMEventQueueKey = @"DMEventQueue";
static NSString * const DMEventQueueMaxSizeKey = @"DMEventQueueMaxSize";
static NSString * const DMEventQueueMaxDaysOldKey = @"DMEventQueueMaxDaysOld";
static NSString * const DMAnalyticsURLKey = @"DMAnalyticsURL";
static NSString * const DMAppIdKey = @"DMAppId";

static NSString * const DMAnalyticsURLFormat = @"http://%@.api.deskmetrics.com/sendData";
static int const DMEventQueueDefaultMaxSize = 100;
static int const DMEventQueueDefaultMaxDaysOld = 7;

static double kDMEventQueueSecondsInADay = 60.0*60.0*24.0;

@interface DMTrackingQueue ()

@property (retain) NSMutableArray *events;
@property (retain) NSString *analyticsURL;

@end

@implementation DMTrackingQueue

@synthesize events;
@synthesize analyticsURL;

- (id)init
{
    self = [super init];
    if (self) {        
        SUHost *host = [DMCommon sharedAppHost];

        [self setEvents:[host objectForUserDefaultsKey: DMEventQueueKey]];
        if (!events) {
            [self setEvents:[NSMutableArray array]];
        }

        NSArray *supportDirectories = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
        NSLog(@"%@", supportDirectories);

        if ([host objectForKey:DMEventQueueMaxSizeKey] == nil)
            maxSize = DMEventQueueDefaultMaxSize;
        else
            maxSize = [[host objectForKey:DMEventQueueMaxSizeKey] intValue];

        int maxDaysOld;
        if ([host objectForKey:DMEventQueueMaxDaysOldKey] == nil)
            maxDaysOld = DMEventQueueDefaultMaxDaysOld;
        else
            maxDaysOld = [[host objectForKey:DMEventQueueMaxDaysOldKey] intValue];

        maxSecondsOld = maxDaysOld * kDMEventQueueSecondsInADay;
        
        [self setAnalyticsURL:[host objectForInfoDictionaryKey:DMAnalyticsURLKey]];
        if (!analyticsURL)
        {
            NSString *appId = [host objectForInfoDictionaryKey:DMAppIdKey];
            if (!appId)
            {
                NSLog(@"Could not find neither %@ nor %@ in Info.plist!", DMAnalyticsURLKey, DMAppIdKey);
                [self release];
                return nil;
            }

            [self setAnalyticsURL:[NSString stringWithFormat:DMAnalyticsURLFormat, appId]];
        }
        
        [self flushIfExceedsBounds];
    }
    
    return self;
}

- (void)dealloc
{
    [self setEvents:nil];

    [super dealloc];
}

- (void)add:(NSDictionary *)event
{
    [events addObject:event];
    [[NSUserDefaults standardUserDefaults] setObject:events
                                              forKey: DMEventQueueKey];
    
    [self flushIfExceedsBounds];
}

- (void)send:(NSDictionary *)event
{
    [self sendBatch:[NSArray arrayWithObject:event]];
}

- (void)sendBatch:(NSArray *)events
{
    
}

- (BOOL)flushIfExceedsBounds
{
    if ([events count] > 0)
    {
        NSDictionary *oldestEvent = [events objectAtIndex:0];
        NSDate *oldestEventDate = [NSDate dateWithTimeIntervalSince1970:[[oldestEvent objectForKey:@"ts"] intValue]];
        
        if (oldestEventDate == nil)
            return [self flush];
        
        if ([[NSDate date] timeIntervalSinceDate:oldestEventDate] >= maxSecondsOld)
            return [self flush];

        if ([events count] >= maxSize)
            return [self flush];
    }

    return NO;
}

- (BOOL)flush
{
    [self sendBatch:[self events]];
    return YES;
}

@end
