//
//  DMTracker.m
//  ObjectiveMetrics
//
//  Created by Jørgen P. Tjernø on 3/22/11.
//  Copyright 2011 devSoft. All rights reserved.
//

#import "DMTracker.h"

#import "DMTrackingQueue.h"
#import "NSString+DMUUID.h"

static NSString * const DMUserIdKey = @"DMUserId";

/* These are the basic fields all requests contain. */
static NSString * const DMFieldSession = @"ss";
static NSString * const DMFieldType = @"tp";
static NSString * const DMFieldTimestamp = @"ts";

/* These are various fields that the requests can contain. */
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

/* These are all the fields that DMTypeStartApp wants. */
static NSString * const DMFieldUserId = @"ID";
static NSString * const DMFieldInfoApplicationVersion = @"aver";
static NSString * const DMFieldInfoOSVersion = @"osv";
static NSString * const DMFieldInfoOSServicePack = @"ossp";
static NSString * const DMFieldInfoOSArchitecture = @"osar";
static NSString * const DMFieldInfoJavaVersion = @"osjv";
static NSString * const DMFieldInfoDotNetVersion = @"osnet";
static NSString * const DMFieldInfoDotNetServicePack = @"osnsp";
static NSString * const DMFieldInfoOSLanguage = @"oslng";
static NSString * const DMFieldInfoScreenResolution = @"osscn";
static NSString * const DMFieldInfoProcessorName = @"cnm";
static NSString * const DMFieldInfoProcessorBrand = @"cbr";
static NSString * const DMFieldInfoProcessorFrequency = @"cfr";
static NSString * const DMFieldInfoProcessorCores = @"ccr";
static NSString * const DMFieldInfoProcessorArchitecture = @"car";
static NSString * const DMFieldInfoMemoryTotal = @"mtt";
static NSString * const DMFieldInfoMemoryFree = @"mfr";
static NSString * const DMFieldInfoDiskTotal = @"dtt";
static NSString * const DMFieldInfoDiskFree = @"dfr";

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
                if ([queue count] > 0)
                {
                    /* If the queue isn't empty, that means we were unable to send some items last session.
                     * Check that the last session had the time to queue a stopApp, otherwise fabricate our own.
                     */
                    NSDictionary *lastEvent = [queue eventAtIndex:[queue count] - 1];
                    if ([[lastEvent objectForKey:DMFieldType] isNotEqualTo:DMTypeStopApp])
                    {
                        /* Create a new stopApp, but set the session to the previous session. */
                        NSMutableDictionary *stopApp = [self infoStopApp];
                        [stopApp setValue:[lastEvent objectForKey:DMFieldSession]
                                   forKey:DMFieldSession];
                        [queue add:lastEvent];
                    }
                    [queue flush];
                }

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
    [self stopApp];
}

- (void)startApp
{
    if (!session)
    {
        flow = 1;

        [self setSession:[NSString uuid]];
        [queue send:[self infoStartApp]];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationWillTerminate:)
                                                     name:NSApplicationWillTerminateNotification
                                                   object:nil];
    }
    else
    {
        NSLog(@"Warning! -[DMTracker startApp] called more than once!");
    }
}

- (void)stopApp
{
    if (session)
    {
        if (queue)
        {
            [queue add:[self infoStopApp]];
            [queue blockingFlush];
        }

        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [self setSession:nil];
    }
    else
    {
        NSLog(@"Warning! -[DMTracker stopApp] called more than once or before startApp!");
    }
}

- (NSMutableDictionary *)infoWithType:(NSString *)type
{
    // TODO: Verify that this gives us time in GMT+0.
    return [NSMutableDictionary dictionaryWithObjectsAndKeys:
            [self session], DMFieldSession,
            type, DMFieldType,
            [NSNumber numberWithInt:(int)[[NSDate date] timeIntervalSince1970]], DMFieldTimestamp,
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

    SUHost *host = [DMHosts sharedFrameworkHost], *app = [DMHosts sharedAppHost];
    
    NSString *uuid = [host objectForUserDefaultsKey:DMUserIdKey];
    if (!uuid)
    {
        uuid = [NSString uuid];
        [host setObject:uuid forUserDefaultsKey:DMUserIdKey];
    }    

    [event setValue:uuid
             forKey:DMFieldUserId];

    [event setValue:[app version]
             forKey:DMFieldInfoApplicationVersion];
    
    NSArray *systemProfileArray = [app systemProfile];
    NSMutableDictionary *systemProfile = [NSMutableDictionary dictionary];
    for (NSDictionary *dict in systemProfileArray)
    {
        [systemProfile setValue:[dict objectForKey:@"value"]
                         forKey:[dict objectForKey:@"key"]];
    }
    DLog(@"System profile: %@", systemProfile);
    
    NSArray *osVersion = [[systemProfile objectForKey:@"osVersion"] componentsSeparatedByString:@"."];
    if ([osVersion count] > 1)
        [event setValue:[NSString stringWithFormat:@"Mac OS X %@.%@",
                         [osVersion objectAtIndex:0],
                         [osVersion objectAtIndex:1]]
                 forKey:DMFieldInfoOSVersion];    
    else
        [event setValue:[NSString stringWithFormat:@"UNKNOWN",
                         [osVersion objectAtIndex:0],
                         [osVersion objectAtIndex:1]]
                 forKey:DMFieldInfoOSVersion];    

    if ([osVersion count] > 2)
        [event setValue:[osVersion objectAtIndex:2]
                 forKey:DMFieldInfoOSServicePack];
    else
        [event setValue:@""
                 forKey:DMFieldInfoOSServicePack];

    // TODO: this is wrong.
    [event setValue:[NSNumber numberWithInt:([[systemProfile objectForKey:@"cpu64bit"] boolValue] ? 64 : 32)]
             forKey:DMFieldInfoOSArchitecture];
    [event setValue:@"null"
             forKey:DMFieldInfoJavaVersion];
    [event setValue:@"null"
             forKey:DMFieldInfoDotNetVersion];
    // TODO: this is wrong.
    [event setValue:[NSNumber numberWithInt:0]
             forKey:DMFieldInfoDotNetServicePack];
    // TODO: this is wrong.
    [event setValue:[NSNumber numberWithInt:1046]
             forKey:DMFieldInfoOSLanguage];
    [event setValue:@"null"
             forKey:DMFieldInfoScreenResolution];
    [event setValue:[systemProfile objectForKey:@"model"]
             forKey:DMFieldInfoProcessorName];
    [event setValue:@"null"
             forKey:DMFieldInfoProcessorBrand];
    [event setValue:[systemProfile objectForKey:@"cpuFreqMHz"]
             forKey:DMFieldInfoProcessorFrequency];
    [event setValue:[systemProfile objectForKey:@"ncpu"]
             forKey:DMFieldInfoProcessorCores];
    [event setValue:[NSNumber numberWithInt:([[systemProfile objectForKey:@"cpu64bit"] boolValue] ? 64 : 32)]
             forKey:DMFieldInfoProcessorArchitecture];
    [event setValue:[NSNumber numberWithInteger:[[systemProfile objectForKey:@"ramMB"] integerValue] * 1024 * 1024]
             forKey:DMFieldInfoMemoryTotal];
    [event setValue:@"null"
             forKey:DMFieldInfoMemoryFree];
    [event setValue:@"null"
             forKey:DMFieldInfoDiskTotal];
    [event setValue:@"null"
             forKey:DMFieldInfoDiskFree];

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
