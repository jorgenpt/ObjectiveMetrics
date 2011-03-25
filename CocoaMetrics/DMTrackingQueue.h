//
//  DMTrackingQueue.h
//  CocoaMetrics
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
    NSUInteger numberOfPendingEvents;
    DMRequester *requester;
}

- (void)add:(NSDictionary *)event;
- (void)send:(NSDictionary *)event;
- (void)sendBatch:(NSArray *)events;

- (NSUInteger)count;
- (NSDictionary *)eventAtIndex:(NSUInteger)index;

- (BOOL)flushIfExceedsBounds;
- (void)flush;
- (BOOL)blockingFlush;

@end
