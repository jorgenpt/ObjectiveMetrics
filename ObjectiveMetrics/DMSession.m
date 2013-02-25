//
//  DMSession.m
//  ObjectiveMetrics
//
//  Created by Jorgen Tjerno on 12/28/12.
//  Copyright (c) 2012 bitSpatter. All rights reserved.
//

#import "DMSession.h"
#import "DMHosts.h"
#import "DMEvent.h"

#import "NSDictionary+TypedRetrieval.h"
#import "NSString+Random.h"

static const int kDMSessionIdLength = 24;
static NSString * const kDMJSONVersion = @"2.0";


#pragma mark Serialization keys
static NSString * const kDMHeaderField = @"h";
static NSString * const kDMBodyField = @"d";

static NSString * const kDMHeaderFieldSession = @"ss";
static NSString * const kDMHeaderFieldUserId = @"uid";
static NSString * const kDMHeaderFieldApplicationVersion = @"app";
static NSString * const kDMHeaderFieldJSONVersion = @"jsn";

#pragma mark Private API
@interface DMSession ()
@property (retain) NSString *sessionId;
@property (retain) NSString *appVersion;
@property (retain) NSString *jsonVersion;
@property (retain) NSMutableArray *events;

- (NSDictionary *)serializeHeaderAsDictionaryWithUserId:(NSString *)userId;
- (NSDictionary *)serializeAsDictionaryWithUserId:(NSString *)userId;
- (void)ensureSessionIsTerminated:(NSDictionary *)header;

@end

#pragma mark Implementation
@implementation DMSession

@synthesize sessionId;
@synthesize appVersion, jsonVersion;
@synthesize events;

- (id)init
{
    self = [super init];
    if (self) {
        self.sessionId = [NSString randomStringOfLength:kDMSessionIdLength];
        self.events = [NSMutableArray array];
        self.jsonVersion = kDMJSONVersion;

        DMSUHost *app = [DMHosts sharedAppHost];
        self.appVersion = [app version];
        if (!self.appVersion) {
            self.appVersion = @"0.0";
        }
    }

    return self;
}

- (id)initWithDictionary:(NSDictionary *)aDictionary
{
    self = [self init];
    if (self) {
        NSDictionary *headerDictionary = [aDictionary dictionaryForKey:kDMHeaderField];
        if ([headerDictionary count] > 0) {
            NSString *newSessionId = [headerDictionary stringForKey:kDMHeaderFieldSession];
            if ([newSessionId length] == kDMSessionIdLength)
                self.sessionId = newSessionId;

            NSString *newJsonVersion = [headerDictionary stringForKey:kDMHeaderFieldJSONVersion];
            if ([newJsonVersion length] > 0)
                self.jsonVersion = newJsonVersion;

            NSString *newAppVersion = [headerDictionary stringForKey:kDMHeaderFieldApplicationVersion];
            if ([newAppVersion length] > 0)
                self.appVersion = newAppVersion;
        }

        NSArray *bodyArray = [aDictionary arrayForKey:kDMBodyField];
        if ([bodyArray count] > 0) {
            self.events = [[bodyArray mutableCopy] autorelease];
        }
        [self ensureSessionIsTerminated:headerDictionary];
    }

    return self;
}

- (void)ensureSessionIsTerminated:(NSDictionary *)header
{
    NSDictionary *lastEvent = [self.events lastObject];
    NSString *lastEventType = [lastEvent objectForKey:kDMFieldType];
    if (![lastEventType isEqualToString:kDMTypeStop]) {
        // We try to estimate the terminating time by adding one second onto when the session was serialized.
        // If it's not available, we use the timestamp of the last event in the session, and finally, we fall back to
        // one second before the current time.
        NSNumber *terminatingEventTime = [header objectForKey:kDMFieldTimestamp];
        if (!terminatingEventTime) {
            terminatingEventTime = [lastEvent objectForKey:kDMFieldTimestamp];
        }

        if (terminatingEventTime) {
            terminatingEventTime = [NSNumber numberWithInt:[terminatingEventTime intValue] + 1];
        } else {
            terminatingEventTime = [NSNumber numberWithInt:[[DMEvent timestamp] intValue] - 1];
        }

        NSMutableDictionary *terminatingEvent = [DMEvent stopEvent];
        [terminatingEvent setObject:terminatingEventTime
                             forKey:kDMFieldTimestamp];
        [self.events addObject:terminatingEvent];
    }
}

- (NSDictionary *)serializeHeaderAsDictionaryWithUserId:(NSString *)userId
{
    NSMutableDictionary *header = [NSMutableDictionary dictionary];
    [header setObject:self.sessionId
               forKey:kDMHeaderFieldSession];

    if (userId) {
        [header setObject:userId
                   forKey:kDMHeaderFieldUserId];
    }

    [header setObject:[DMEvent timestamp]
               forKey:kDMFieldTimestamp];

    [header setObject:self.appVersion
               forKey:kDMHeaderFieldApplicationVersion];
    [header setObject:self.jsonVersion
               forKey:kDMHeaderFieldJSONVersion];
    return header;
}

- (NSDictionary *)serializeAsDictionaryWithUserId:(NSString *)userId
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    [dictionary setObject:[self serializeHeaderAsDictionaryWithUserId:userId]
                   forKey:kDMHeaderField];
    [dictionary setObject:self.events
                   forKey:kDMBodyField];
    return dictionary;
}

- (NSDictionary *)serializeAsDictionary
{
    return [self serializeAsDictionaryWithUserId:nil];
}

@end
