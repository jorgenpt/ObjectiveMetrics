//
//  iOSExampleAppDelegate.h
//  iOSExample
//
//  Created by Jorgen Tjerno on 4/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class iOSExampleViewController;

@interface iOSExampleAppDelegate : NSObject <UIApplicationDelegate> {

}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet iOSExampleViewController *viewController;

@end
