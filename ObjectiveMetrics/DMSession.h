//
//  DMSession.h
//  ObjectiveMetrics
//
//  Created by Jorgen Tjerno on 12/28/12.
//  Copyright (c) 2012 bitSpatter. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DMSession : NSObject {
@private
    NSString *sessionId;
    NSString *appVersion;
    NSString *jsonVersion;
    NSMutableArray *events;
}

- (id)init;
- (id)initWithDictionary:(NSDictionary *)aDictionary;

- (NSDictionary *)serializeAsDictionary;
- (NSDictionary *)serializeAsDictionaryWithUserId:(NSString *)userId;
- (NSMutableArray *)events;

@end
