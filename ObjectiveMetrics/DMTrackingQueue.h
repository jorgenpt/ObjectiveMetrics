//
//  DMTrackingQueue.h
//  ObjectiveMetrics
//
//  Created by Jørgen P. Tjernø on 3/22/11.
//  Copyright 2011 bitSpatter. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DMTracker.h"

@class DMRequester;
@class DMSession;

@interface DMTrackingQueue : NSObject<DMTrackingQueueProtocol> {
@private
    DMSession *currentSession;
    NSArray *sessions;
    DMRequester *requester;
    dispatch_queue_t requestQueue;
    NSString *userId;
}

- (id)initWithApplicationId:(NSString *)appId;

@end
