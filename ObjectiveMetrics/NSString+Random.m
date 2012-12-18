//
//  NSString+Random.m
//  ObjectiveMetrics
//
//  Created by Jørgen P. Tjernø on 12/17/12.
//  Copyright 2012 bitSpatter. All rights reserved.
//

#import "NSString+Random.h"

static NSString * const kValidCharacters = @"0123456789ABCDEF";


@implementation NSString (DMUUIDString)

+ (NSString *)randomStringOfLength:(int)length
{
    NSMutableString* output = [NSMutableString stringWithCapacity:length];
    
    for (int i = 0; i < length; ++i)
    {
        int character = drand48() * [kValidCharacters length];
        [output appendString:[kValidCharacters substringWithRange:NSMakeRange(character, 1)]];
    }
    
    return output;
}

@end
