//
//  AppDelegate.m
//  Flush Counter
//
//  Created by Tom Jay on 9/19/15.
//  Copyright © 2015 Tom Jay. All rights reserved.
//

#import "AppDelegate.h"
#import "MBProgressHUD.h"
#import "BleManager.h"
@interface AppDelegate () <MBProgressHUDDelegate> {
    MBProgressHUD *hud;
    BOOL hudDone;
    
}

@end

@implementation AppDelegate

- (void) showHUD:(NSString*) title details:(NSString*) details {
    
    NSMutableDictionary *values = [NSMutableDictionary dictionary];
    values[@"title"] = title;
    values[@"details"] = details;
    
    [self performSelectorOnMainThread:@selector(showHUDOnMain:) withObject:values waitUntilDone:YES];
}



- (void) showHUDOnMain:(NSDictionary *) values {
    
    hudDone = false;
    
    hud = [[MBProgressHUD alloc] initWithView:self.window];
    [self.window addSubview:hud];
    
    hud.dimBackground = YES;
    hud.labelText = values[@"title"];
    hud.detailsLabelText = values[@"details"];
    hud.square = YES;
    
    // Regiser for HUD callbacks so we can remove it from the window at the right time
    hud.delegate = self;
    
    // Show the HUD while the provided method executes in a new thread
    [hud showWhileExecuting:@selector(waitingForHUD) onTarget:self withObject:nil animated:YES];
}

- (void) waitingForHUD {
    
    while (!hudDone) {
        sleep(1);
    }
    
}

- (void) hidHUD {
    hudDone = true;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    [[BleManager sharedBleManager] disconnectPrimary];

}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
