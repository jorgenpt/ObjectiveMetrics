//
//  DMTrackingQueue.m
//  ObjectiveMetrics
//
//  Created by Jørgen P. Tjernø on 3/22/11.
//  Copyright 2011 bitSpatter. All rights reserved.
//

#import "DMTrackingQueue.h"

#import "DMRequester.h"
#import "DMSession.h"

#import "NSArray+Map.h"
#import "NSString+Random.h"

static char const * const kDMQueueName = "com.bitSpatter.objectivemetrics.requests";

static NSString * const kDMSessionsKey = @"DMSessions";
static NSString * const kDMUserIdKey = @"DM2UserId";
static int const kDMUserIdLength = 32;

@interface DMTrackingQueue ()

@property (retain) DMSession *currentSession;
@property (retain) NSArray *sessions;
@property (retain) DMRequester *requester;
@property (assign) dispatch_queue_t requestQueue;
@property (retain) NSString *userId;

- (void)flushSynchronouslyAndIncludeCurrent:(BOOL)includeCurrent;
- (void)save;
- (void)load;

@end

@implementation DMTrackingQueue

- (id)initWithApplicationId:(NSString *)appId
{
    self = [super init];
    if (self) {
        self.requestQueue = dispatch_queue_create(kDMQueueName, DISPATCH_QUEUE_SERIAL);
        self.requester = [[[DMRequester alloc] initWithApplicationId:appId] autorelease];
        self.currentSession = [[[DMSession alloc] init] autorelease];

        // We immediately try to flush any stuff that wasn't successfully sent.
        [self load];
        [self flushAndIncludeCurrent:NO];
    }

    return self;
}

- (void)dealloc
{
    dispatch_release(self.requestQueue);
    self.currentSession = nil;
    self.sessions = nil;
    self.requester = nil;
    self.userId = nil;

    [super dealloc];
}

- (void)add:(NSDictionary *)event
{
    @synchronized (self)
    {
        [[self.currentSession events] addObject:event];
        [self save];
    }
}

- (void)flushAndIncludeCurrent:(BOOL)includeCurrent
{
    dispatch_async(self.requestQueue, ^{
        [self flushSynchronouslyAndIncludeCurrent:includeCurrent];
    });
}

- (void)blockingFlush
{
    dispatch_sync(self.requestQueue, ^{
        [self flushSynchronouslyAndIncludeCurrent:YES];
    });
}

- (void)discard
{
    @synchronized (self)
    {
        self.sessions = nil;
    }
}

- (void)flushSynchronouslyAndIncludeCurrent:(BOOL)includeCurrent
{
    NSMutableArray *sessionsToSend = nil;
    NSUInteger currentSessionEvents = 0;

    @synchronized(self)
    {
        sessionsToSend = [[self.sessions arrayByApplyingTransformation:^id(id object) {
            return [object serializeAsDictionaryWithUserId:self.userId];
        }] mutableCopy];

        currentSessionEvents = [self.currentSession.events count];
        if (includeCurrent && currentSessionEvents > 0) {
            [sessionsToSend addObject:[self.currentSession serializeAsDictionaryWithUserId:self.userId]];
        }
    }

    if ([sessionsToSend count] == 0) {
        return;
    }

    BOOL messagesDelivered = [self.requester send:sessionsToSend];
    [sessionsToSend release];

    if (messagesDelivered) {
        DLog(@"Messages delivered. Removing %lu events from current sessions.", (unsigned long)currentSessionEvents);
        @synchronized(self)
        {
            if (self.currentSession && currentSessionEvents > 0) {
                NSRange range = NSMakeRange(0, currentSessionEvents);
                [self.currentSession.events removeObjectsInRange:range];
            }

            self.sessions = [NSArray array];
            [self save];
        }
    } else {
        DLog(@"Messages not delivered. Leaving data intact.");
    }
}

- (void)save
{
    NSMutableArray *savedSessions = [NSMutableArray array];
    if (self.sessions) {
        for (DMSession *session in self.sessions) {
            [savedSessions addObject:[session serializeAsDictionary]];
        }
    }

    if ([self.currentSession.events count] > 0) {
        [savedSessions addObject:[self.currentSession serializeAsDictionary]];
    }

    [[NSUserDefaults standardUserDefaults] setObject:savedSessions
                                              forKey:kDMSessionsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)load
{
    DMSUHost *app = [DMHosts sharedAppHost];

    NSString *uid = [app objectForUserDefaultsKey:kDMUserIdKey];
    if (!uid)
    {
        uid = [NSString randomStringOfLength:kDMUserIdLength];
        [app setObject:uid forUserDefaultsKey:kDMUserIdKey];
    }

    self.userId = uid;
    NSArray *serializedSessions = [[NSUserDefaults standardUserDefaults] arrayForKey:kDMSessionsKey];
    NSMutableArray *loadedSessions = [NSMutableArray array];

    for (NSDictionary *session in serializedSessions) {
        [loadedSessions addObject:[[[DMSession alloc] initWithDictionary:session] autorelease]];
    }

    self.sessions = loadedSessions;
}

@end
