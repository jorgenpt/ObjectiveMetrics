//
//  DMTracker.m
//  CocoaMetrics
//
//  Created by Jørgen P. Tjernø on 3/22/11.
//  Copyright 2011 devSoft. All rights reserved.
//

#import "DMTracker.h"

static NSString *DMTypeEvent = @"ev";
static NSString *DMTypeEventValue = @"evV";
static NSString *DMTypeEventTimedStart = @"evS";
static NSString *DMTypeEventTimedStop = @"evST";
static NSString *DMTypeEventCancel = @"evC";
static NSString *DMTypeEventPeriod = @"evP";
static NSString *DMTypeLog = @"lg";
static NSString *DMTypeCustomData = @"ctD";
static NSString *DMTypeCustomDataR = @"ctDR";
static NSString *DMTypeException = @"exC";


@interface DMTracker ()

@property (retain) DMEventQueue *queue;

- (NSDictionary *)event;

- (NSDictionary *)eventInCategory:(NSString *)theCategory
                         withName:(NSString *)theName;

- (NSDictionary *)eventInCategory:(NSString *)theCategory
                         withName:(NSString *)theName
                            value:(NSString *)theValue;

- (NSDictionary *)eventInCategory:(NSString *)theCategory
                         withName:(NSString *)theName
                     secondsSpent:(int)theSeconds
                        completed:(BOOL)wasCompleted;

- (NSDictionary *)log:(NSString *)message;

- (NSDictionary *)customDataWithName:(NSString *)theName
                               value:(NSString *)theValue;

- (NSDictionary *)customDataRealtimeWithName:(NSString *)theName
                                       value:(NSString *)theValue;

- (NSDictionary *)exception:(NSException *)theException;

@end


@implementation DMTracker

@synthesize appId;
@synthesize queue;

- (id)init
{
    self = [super init];
    if (self) {
        [self setAppId:nil];
        [self setQueue:[[[DMEventQueue alloc] init] autorelease]];
        flow = 1;
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

- (NSDictionary *)event
{
    // TODO: Verify this.
    NSDate *timestamp = [NSDate date];
    [timestamp setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    
    return [NSDictionary dictionaryWithObjectsAndKeys:
            [NSString stringWithFormat:@"%d", [self hash]], @"ss",
            [NSString stringWithFormat:@"%d", flow++], @"fl",
            timestamp, @"ts",
            nil];
}

- (NSDictionary *)eventInCategory:(NSString *)theCategory
                         withName:(NSString *)theName
{
    NSDictionary *event = [self event];
    [event setValue:DMTypeEvent
             forKey:@"tp"];
    [event setValue:theCategory
             forKey:@"ca"];
    [event setValue:theName
             forKey:@"nm"];
    return event;
}

- (void)trackEventInCategory:(NSString *)theCategory
                    withName:(NSString *)theName
{
    
}

- (NSDictionary *)eventInCategory:(NSString *)theCategory
                         withName:(NSString *)theName
                            value:(NSString *)theValue
{
    NSDictionary *event = [self eventInCategory:theCategory
                                       withName:theName];
    [event setValue:DMTypeEventValue
             forKey:@"tp"];
    [event setValue:theValue
             forKey:@"vl"];
    return event;
}

- (void)trackEventInCategory:(NSString *)theCategory
                    withName:(NSString *)theName
                       value:(NSString *)theValue
{
    
}

- (NSDictionary *)eventInCategory:(NSString *)theCategory
                         withName:(NSString *)theName
                     secondsSpent:(int)theSeconds
                        completed:(BOOL)wasCompleted
{
    NSDictionary *event = [self eventInCategory:theCategory
                                       withName:theName];
    [event setValue:DMTypeEventPeriod
             forKey:@"tp"];
    [event setValue:[NSString stringWithFormat:@"%d", theSeconds]
             forKey:@"tm"];
    [event setValue:[NSString stringWithFormat:@"%d", wasCompleted]
             forKey:@"ec"];
    
    return event;
}

- (void)trackEventInCategory:(NSString *)theCategory
                    withName:(NSString *)theName
                secondsSpent:(int)theSeconds
                   completed:(BOOL)wasCompleted
{
    
}

- (NSDictionary *)log:(NSString *)message
{
    NSDictionary *event = [self event];
    [event setValue:DMTypeLog
             forKey:@"tp"];
    [event setValue:message
             forKey:@"ms"];
    return event;
}

- (void)trackLog:(NSString *)message
{
    
}

- (NSDictionary *)customDataWithName:(NSString *)theName
                               value:(NSString *)theValue
{
    NSDictionary *event = [self event];
    [event setValue:DMTypeCustomData
             forKey:@"tp"];
    [event setValue:theName
             forKey:@"nm"];
    [event setValue:theValue
             forKey:@"vl"];
    return event;
}

- (void)trackCustomDataWithName:(NSString *)theName
                          value:(NSString *)theValue
{
    
}

- (NSDictionary *)customDataRealtimeWithName:(NSString *)theName
                                       value:(NSString *)theValue
{
    NSDictionary *event = [self customDataWithName:theName
                                             value:theValue];
    [event setValue:DMTypeCustomDataR
             forKey:@"tp"];
    return event;
}

- (void)trackCustomDataRealtimeWithName:(NSString *)theName
                                  value:(NSString *)theValue
{
    
}

- (NSDictionary *)exception:(NSException *)theException
{
    NSDictionary *event = [self event];
    [event setValue:DMTypeException
             forKey:@"tp"];
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

- (void)trackException:(NSException *)theException
{
    
}

@end
