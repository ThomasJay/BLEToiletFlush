//
//  AppDelegate.h
//  Flush Counter
//
//  Created by Tom Jay on 9/19/15.
//  Copyright © 2015 Tom Jay. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

- (void) showHUD:(NSString*) title details:(NSString*) details;
- (void) hidHUD;


@end

