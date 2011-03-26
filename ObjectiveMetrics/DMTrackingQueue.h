//
//  DMTrackingQueue.h
//  ObjectiveMetrics
//
//  Created by Jørgen P. Tjernø on 3/22/11.
//  Copyright 2011 devSoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DMRequester;

@interface DMTrackingQueue : NSObject {
@private
    NSMutableArray *events;
    int maxSize;
    double maxSecondsOld;
    NSRange pendingEvents;
    DMRequester *requester;
}

- (NSUInteger)count;
- (NSDictionary *)eventAtIndex:(NSUInteger)index;

- (void)add:(NSDictionary *)event;
- (void)send:(NSDictionary *)event;

- (void)flush;
- (BOOL)blockingFlush;

@end
