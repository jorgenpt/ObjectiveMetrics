//
//  DMTracker.m
//  CocoaMetrics
//
//  Created by Jørgen P. Tjernø on 3/22/11.
//  Copyright 2011 devSoft. All rights reserved.
//

#import "DMTracker.h"

#import "DMTrackingQueue.h"
#import "NSString+DMUUID.h"

static NSString * const DMFieldSession = @"ss";
static NSString * const DMFieldType = @"tp";
static NSString * const DMFieldTimestamp = @"ts";
static NSString * const DMFieldFlow = @"fl";
static NSString * const DMFieldCategory = @"ca";
static NSString * const DMFieldName = @"nm";
static NSString * const DMFieldValue = @"vl";
static NSString * const DMFieldEventTime = @"tm";
static NSString * const DMFieldEventConcluded = @"ec";
static NSString * const DMFieldMessage = @"ms";
static NSString * const DMFieldExceptionMessage = @"msg";
static NSString * const DMFieldExceptionSource = @"src";
static NSString * const DMFieldExceptionStack = @"stk";
static NSString * const DMFieldExceptionTargetSite = @"tgs";

static NSString * const DMTypeStartApp = @"strApp";
static NSString * const DMTypeStopApp = @"stApp";
static NSString * const DMTypeEvent = @"ev";
static NSString * const DMTypeEventValue = @"evV";
static NSString * const DMTypeEventTimedStart = @"evS";
static NSString * const DMTypeEventTimedStop = @"evST";
static NSString * const DMTypeEventCancel = @"evC";
static NSString * const DMTypeEventPeriod = @"evP";
static NSString * const DMTypeLog = @"lg";
static NSString * const DMTypeCustomData = @"ctD";
static NSString * const DMTypeCustomDataR = @"ctDR";
static NSString * const DMTypeException = @"exC";

static DMTracker* defaultInstance = nil;

@interface DMTracker ()

@property (retain) DMTrackingQueue *queue;
@property (retain) NSString *session;

- (NSMutableDictionary *)infoStartApp;
- (NSMutableDictionary *)infoStopApp;

@end


@implementation DMTracker

@synthesize queue;
@synthesize session;

+ (id) defaultTracker
{
    @synchronized(self)
    {
        if (defaultInstance == nil)
            [[self alloc] init];
    }
    return defaultInstance;
    
}

+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self) {
        if (defaultInstance == nil) {
            return [super allocWithZone:zone];
        }
    }
    return defaultInstance;
}

- (id)init
{
    Class myClass = [self class];
    @synchronized(myClass) {
        if (defaultInstance == nil) {
            self = [super init];
            if (self) {
                [self setQueue:[[[DMTrackingQueue alloc] init] autorelease]];
                [self setSession:[NSString uuid]];
                flow = 1;
                
                if ([queue count] > 0)
                {
                    if ([[[queue eventAtIndex:[queue count] - 1] objectForKey:DMFieldType] isNotEqualTo:DMTypeStopApp])
                        [queue add:[self infoStopApp]];
                    [queue flush];
                }

                [queue send:[self infoStartApp]];
                
                [[NSNotificationCenter defaultCenter] addObserver:self
                                                         selector:@selector(applicationWillTerminate:)
                                                             name:NSApplicationWillTerminateNotification
                                                           object:nil];

                defaultInstance = self;
            }
        }
    }
    return defaultInstance;
}

- (id) copyWithZone:(NSZone *)zone { return self; }
- (id) retain { return self; }
- (NSUInteger) retainCount { return UINT_MAX; }
- (void) release {}
- (id) autorelease { return self; }

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
    [self endSession];
}

- (void)endSession
{
    if (session && queue)
    {
        [queue add:[self infoStopApp]];
        [queue blockingFlush];
    }

    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self setSession:nil];
    [self setQueue:nil];
}

- (NSMutableDictionary *)infoWithType:(NSString *)type
{
    // TODO: Verify this - timezones?
    NSDate *timestamp = [NSDate date];

    return [NSMutableDictionary dictionaryWithObjectsAndKeys:
            [self session], DMFieldSession,
            type, DMFieldType,
            [NSNumber numberWithInt:(int)[timestamp timeIntervalSince1970]], DMFieldTimestamp,
            nil];
}

- (NSMutableDictionary *)infoForEventNamed:(NSString *)name
                                  withType:(NSString *)type
{
    NSMutableDictionary *info = [self infoWithType:type];
    [info setValue:[NSString stringWithFormat:@"%d", flow++]
            forKey:DMFieldFlow];
    [info setValue:name
            forKey:DMFieldName];
    return info;
}


