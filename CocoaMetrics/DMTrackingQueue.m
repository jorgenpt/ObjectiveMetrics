//
//  DMTrackingQueue.m
//  CocoaMetrics
//
//  Created by Jørgen P. Tjernø on 3/22/11.
//  Copyright 2011 devSoft. All rights reserved.
//

#import "DMTrackingQueue.h"

#import "DMCommon.h"
#import "DMRequester.h"

static NSString * const DMEventQueueKey = @"DMEventQueue";
static NSString * const DMEventQueueMaxSizeKey = @"DMEventQueueMaxSize";
static NSString * const DMEventQueueMaxDaysOldKey = @"DMEventQueueMaxDaysOld";

static int const DMEventQueueDefaultMaxSize = 100;
static int const DMEventQueueDefaultMaxDaysOld = 7;

static double kDMEventQueueSecondsInADay = 60.0*60.0*24.0;

@interface DMTrackingQueue () <DMRequesterDelegate>

@property (retain) NSMutableArray *events, *pending;
@property (retain) DMRequester *requester;

- (void)sendBatch:(NSArray *)events;
- (BOOL)flushIfExceedsBounds;

@end

@implementation DMTrackingQueue

@synthesize events, pending, requester;

- (id)init
{
    self = [super init];
    if (self) {        
        SUHost *host = [DMCommon sharedAppHost];
        [self setRequester:[[[DMRequester alloc] initWithDelegate:self] autorelease]];

        [self setEvents:[host objectForUserDefaultsKey:DMEventQueueKey]];
        if (!events)
            [self setEvents:[NSMutableArray array]];

        /*NSArray *supportDirectories = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
        NSLog(@"%@", supportDirectories);*/

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
                                              forKey:DMEventQueueKey];
    [[NSUserDefaults standardUserDefaults] synchronize];

    [self flushIfExceedsBounds];
}

- (void)send:(NSDictionary *)event
{
    if (numberOfPendingEvents != 0)
    {
        [requester wait];
    }

    numberOfPendingEvents = -1;
    [self sendBatch:[NSArray arrayWithObject:event]];
}

- (void)sendBatch:(NSArray *)theEvents
{
    [requester send:theEvents];
}

- (NSUInteger)count
{
    return [events count];
}

- (NSDictionary *)eventAtIndex:(NSUInteger)index
{
    return (NSDictionary *)[events objectAtIndex:index];
}

- (BOOL)flushIfExceedsBounds
{
    if ([events count] > 0)
    {
        NSDictionary *oldestEvent = [events objectAtIndex:0];
        NSDate *oldestEventDate = [NSDate dateWithTimeIntervalSince1970:[[oldestEvent objectForKey:@"ts"] intValue]];
        
        if (oldestEventDate == nil)
            [self flush];
        else if ([[NSDate date] timeIntervalSinceDate:oldestEventDate] >= maxSecondsOld)
            [self flush];
        else if ([events count] >= maxSize)
            [self flush];
        else
            return NO;

        return YES;
    }

    return NO;
}

- (void)flush
{
    if (numberOfPendingEvents != 0)
    {
        [requester wait];
    }

    numberOfPendingEvents = [events count];
    [self sendBatch:events];
}

- (BOOL)blockingFlush
{
    [self flush];
    [requester wait];
    
    return [events count] == 0;
}

- (void)requestSucceeded:(DMRequester *)requester
{
    DLog(@"Request succeeded. %ld pending events.", numberOfPendingEvents);
    if (numberOfPendingEvents > 0)
    {
        [events removeObjectsInRange:NSMakeRange(0, numberOfPendingEvents)];
        [[NSUserDefaults standardUserDefaults] setObject:events
                                                  forKey:DMEventQueueKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }

    numberOfPendingEvents = 0;
}

@end
