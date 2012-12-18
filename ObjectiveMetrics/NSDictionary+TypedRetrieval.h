//
//  NSDictionary+TypedRetrieval.h
//  ObjectiveMetrics
//
//  Created by Jorgen Tjerno on 12/28/12.
//  Copyright (c) 2012 bitSpatter. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (TypedRetrieval)

- (id)objectForKey:(id)aKey
         withClass:(Class)aType;

- (NSString *)stringForKey:(NSString *)aKey;
- (NSArray *)arrayForKey:(NSString *)aKey;
- (NSDictionary *)dictionaryForKey:(NSString *)aKey;

@end
