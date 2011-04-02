//
//  DesktopExampleAppDelegate.h
//  DesktopExample
//
//  Created by Jørgen P. Tjernø on 3/23/11.
//  Copyright 2011 devSoft. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface DesktopExampleAppDelegate : NSObject <NSApplicationDelegate> {
@private
    NSWindow *window;
}

@property (assign) IBOutlet NSWindow *window;

@end
