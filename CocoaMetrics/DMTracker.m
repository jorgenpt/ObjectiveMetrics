//
//  DMTracker.m
//  CocoaMetrics
//
//  Created by Jørgen P. Tjernø on 3/22/11.
//  Copyright 2011 devSoft. All rights reserved.
//

#import "DMTracker.h"

#import "NSString+DMUUID.h"

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


@interface DMTracker ()

@property (retain) DMTrackingQueue *queue;
@property (retain) NSString *session;

- (NSMutableDictionary *)infoStartApp;
- (NSMutableDictionary *)infoStopApp;

@end


@implementation DMTracker

@synthesize queue;
@synthesize session;

- (id)init
{
    self = [super init];
    if (self) {
        [self setQueue:[[[DMTrackingQueue alloc] init] autorelease]];
        [self setSession:[NSString uuid]];
        flow = 1;

        [queue send:[self infoStartApp]];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationWillTerminate:)
                                                     name:NSApplicationWillTerminateNotification
                                                   object:nil];
    }

    return self;
}

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
    [self endSession];
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self endSession];

    [self setQueue:nil];
    [self setSession:nil];

    [super dealloc];
}

- (void)endSession
{
    if (session && queue)
    {
        [queue add:[self infoStopApp]];
        [queue flush];
    }

    [self setSession:nil];
    [self setQueue:nil];
}

- (NSMutableDictionary *)infoWithType:(NSString *)type
{
    // TODO: Verify this - timezones?
    NSDate *timestamp = [NSDate date];

    return [NSMutableDictionary dictionaryWithObjectsAndKeys:
            [self session], @"ss",
            type, @"tp",
            [NSNumber numberWithInt:(int)[timestamp timeIntervalSince1970]], @"ts",
            nil];
}

- (NSMutableDictionary *)infoForEventNamed:(NSString *)name
                                  withType:(NSString *)type
{
    NSMutableDictionary *info = [self infoWithType:type];
    [info setValue:[NSString stringWithFormat:@"%d", flow++]
            forKey:@"fl"];
    [info setValue:name
            forKey:@"nm"];
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
             forKey:@"ca"];
    return event;
}

- (NSMutableDictionary *)infoForEventWithCategory:(NSString *)theCategory
                                             name:(NSString *)theName
                                            value:(NSString *)theValue
{
    NSMutableDictionary *event = [self infoForEventWithCategory:theCategory
                                                           name:theName];
    [event setValue:DMTypeEventValue
             forKey:@"tp"];
    [event setValue:theValue
             forKey:@"vl"];
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
             forKey:@"tp"];
    [event setValue:[NSString stringWithFormat:@"%d", theSeconds]
             forKey:@"tm"];
    [event setValue:[NSString stringWithFormat:@"%d", wasCompleted]
             forKey:@"ec"];
    return event;
}

- (NSMutableDictionary *)infoForLogMessage:(NSString *)message
{
    NSMutableDictionary *event = [self infoWithType:DMTypeLog];
    [event setValue:message
             forKey:@"ms"];
    return event;
}


- (NSMutableDictionary *)infoForCustomDataWithName:(NSString *)theName
                                             value:(NSString *)theValue
{
    NSMutableDictionary *event = [self infoWithType:DMTypeCustomData];
    [event setValue:theName
             forKey:@"nm"];
    [event setValue:theValue
             forKey:@"vl"];
    return event;
}


- (NSMutableDictionary *)infoForCustomDataRealtimeWithName:(NSString *)theName
                                                     value:(NSString *)theValue
{
    NSMutableDictionary *event = [self infoForCustomDataWithName:theName
                                                           value:theValue];
    [event setValue:DMTypeCustomDataR
             forKey:@"tp"];
    return event;
}


- (NSMutableDictionary *)infoForException:(NSException *)theException
{
    NSMutableDictionary *event = [self infoWithType:DMTypeException];
    [event setValue:@"" // event.message
             forKey:@"msg"];
    [event setValue:[theException name]
             forKey:@"src"];
    [event setValue:@"" // [theException callStackSymbols]
             forKey:@"stk"];
    [event setValue:@"" // Top of stack trace, location ("target site")
             forKey:@"tgs"];
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
