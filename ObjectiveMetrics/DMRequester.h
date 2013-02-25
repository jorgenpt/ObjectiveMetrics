//
//  DMRequester.h
//  ObjectiveMetrics
//
//  Created by Jørgen P. Tjernø on 3/24/11.
//  Copyright 2011 bitSpatter. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface DMRequester : NSObject {
@private
    NSMutableURLRequest *request;
}

- (id)initWithApplicationId:(NSString *)appId;
- (BOOL)send:(NSArray *)data;

@end
