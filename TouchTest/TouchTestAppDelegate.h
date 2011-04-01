//
//  TouchTestAppDelegate.h
//  TouchTest
//
//  Created by Jorgen Tjerno on 4/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TouchTestViewController;

@interface TouchTestAppDelegate : NSObject <UIApplicationDelegate> {

}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet TouchTestViewController *viewController;

@end