- (NSMutableDictionary *)infoStartApp
{
    NSMutableDictionary *event = [self infoWithType:DMTypeStartApp];
    return event;
}

- (NSMutableDictionary *)infoStopApp
{
    return [self infoWithType:DMTypeStopApp];
}

- (NSMutableDictionary *)infoForEventWithCategory:(NSString *)theCategory
                                             name:(NSString *)theName
{
    NSMutableDictionary *event = [self infoForEventNamed:theName
                                                withType:DMTypeEvent];
    [event setValue:theCategory
             forKey:DMFieldCategory];
    return event;
}

- (NSMutableDictionary *)infoForEventWithCategory:(NSString *)theCategory
                                             name:(NSString *)theName
                                            value:(NSString *)theValue
{
    NSMutableDictionary *event = [self infoForEventWithCategory:theCategory
                                                           name:theName];
    [event setValue:DMTypeEventValue
             forKey:DMFieldType];
    [event setValue:theValue
             forKey:DMFieldValue];
    return event;
}

- (NSMutableDictionary *)infoForEventWithCategory:(NSString *)theCategory
                                             name:(NSString *)theName
                                     secondsSpent:(int)theSeconds
                                        completed:(BOOL)wasCompleted
{
    NSMutableDictionary *event = [self infoForEventWithCategory:theCategory
                                                           name:theName];
    [event setValue:DMTypeEventPeriod
             forKey:DMFieldType];
    [event setValue:[NSString stringWithFormat:@"%d", theSeconds]
             forKey:DMFieldEventTime];
    [event setValue:[NSString stringWithFormat:@"%d", wasCompleted]
             forKey:DMFieldEventConcluded];
    return event;
}

- (NSMutableDictionary *)infoForLogMessage:(NSString *)message
{
    NSMutableDictionary *event = [self infoWithType:DMTypeLog];
    [event setValue:message
             forKey:DMFieldMessage];
    return event;
}


- (NSMutableDictionary *)infoForCustomDataWithName:(NSString *)theName
                                             value:(NSString *)theValue
{
    NSMutableDictionary *event = [self infoWithType:DMTypeCustomData];
    [event setValue:theName
             forKey:DMFieldName];
    [event setValue:theValue
             forKey:DMFieldValue];
    return event;
}


- (NSMutableDictionary *)infoForCustomDataRealtimeWithName:(NSString *)theName
                                                     value:(NSString *)theValue
{
    NSMutableDictionary *event = [self infoForCustomDataWithName:theName
                                                           value:theValue];
    [event setValue:DMTypeCustomDataR
             forKey:DMFieldType];
    return event;
}


- (NSMutableDictionary *)infoForException:(NSException *)theException
{
    NSMutableDictionary *event = [self infoWithType:DMTypeException];
    [event setValue:@"" // event.message
             forKey:DMFieldExceptionMessage];
    [event setValue:[theException name]
             forKey:DMFieldExceptionSource];
    [event setValue:@"" // [theException callStackSymbols]
             forKey:DMFieldExceptionStack];
    [event setValue:@"" // Top of stack trace, location ("target site")
             forKey:DMFieldExceptionTargetSite];
    return event;
}

- (void)trackEventInCategory:(NSString *)theCategory
                    withName:(NSString *)theName
{
    [queue add:[self infoForEventWithCategory:theCategory name:theName]];
}


- (void)trackEventInCategory:(NSString *)theCategory
                    withName:(NSString *)theName
                       value:(NSString *)theValue
{
    [queue add:[self infoForEventWithCategory:theCategory
                                   name:theName
                                      value:theValue]];    
}

- (void)trackEventInCategory:(NSString *)theCategory
                    withName:(NSString *)theName
                secondsSpent:(int)theSeconds
                   completed:(BOOL)wasCompleted
{
    [queue add:[self infoForEventWithCategory:theCategory
                                   name:theName
                               secondsSpent:theSeconds
                                  completed:wasCompleted]];
}

- (void)trackLog:(NSString *)message
{
    [queue add:[self infoForLogMessage:message]];
}

- (void)trackCustomDataWithName:(NSString *)theName
                          value:(NSString *)theValue
{
    [queue add:[self infoForCustomDataWithName:theName value:theValue]];
}

- (void)trackCustomDataRealtimeWithName:(NSString *)theName
                                  value:(NSString *)theValue
{
    [queue send:[self infoForCustomDataRealtimeWithName:theName value:theValue]];
}

- (void)trackException:(NSException *)theException
{
    [queue send:[self infoForException:theException]];
}

@end
