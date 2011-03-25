//
//  DMRequester.m
//  ObjectiveMetrics
//
//  Created by Jørgen P. Tjernø on 3/24/11.
//  Copyright 2011 devSoft. All rights reserved.
//

#import "DMRequester.h"

#import "JSON.h"

static NSString * const DMAnalyticsURLKey = @"DMAnalyticsURL";
static NSString * const DMAppIdKey = @"DMAppId";
static NSString * const DMAnalyticsURLFormat = @"http://%@.api.deskmetrics.com/sendData";

static NSString * const DMStatusCodeKey = @"status_code";

@interface DMRequester ()

@property (retain) NSURLConnection *connection;
@property (retain) NSMutableURLRequest *request;

@end


@implementation DMRequester

@synthesize delegate, request, connection;

- (id)init
{
    self = [super init];
    if (self) {
        SUHost *host = [DMHosts sharedAppHost];
        NSString *URL = [host objectForInfoDictionaryKey:DMAnalyticsURLKey];
        if (!URL)
        {
            NSString *appId = [host objectForInfoDictionaryKey:DMAppIdKey];
            if (!appId)
            {
                NSLog(@"Could not find neither %@ nor %@ in Info.plist!", DMAnalyticsURLKey, DMAppIdKey);
                [self release];
                return nil;
            }

            URL = [NSString stringWithFormat:DMAnalyticsURLFormat, appId];
        }

        DLog(@"URL: %@", URL);

        [self setRequest:[NSMutableURLRequest requestWithURL:[NSURL URLWithString:URL]]];
        [request setHTTPMethod:@"POST"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];

        [self setConnection:nil];
    }

    return self;
}

- (id)initWithDelegate:(id)theDelegate
{
    self = [self init];
    if (self)
    {
        [self setDelegate:theDelegate];
    }
    
    return self;
}

- (void)dealloc
{
    [self setRequest:nil];
    [self setConnection:nil];

    [super dealloc];
}

- (void)send:(id)data
{
    NSData *json = [[data JSONRepresentation] dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableURLRequest *sentRequest = [request copy];

    [sentRequest setValue:[NSString stringWithFormat:@"%d", [json length]] forHTTPHeaderField:@"Content-Length"];
    [sentRequest setHTTPBody:json];
    
    DLog(@"Sending data: %@", [data JSONRepresentation]);

    encounteredError = NO;
    [self setConnection:[NSURLConnection connectionWithRequest:[sentRequest autorelease] delegate:self]];
}

- (void)wait
{
    NSRunLoop *loop = [NSRunLoop currentRunLoop];
    while (connection && [loop runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]]);
}

#pragma mark -
#pragma mark NSURLConnection delegate

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse *)cachedResponse
{
    return nil;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    if ([response isKindOfClass:[NSHTTPURLResponse class]])
    {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;        
        if ([httpResponse statusCode] < 200 || [httpResponse statusCode] > 299)
        {
            NSLog(@"Request fail: %ld", [httpResponse statusCode]);
            encounteredError = YES;
        }
        
        DLog(@"Got DeskMetrics response, encoding: %@, status code: %ld",
             [httpResponse textEncodingName], [httpResponse statusCode]);
    }
    else
    {
        NSLog(@"Got DeskMetrics response, but not HTTP. Encoding: %@", [response textEncodingName]);
    }

    
    encoding = NSUTF8StringEncoding;
    CFStringEncoding cfEncoding = CFStringConvertIANACharSetNameToEncoding((CFStringRef)[response textEncodingName]);
    if (cfEncoding != kCFStringEncodingInvalidId) {
        encoding = CFStringConvertEncodingToNSStringEncoding(cfEncoding);
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if (!encounteredError)
    {
        NSString *responseBody = [[[NSString alloc] initWithData:data encoding:encoding] autorelease];
        id result = [responseBody JSONValue];
        DLog(@"Received data: %@", result);
        if ([result isKindOfClass:[NSDictionary class]])
        {
            id status = [result objectForKey:DMStatusCodeKey];
            NSInteger statuscode = [status integerValue];
            if (statuscode == 0 || statuscode == 1)
                encounteredError = NO;
            else
            {
                if (statuscode < 0)
                    NSLog(@"Got error code from DeskMetrics: %ld", statuscode);
                else
                    NSLog(@"Got unexpected positive code from DeskMetrics: %ld", statuscode);
                encounteredError = YES;
            }
        }
        else 
        {
            encounteredError = YES;
            NSLog(@"Got unknown JSON from DeskMetrics: %@ (%@)", responseBody, result);
        }
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    if ([delegate respondsToSelector:@selector(requestFailed:)])
        [delegate requestFailed:self];

    NSLog(@"DeskMetrics connection failed: %@", error);

    [self setConnection:nil];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    DLog(@"DeskMetrics connection finished: %@error", (encounteredError ? @"" : @"no "));

    if (encounteredError)
    {
        if ([delegate respondsToSelector:@selector(requestFailed:)])
            [delegate requestFailed:self];
    }
    else
    {
        if ([delegate respondsToSelector:@selector(requestSucceeded:)])
            [delegate requestSucceeded:self];
    }

    [self setConnection:nil];
}

@end
