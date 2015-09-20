//
//  PeripheralManager.m
//  Flush Counter
//
//  Created by Tom Jay on 9/19/15.
//  Copyright © 2015 Tom Jay. All rights reserved.
//

#import "PeripheralManager.h"
#import "BleManager.h"

#define DEVICE_SERVICE        @"DFB0"
#define IO_CHARACTERISTIC @"DFB1"

@interface PeripheralManager () <CBPeripheralDelegate> {
    
}

@property (strong, nonatomic) NSTimer *activityTimer;

@property (nonatomic, strong) CBCharacteristic *characteristic;

@end



@implementation PeripheralManager


-(void) startFromConnected {
    
    
    // Self delegate
    self.peripheral.delegate = self;
    
    // look at the services provided by this peripheral
    [self.peripheral discoverServices:nil];
    
    
}

-(void) setDisconnectedState {
    
    if (self.peripheral && self.characteristic) {
        [self.peripheral setNotifyValue:NO forCharacteristic:self.characteristic];
    }
    
    
    [self.peripheral setDelegate:nil];
    self.peripheral = nil;
    
}


// This method returns the result of a @link discoverServices:
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    
    NSLog(@"peripheral:%@ didDiscoverServices:%@", peripheral, [error localizedDescription]);
    
    for (CBService *service in peripheral.services) {
        
        NSLog(@"Service found with UUID: %@", service.UUID);
        
        if ([service.UUID isEqual:[CBUUID UUIDWithString:DEVICE_SERVICE]]) {
            NSLog(@"DEVICE SERVICE Found");
        }
        
        [peripheral discoverCharacteristics:nil forService:service];
    }
}

// This method returns the result of a @link discoverCharacteristics:forService:
- (void)peripheral:(CBPeripheral *)peripheral
didDiscoverCharacteristicsForService:(CBService *)service
             error:(NSError *)error {
    
    NSLog(@"peripheral:%@ didDiscoverCharacteristicsForService:%@ error:%@",
          peripheral, service, [error localizedDescription]);
    
    if (error) {
        NSLog(@"Discovered characteristics for %@ with error: %@",
              service.UUID, [error localizedDescription]);
        return;
    }
    
    if([service.UUID isEqual:[CBUUID UUIDWithString:DEVICE_SERVICE]]) {
        
        for (CBCharacteristic *characteristic in service.characteristics) {
            
            NSLog(@"discovered characteristic %@", characteristic.UUID);
            
            if([characteristic.UUID isEqual:[CBUUID UUIDWithString:IO_CHARACTERISTIC]]) {
                NSLog(@"Found IO_CHARACTERISTIC Notify Characteristic %@", characteristic);
                self.characteristic = characteristic;
                [self.peripheral setNotifyValue:YES forCharacteristic:characteristic];
            }
            
        }
        
        
    }
    
    
    
    
}


// This method is invoked after a @link readValueForCharacteristic: @/link call, or upon receipt of a notification/indication
- (void)peripheral:(CBPeripheral *)peripheral
didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic
             error:(NSError *)error {
    
    NSLog(@"peripheral:%@ didUpdateValueForCharacteristic:%@ error:%@",
          peripheral, characteristic, error);
    
    if (error) {
        NSLog(@"Error updating value for characteristic %@ error: %@",
              characteristic.UUID, [error localizedDescription]);
        return;
    }
    
    
    
    if([characteristic.UUID isEqual:[CBUUID UUIDWithString:IO_CHARACTERISTIC]]) {
        
        NSString *chunk = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
        NSLog(@"chunk = %@", chunk);
        
        [[BleManager sharedBleManager] newValue:chunk peripheralManager:self];
        
    }
    
}

-(void) writeData:(NSData *)data {
    [_peripheral writeValue:data forCharacteristic:_characteristic type:CBCharacteristicWriteWithResponse];
}




@end
