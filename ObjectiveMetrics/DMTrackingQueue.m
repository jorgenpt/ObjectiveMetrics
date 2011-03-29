//
//  DMTrackingQueue.m
//  ObjectiveMetrics
//
//  Created by Jørgen P. Tjernø on 3/22/11.
//  Copyright 2011 devSoft. All rights reserved.
//

#import "DMTrackingQueue.h"

#import "DMRequester.h"

static NSString * const DMEventQueueKey = @"DMEventQueue";
static NSString * const DMEventQueueMaxSizeKey = @"DMEventQueueMaxSize";
static NSString * const DMEventQueueMaxDaysOldKey = @"DMEventQueueMaxDaysOld";
static NSString * const DMNullPlaceholder = @"<[Aija8kua]NULL-VALUE[ep6gae3U]>";

static int const DMEventQueueDefaultMaxSize = 100;
static int const DMEventQueueDefaultMaxDaysOld = 7;

static double kDMEventQueueSecondsInADay = 60.0*60.0*24.0;

@interface DMTrackingQueue () <DMRequesterDelegate>

@property (retain) NSMutableArray *events, *pending;
@property (retain) DMRequester *requester;

- (void)sendRange:(NSRange)range;
- (BOOL)flushIfExceedsBounds;
- (void)save;
- (void)load;

@end

@implementation DMTrackingQueue

@synthesize events, pending, requester;

- (id)init
{
    self = [super init];
    if (self) {
        SUHost *host = [DMHosts sharedAppHost];
        [self setRequester:[[[DMRequester alloc] initWithDelegate:self] autorelease]];

        /* TODO: Use NSApplicationSupportDirectory for the queue?
        NSArray *supportDirectories = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
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

        [self load];
    }

    return self;
}

- (void)dealloc
{
    [self setEvents:nil];

    [super dealloc];
}

- (NSUInteger)count
{
    return [events count];
}

- (NSDictionary *)eventAtIndex:(NSUInteger)index
{
    return (NSDictionary *)[events objectAtIndex:index];
}

- (void)add:(NSDictionary *)event
{
    [events addObject:event];
    [self save];
    [self flushIfExceedsBounds];
}

- (void)send:(NSDictionary *)event
{
    if (pendingEvents.length > 0)
        [requester wait];

    [events addObject:event];
    NSRange toSend = NSMakeRange([events count] - 1, 1);

    [self sendRange:toSend];
}

- (void)sendRange:(NSRange)range;
{
    pendingEvents = range;
    [requester send:[events subarrayWithRange:range]];
}

- (void)flush
{
    if (pendingEvents.length > 0)
        [requester wait];

    [self sendRange:NSMakeRange(0, [events count])];
}

- (BOOL)blockingFlush
{
    [self flush];
    [requester wait];

    return [events count] == 0;
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

- (void)save
{
    NSMutableArray *outputEvents = [NSMutableArray array];
    for (NSDictionary *immutableMessage in events)
    {
        NSMutableDictionary *message = [NSMutableDictionary dictionaryWithDictionary:immutableMessage];

        for (NSString *key in [message allKeysForObject:[NSNull null]])
        {
            [message setObject:DMNullPlaceholder
                        forKey:key];
        }

        [outputEvents addObject:message];
    }

    [[NSUserDefaults standardUserDefaults] setObject:outputEvents
                                              forKey:DMEventQueueKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)load
{
    NSArray *loadedEvents = [[NSUserDefaults standardUserDefaults] objectForKey:DMEventQueueKey];
    if (!loadedEvents)
        loadedEvents = [NSArray array];

    [self setEvents:[NSMutableArray array]];
    for (NSDictionary *immutableMessage in loadedEvents)
    {
        if (![immutableMessage isKindOfClass:[NSDictionary class]])
            continue;

        NSMutableDictionary *message = [NSMutableDictionary dictionaryWithDictionary:immutableMessage];
        for (NSString *key in [message allKeys])
        {
            id value = [message objectForKey:key];
            if ([value isKindOfClass:[NSString class]] && [value isEqualToString:DMNullPlaceholder])
            {
                [message setObject:[NSNull null]
                            forKey:key];
            }
        }

        [events addObject:message];
    }
}

- (void)requestSucceeded:(DMRequester *)requester
{
    DLog(@"Request succeeded. Removing events [%ld, %ld)", pendingEvents.location, pendingEvents.location + pendingEvents.length);
    if (pendingEvents.length > 0)
    {
        [events removeObjectsInRange:pendingEvents];
        [self save];
    }

    pendingEvents.location = pendingEvents.length = 0;
}

@end
