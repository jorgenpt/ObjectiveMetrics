//
//  DMRequester.h
//  ObjectiveMetrics
//
//  Created by Jørgen P. Tjernø on 3/24/11.
//  Copyright 2011 devSoft. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface DMRequester : NSObject {
@private
    NSMutableURLRequest *request;
    NSURLConnection *connection;
    id delegate;
    BOOL encounteredError;
    NSStringEncoding encoding;
}

@property (retain) id delegate;

- (id)initWithDelegate:(id)theDelegate;

- (void)send:(id)data;
- (void)wait;

@end

@protocol DMRequesterDelegate
@optional
- (void)requestFailed:(DMRequester *)requester;
- (void)requestSucceeded:(DMRequester *)requester;
@end
