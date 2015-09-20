//
//  PeripheralManager.h
//  Flush Counter
//
//  Created by Tom Jay on 9/19/15.
//  Copyright © 2015 Tom Jay. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreBluetooth;

#import "BleManager.h"



@interface PeripheralManager : NSObject


@property (nonatomic, strong) CBPeripheral *peripheral;
@property (nonatomic, readwrite) int *peripheralState;

@property (nonatomic, strong) NSString *peripheralType;
@property (nonatomic, strong) NSString *peripheralReference;


-(void) startFromConnected;

-(void) setDisconnectedState;

-(void) writeData:(NSData *)data;


@end
