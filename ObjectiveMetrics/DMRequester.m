//
//  DMRequester.m
//  ObjectiveMetrics
//
//  Created by Jørgen P. Tjernø on 3/24/11.
//  Copyright 2011 bitSpatter. All rights reserved.
//

#import "DMRequester.h"

#if TARGET_OS_IPHONE
# import "SBJson.h"
#else
# import <SBJson/SBJson.h>
#endif

static NSString * const kDMAnalyticsURLFormat = @"https://%@.apiv2.deskmetrics.com/data";

@interface DMRequester ()
@property (retain) NSMutableURLRequest *request;

- (NSURL *)urlWithApplicationId:(NSString *)appId;
- (NSString *)userAgent;
@end


@implementation DMRequester

@synthesize request;

- (id)initWithApplicationId:(NSString *)appId
{
    self = [super init];
    if (self) {
        self.request = [NSMutableURLRequest requestWithURL:[self urlWithApplicationId:appId]];
        [self.request setHTTPMethod:@"POST"];
        [self.request setValue:@"application/json"
            forHTTPHeaderField:@"Accept"];
        [self.request setValue:@"application/x-www-form-urlencoded"
            forHTTPHeaderField:@"Content-Type"];
        [self.request setValue:[self userAgent]
            forHTTPHeaderField:@"User-Agent"];
    }

    return self;
}

- (void)dealloc
{
    [self setRequest:nil];

    [super dealloc];
}


- (NSURL *)urlWithApplicationId:(NSString *)appId
{
    NSString *urlString = [NSString stringWithFormat:kDMAnalyticsURLFormat, appId];
    DLog(@"URL: %@", urlString);
    return [NSURL URLWithString:urlString];
}

- (NSString *)userAgent
{
    DMSUHost *frameworkHost = [DMHosts sharedFrameworkHost];
    return [NSString stringWithFormat:@"DM SDK/%@ v%@ (%@)",
            (TARGET_OS_IPHONE ? @"iOS" : @"Mac OS X"),
            [frameworkHost version],
            [frameworkHost objectForInfoDictionaryKey:@"CFBundleName"]];
}

- (BOOL)send:(NSArray *)events
{
    NSData *json = [[events JSONRepresentation] dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableURLRequest *sentRequest = [self.request copy];

    [sentRequest setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[json length]] forHTTPHeaderField:@"Content-Length"];
    [sentRequest setHTTPBody:json];

    DLog(@"Sending data: %@", [events JSONRepresentation]);

    NSURLResponse *response = nil;
    NSError *error = nil;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:sentRequest
                                                 returningResponse:&response
                                                             error:&error];
    [sentRequest release];

    if (!responseData) {
        NSLog(@"Could not submit data to DeskMetrics: %@", error);
        return NO;
    }

    if (![response isKindOfClass:[NSHTTPURLResponse class]]) {
        NSLog(@"Got invalid response object: %@", response);
        return NO;
    }

    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    NSInteger statusCode = [httpResponse statusCode];
    if (statusCode < 200 || statusCode > 299) {
        NSLog(@"Got strange response code: %li", (long)statusCode);
        return NO;
    }

    NSStringEncoding encoding = NSUTF8StringEncoding;
    NSString *encodingName = [response textEncodingName];
    if (encodingName)
    {
        CFStringEncoding cfEncoding = CFStringConvertIANACharSetNameToEncoding((CFStringRef)encodingName);
        if (cfEncoding != kCFStringEncodingInvalidId)
        {
            encoding = CFStringConvertEncodingToNSStringEncoding(cfEncoding);
        }
    }

    NSString *responseBody = [[[NSString alloc] initWithData:responseData
                                                    encoding:encoding] autorelease];
    DLog(@"Completed with data: %@", responseBody);

    return YES;
}

@end
