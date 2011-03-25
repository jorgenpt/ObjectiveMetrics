//
//  DMTrackingQueue.h
//  ObjectiveMetrics
//
//  Created by Jørgen P. Tjernø on 3/22/11.
//  Copyright 2011 devSoft. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class DMRequester;

@interface DMTrackingQueue : NSObject {
@private
    NSMutableArray *events;
    int maxSize;
    double maxSecondsOld;
    NSInteger numberOfPendingEvents;
    DMRequester *requester;
}

- (void)add:(NSDictionary *)event;
- (void)send:(NSDictionary *)event;

- (NSUInteger)count;
- (NSDictionary *)eventAtIndex:(NSUInteger)index;

- (void)flush;
- (BOOL)blockingFlush;

@end
