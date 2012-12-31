//
//  DMTracker.m
//  ObjectiveMetrics
//
//  Created by Jørgen P. Tjernø on 3/22/11.
//  Copyright 2011 bitSpatter. All rights reserved.
//

#import "DMTracker.h"
#import "DMEvent.h"
#import "DMNullQueue.h"
#import "DMTrackingQueue.h"
#import "NSString+Random.h"

static DMTracker* defaultInstance = nil;

@interface DMTracker () {
    int flow;
}

@property (retain) id<DMTrackingQueueProtocol> queue;
@end


@implementation DMTracker

+ (DMTracker *)defaultTracker
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultInstance = [[self alloc] init];
    });

    return defaultInstance;
}

- (void)dealloc
{
    self.queue = nil;

    [super dealloc];
}

- (void)shouldFlush:(NSNotification *)aNotification
{
    [self flushQueue];
}

- (void)startWithApplicationId:(NSString *)appId
{
    if (!self.queue)
    {
        self.queue = [[[DMTrackingQueue alloc] initWithApplicationId:appId] autorelease];

        flow = 1;
        [self queueMessageWithFlow:[DMEvent startEvent]];

#if TARGET_OS_IPHONE
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(shouldFlush:)
                                                     name:UIApplicationDidReceiveMemoryWarningNotification
                                                   object:nil];
#endif
    }
    else
    {
        NSLog(@"Warning! -[DMTracker start] called more than once!");
    }
}

- (void)disable
{
    self.queue = [[[DMNullQueue alloc] init] autorelease];
}

- (void)stop
{
    [self stopAndFlushSynchronously:NO];
}

- (void)stopAndFlushSynchronously:(BOOL)synchronously
{
    if (self.queue)
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self];

        [self queueMessageWithFlow:[DMEvent stopEvent]];
        if (synchronously) {
            [self.queue blockingFlush];
        } else {
            [self.queue flushAndIncludeCurrent:YES];
        }

        self.queue = nil;
    }
    else
    {
        NSLog(@"Warning! -[DMTracker stop] called more than once or before start!");
    }
}

- (void)flushQueue
{
    [self.queue flushAndIncludeCurrent:YES];
}

- (void)discardQueue
{
    [self.queue discard];
}

- (void)queueMessageWithFlow:(NSMutableDictionary *)message
{
    int ourFlow;
    @synchronized(self) { ourFlow = flow++; }

    [message setValue:[NSString stringWithFormat:@"%d", ourFlow]
               forKey:kDMFieldFlow];

    [self.queue add:message];
}

#pragma mark - Event tracking

- (void)trackEvent:(NSString *)eventName
{
    [self trackEvent:eventName
      withProperties:nil];
}

- (void)trackEvent:(NSString *)eventName
    withProperties:(NSDictionary *)properties
{
    [self queueMessageWithFlow:[DMEvent event:eventName
                               withProperties:properties]];
}

- (void)trackLog:(NSString *)format, ...
{
    va_list arguments;
    va_start(arguments, format);
    NSString *message = [[NSString alloc] initWithFormat:format arguments:arguments];
    va_end(arguments);

    [self queueMessageWithFlow:[DMEvent logEventWithMessage:message]];
    [message release];
}

@end
