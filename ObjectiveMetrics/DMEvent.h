//
//  DMEvent.h
//  ObjectiveMetrics
//
//  Created by Jorgen Tjerno on 12/28/12.
//  Copyright (c) 2012 bitSpatter. All rights reserved.
//

#import <Foundation/Foundation.h>

NSString * const kDMFieldTimestamp;
NSString * const kDMFieldFlow;
NSString * const kDMFieldType;

NSString * const kDMTypeStop;

@interface DMEvent : NSObject

+ (NSNumber *)timestamp;

+ (NSMutableDictionary *)startEvent;
+ (NSMutableDictionary *)stopEvent;
+ (NSMutableDictionary *)event:(NSString *)eventName
                withProperties:(NSDictionary *)properties;
+ (NSMutableDictionary *)logEventWithMessage:(NSString *)theMessage;

@end
