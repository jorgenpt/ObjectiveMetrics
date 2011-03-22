//
//  DMEventQueue.h
//  CocoaMetrics
//
//  Created by Jørgen P. Tjernø on 3/22/11.
//  Copyright 2011 devSoft. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface DMEventQueue : NSObject {
@private
    NSMutableArray *events;
}

- (void)add:(NSDictionary *)event;

@end
