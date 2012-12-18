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

@end

#pragma mark Implementation
@implementation DMSession

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
            NSString *sessionId = [headerDictionary stringForKey:kDMHeaderFieldSession];
            if ([sessionId length] == kDMSessionIdLength)
                self.sessionId = sessionId;

            NSString *jsonVersion = [headerDictionary stringForKey:kDMHeaderFieldJSONVersion];
            if ([jsonVersion length] > 0)
                self.jsonVersion = jsonVersion;

            NSString *appVersion = [headerDictionary stringForKey:kDMHeaderFieldApplicationVersion];
            if ([appVersion length] > 0)
                self.appVersion = appVersion;
        }

        NSDictionary *bodyDictionary = [aDictionary dictionaryForKey:kDMBodyField];
        if ([bodyDictionary count] > 0) {
            self.events = [[bodyDictionary mutableCopy] autorelease];
        }
    }

    return self;
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
