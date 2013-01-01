//
//  DMEvent.m
//  ObjectiveMetrics
//
//  Created by Jorgen Tjerno on 12/28/12.
//  Copyright (c) 2012 bitSpatter. All rights reserved.
//

#import "DMEvent.h"

#if TARGET_OS_IPHONE
# import <UIKit/UIKit.h>
#else
# import <Cocoa/Cocoa.h>
#endif

static const int kBytesPerMegabyte = 1024 * 1024;

#pragma mark General message fields
NSString * const kDMFieldType = @"tp";
NSString * const kDMFieldFlow = @"fl";
NSString * const kDMFieldTimestamp = @"ts";


#pragma mark Start message fields
NSString * const kDMTypeStart = @"sta";
static NSString * const DMFieldStartUserCustomId = @"cid";
static NSString * const DMFieldStartUserEmail = @"uem";
static NSString * const DMFieldStartOSName = @"os";
static NSString * const DMFieldStartOSServicePack = @"sp";
static NSString * const DMFieldStartOSArchitecture = @"ar";
static NSString * const DMFieldStartOSLanguage = @"ln";
static NSString * const DMFieldStartOSFontDPI = @"fd";
static NSString * const DMFieldStartScreenCount = @"mc";
static NSString * const DMFieldStartScreenResolution = @"mr";
static NSString * const DMFieldStartProcessorInfo = @"pr";
static NSString * const DMFieldStartProcessorArchitecture = @"pa";
static NSString * const DMFieldStartMemoryTotal = @"mz";
static NSString * const DMFieldStartJavaVersion = @"jav";
static NSString * const DMFieldStartDotNetVersion = @"net";

#pragma mark Event message fields
NSString * const kDMTypeEvent = @"evt";
static NSString * const DMFieldEventName = @"na";
static NSString * const DMFieldEventProperties = @"pr";

#pragma mark Log message fields
NSString * const kDMTypeLog = @"log";
static NSString * const DMFieldLogMessage = @"na";

#pragma mark Stop message fields
NSString * const kDMTypeStop = @"sto";


@implementation DMEvent

#pragma mark - Message generation utility functions.

+ (NSNumber *)timestamp
{
    // TODO: Verify that this gives us time in GMT+0.
    return [NSNumber numberWithInt:(int)[[NSDate date] timeIntervalSince1970]];
}

+ (NSMutableDictionary *)baseMessageWithType:(NSString *)type
{
    return [NSMutableDictionary dictionaryWithDictionary:@{kDMFieldType : type, kDMFieldTimestamp : [[self class] timestamp]}];
}

#pragma mark - Message generation

+ (NSMutableDictionary *)startEvent
{
    NSMutableDictionary *event = [self baseMessageWithType:kDMTypeStart];

    DMSUHost *app = [DMHosts sharedAppHost];
    NSArray *systemProfileArray = [app systemProfile];
    NSMutableDictionary *systemProfile = [NSMutableDictionary dictionary];
    for (NSDictionary *dict in systemProfileArray)
    {
        [systemProfile setValue:[dict objectForKey:@"value"]
                         forKey:[dict objectForKey:@"key"]];
    }
    DLog(@"System profile: %@", systemProfile);

    NSArray *osVersion = [[systemProfile objectForKey:@"osVersion"] componentsSeparatedByString:@"."];
    if ([osVersion count] > 1)
    {
        [event setValue:[NSString stringWithFormat:@"%@ %@.%@",
                         (TARGET_OS_IPHONE ? @"iOS" : @"Mac OS X"),
                         [osVersion objectAtIndex:0],
                         [osVersion objectAtIndex:1]]
                 forKey:DMFieldStartOSName];
    }

    [event setValue:nil forKey:DMFieldStartOSServicePack];
    if ([osVersion count] > 2)
    {
        [event setValue:[osVersion objectAtIndex:2]
                 forKey:DMFieldStartOSServicePack];
    }

    [event setValue:[systemProfile objectForKey:@"lang"]
             forKey:DMFieldStartOSLanguage];

    // TODO: This is the CPU arch and not the OS arch.
    [event setValue:[NSNumber numberWithInteger:([[systemProfile objectForKey:@"cpu64bit"] boolValue] ? 64 : 32)]
             forKey:DMFieldStartOSArchitecture];
    [event setValue:[systemProfile objectForKey:@"cpuBrand"]
             forKey:DMFieldStartProcessorInfo];
    [event setValue:[NSNumber numberWithInteger:([[systemProfile objectForKey:@"cpu64bit"] boolValue] ? 64 : 32)]
             forKey:DMFieldStartProcessorArchitecture];
    [event setValue:[NSNumber numberWithInteger:[[systemProfile objectForKey:@"ramMB"] integerValue] * kBytesPerMegabyte]
             forKey:DMFieldStartMemoryTotal];

#if TARGET_OS_IPHONE
    [event setValue:[NSNumber numberWithInteger:[[UIScreen screens] count]]
             forKey:DMFieldStartScreenCount];
#else
    [event setValue:[NSNumber numberWithInteger:[[NSScreen screens] count]]
             forKey:DMFieldStartScreenCount];
#endif

    [event setValue:[systemProfile objectForKey:@"mainScreenResolution"]
             forKey:DMFieldStartScreenResolution];

    // TODO: Retrieve Java version somehow?
    // Missing values:
    //  - DMFieldStartJavaVersion
    //  - DMFieldStartDotNetVersion
    //  - DMFieldStartUserCustomId
    //  - DMFieldStartUserEmail
    //  - DMFieldStartOSFontDPI

    return event;
}

+ (NSMutableDictionary *)stopEvent
{
    return [self baseMessageWithType:kDMTypeStop];
}

+ (NSMutableDictionary *)event:(NSString *)eventName
                withProperties:(NSDictionary *)properties
{
    NSMutableDictionary *event = [self baseMessageWithType:kDMTypeEvent];
    [event setValue:eventName
             forKey:DMFieldEventName];

    if ([properties count] > 0) {
        [event setValue:properties
                 forKey:DMFieldEventProperties];
    }

    return event;
}

+ (NSMutableDictionary *)logEventWithMessage:(NSString *)theMessage
{
    NSMutableDictionary *event = [self baseMessageWithType:kDMTypeLog];
    [event setValue:theMessage
             forKey:DMFieldLogMessage];
    return event;
}

@end
