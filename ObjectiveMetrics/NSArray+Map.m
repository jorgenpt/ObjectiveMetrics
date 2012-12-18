//
//  NSArray+Map.m
//  ObjectiveMetrics
//
//  Created by Jorgen Tjerno on 12/28/12.
//  Copyright (c) 2012 bitSpatter. All rights reserved.
//

#import "NSArray+Map.h"

@implementation NSArray (Map)

- (NSArray *)arrayByApplyingTransformation:(id (^)(id object))aTransform
{
    NSUInteger count = [self count];
    id *derivedObjects = (id *)calloc(count, sizeof(id));

    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        derivedObjects[idx] = [aTransform(obj) retain];
    }];

    NSArray *derivedArray = [NSArray arrayWithObjects:derivedObjects
                                          count:count];

    for (int i = 0; i < count; i++)
        [derivedObjects[i] release];
    free(derivedObjects);

    return derivedArray;
}

@end
