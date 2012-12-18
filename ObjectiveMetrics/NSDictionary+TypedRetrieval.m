//
//  NSDictionary+TypedRetrieval.m
//  ObjectiveMetrics
//
//  Created by Jorgen Tjerno on 12/28/12.
//  Copyright (c) 2012 bitSpatter. All rights reserved.
//

#import "NSDictionary+TypedRetrieval.h"

@implementation NSDictionary (TypedRetrieval)

- (id)objectForKey:(id)aKey
         withClass:(Class)aType
{
    id obj = [self objectForKey:aKey];

    if ([obj isMemberOfClass:aType])
        return obj;

    return nil;
}

- (NSString *)stringForKey:(NSString *)aKey
{
    return [self objectForKey:aKey
                    withClass:[NSString class]];
}

- (NSArray *)arrayForKey:(NSString *)aKey
{
    return [self objectForKey:aKey
                    withClass:[NSArray class]];
}

- (NSDictionary *)dictionaryForKey:(NSString *)aKey
{
    return [self objectForKey:aKey
                    withClass:[NSDictionary class]];
}

@end
