//
//  DMTrackingQueue.h
//  CocoaMetrics
//
//  Created by Jørgen P. Tjernø on 3/22/11.
//  Copyright 2011 devSoft. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface DMTrackingQueue : NSObject {
@private
    NSMutableArray *events;
    int maxSize;
    double maxSecondsOld;
    NSString *analyticsURL;
}

- (id)init;

- (void)add:(NSDictionary *)event;
- (void)send:(NSDictionary *)event;
- (void)sendBatch:(NSArray *)events;

- (BOOL)flushIfExceedsBounds;
- (BOOL)flush;

@end
