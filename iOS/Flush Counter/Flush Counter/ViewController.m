//
//  ViewController.m
//  Flush Counter
//
//  Created by Tom Jay on 9/19/15.
//  Copyright © 2015 Tom Jay. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"
#import "BleManager.h"

@interface ViewController () <BleManagerDelegate> {
    
   int value;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [BleManager sharedBleManager].delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];

    


}

- (void)appWillBecomeActive {
    [self performSelector:@selector(checkFlushCountButtonPressed:) withObject:nil afterDelay:2.0];

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction) checkFlushCountButtonPressed:(id) sender {
    
    NSString *bleErrorState = [[BleManager sharedBleManager] checkBleErrorState];
    
    if (bleErrorState != nil) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"BLE issue Found" message:bleErrorState delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alert show];
        
        return;
    }
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    [appDelegate showHUD:@"Find BLE Device" details:@"Please wait..."];
    [[BleManager sharedBleManager] pair];

}



- (void)bleScanTimeout {
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    [appDelegate hidHUD];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Scan Timeout"
                                                    message:@"BLE Scan Timeout."
                                                   delegate:nil
                                          cancelButtonTitle:@"Ok"
                                          otherButtonTitles:nil];
    [alert show];
    
}

-(void) bleScanFailed:(NSError *)error {
    
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    [appDelegate hidHUD];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Scan Failed"
                                                    message:@"BLE Scan failed."
                                                   delegate:nil
                                          cancelButtonTitle:@"Ok"
                                          otherButtonTitles:nil];
    [alert show];
    
}

-(void) newPeripheralConnected:(NSString*) dummy peripheralType:(NSString*) peripheralType peripheralReference:(NSString*) peripheralReference {
    
    NSLog(@"newPeripheralConnected started");
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [appDelegate hidHUD];

    [self performSelectorOnMainThread:@selector(notifyDeviceFound) withObject:nil waitUntilDone:NO];
    
    
    
}





-(void) notifyDeviceFound {
    
    [self performSelector:@selector(sendStatusRequest) withObject:nil afterDelay:2.0];
    
    //    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Found"
    //                                                    message:@"BLE Connected."
    //                                                   delegate:nil
    //                                          cancelButtonTitle:@"Ok"
    //                                          otherButtonTitles:nil];
    //    [alert show];
    
    
}

-(void) sendStatusRequest {
    NSData* data = [[NSString stringWithFormat:@"<STATUS>0;"] dataUsingEncoding:NSUTF8StringEncoding];
   
    [[BleManager sharedBleManager] writePrimaryWithData:data];
    
}

-(void) newValue:(NSString*)chunk {
    
    NSString *newData = [chunk stringByReplacingOccurrencesOfString:@"<FLUSHES>"
                                                         withString:@""];
    
    newData = [newData stringByReplacingOccurrencesOfString:@";"
                                                         withString:@""];
    
    value = [newData intValue];
    
    [self performSelectorOnMainThread:@selector(updateUI) withObject:nil waitUntilDone:NO];

    
}

-(void) updateUI {
    float gallons = (float) value * 2.2;
    
    
    self.flushCountLabel.text = [NSString stringWithFormat:@"%d", value];
    self.gallonsLabel.text = [NSString stringWithFormat:@"%4.2f", gallons];

    
}




@end
