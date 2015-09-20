//
//  BleManager.m
//  Flush Counter
//
//  Created by Tom Jay on 9/19/15.
//  Copyright © 2015 Tom Jay. All rights reserved.
//

#import "BleManager.h"
#import "PeripheralManager.h"

@import CoreBluetooth;

//#define DEVICE_SERVICE        @"0000dfb0-0000-1000-8000-00805f9b34fb"

#define IO_SERVICE        @"DFB0"


@interface BleManager () <CBCentralManagerDelegate> {
    
}


@property (nonatomic, strong) CBCentralManager *manager;

@property (nonatomic, strong) NSMutableArray *peripheralManagerList;

@property (strong, nonatomic) NSTimer *scanTimer;

@property (nonatomic, strong) CBPeripheral *scanPeripheral;



@end

@implementation BleManager

+(BleManager *) sharedBleManager {
    
    static dispatch_once_t once;
    
    static BleManager *instance;
    
    dispatch_once(&once, ^{
        instance = [[BleManager alloc] init];
    });
    
    return instance;
}

- (id)init {
    
    self = [super init];
    if (self) {
        
        self.manager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_queue_create("com.adc.BleManagerDispatchQueue", DISPATCH_QUEUE_SERIAL)];
        
        self.peripheralManagerList = [NSMutableArray array];
        
        
    }
    return self;
}

-(void) pair {
    
    NSLog(@"BleManager::pair");
    
    
    self.scanTimer = [NSTimer scheduledTimerWithTimeInterval:20.0 target:self selector:@selector(timeoutFromScanWhileLookingForNewDevice) userInfo:nil repeats:NO];
    
    [self startScan];
    
}


- (void) startScan {
    
    NSLog(@"starting startScan");
    NSArray *services = [NSArray arrayWithObject:[CBUUID UUIDWithString:IO_SERVICE]];
    
    [self.manager scanForPeripheralsWithServices:services options:nil];
}



-(void) timeoutFromScanWhileLookingForNewDevice {
    
    NSLog(@"BleManager::timeoutFromScanWhileLookingForNewDevice");
    
    [self.manager stopScan];
    
    // Tell our caller that we timed out and did not find a new patch
    
    if (self.delegate) {
        
        if ([self.delegate respondsToSelector:@selector(bleScanTimeout)]) {
            [self.delegate bleScanTimeout];
        }
        
    }
}



-(NSString *) checkBleErrorState {
    
    
    if (self.manager.state != CBCentralManagerStatePoweredOn) {
        
        if (self.manager.state == CBCentralManagerStateUnsupported) {
            return @"Sorry, we could not find Bluetooth on this device.";
        }
        
        if (self.manager.state == CBCentralManagerStateUnauthorized) {
            return @"You do not have permission to use the BlueTooth on this device. Maybe check in settings.";
        }
        
        if (self.manager.state == CBCentralManagerStatePoweredOff) {
            return @"Please turn the Bluetooth power on to use this application.";
        }
        
        
        return @"Unknown Bluetooth error has occured.";
    }
    else {
        // Nil means no error
        return nil;
    }
    
}

-(void) disconnectPrimary {
    
    
    PeripheralManager *peripheralManager = [_peripheralManagerList lastObject];
    
    CBPeripheral *peripheral = peripheralManager.peripheral;
    
    [peripheralManager setDisconnectedState];
    
    
    [self.manager cancelPeripheralConnection:peripheral];
    
    [_peripheralManagerList removeLastObject];
    
    
}

-(void) writePrimaryWithData:(NSData *)data {
    
    PeripheralManager *peripheralManager = [_peripheralManagerList lastObject];
    
    [peripheralManager writeData:data];
    
}


-(void) newValue:(NSString*)chunk peripheralManager:(PeripheralManager*) peripheralManager {
    
    if (self.delegate) {
        
        if ([self.delegate respondsToSelector:@selector(newValue:)]) {
            [self.delegate newValue:chunk];
        }
        
    }
    
}


#pragma CBCentralManagerDelegate

- (void) centralManagerDidUpdateState:(CBCentralManager *)central {
    
    NSLog(@"centralManagerDidUpdateState:%@", central);
    
    NSString * state = nil;
    switch ([self.manager state]) {
        case CBCentralManagerStateUnsupported:
            state = @"The platform/hardware doesn't support Bluetooth Low Energy.";
            break;
        case CBCentralManagerStateUnauthorized:
            state = @"The app is not authorized to use Bluetooth Low Energy.";
            break;
        case CBCentralManagerStatePoweredOff:
            state = @"Bluetooth is currently powered off.";
            break;
        case CBCentralManagerStatePoweredOn:
            state = @"Powered On";
            //            [self startScan];
            break;
        case CBCentralManagerStateUnknown:
        default:
            state = @"Unknown";
    }
    NSLog(@"centralManagerDidUpdateState: %@ to %@", central, state);
}


- (void) centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    
    NSLog(@"centralManager:didDiscoverPeripheral:%@ advertisementData:%@ RSSI %@",
          peripheral,
          [advertisementData description],
          RSSI);
    
    NSString *deviceName = [advertisementData objectForKey:@"kCBAdvDataLocalName"];
    
    NSLog(@"deviceName: %@", deviceName);
    
    
    // Check to see if we found this PIN encoded inthe peripheral name
    NSString *nameWithPin = advertisementData[@"kCBAdvDataLocalName"];
    
//    if ([nameWithPin rangeOfString:self.scanPin].location != NSNotFound) {
//        
//        NSLog(@"centralManager:didDiscoverPeripheral Found our PIN, go connect PIN=%@", self.scanPin);
//        
        self.scanPeripheral = peripheral;
        
        // OK, this is the peripheral with the PIN to connect to
        [self.manager connectPeripheral:peripheral options:nil];
        
//    }
    
    
    
}


// This method is invoked when a connection initiated by @link connectPeripheral:options: @/link has succeeded.
- (void) centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    
    NSLog(@"centralManager:didConnectPeripheral:%@", peripheral);
    
    
    [self.scanTimer invalidate];
    self.scanTimer = nil;
    
    // We found the peripheral we are looking for, no reason to look any further
    [self.manager stopScan];
    
    PeripheralManager *peripheralManager = [[PeripheralManager alloc] init];
    
    peripheralManager.peripheralType = @"BLE";
    peripheralManager.peripheralReference = peripheral.identifier.UUIDString;
    
    [self.peripheralManagerList addObject:peripheralManager];
    
    
    peripheralManager.peripheral = peripheral;
    
    if (self.delegate) {
        
        if ([self.delegate respondsToSelector:@selector(newPeripheralConnected:peripheralType:peripheralReference:)]) {
            [self.delegate newPeripheralConnected:@"" peripheralType:peripheralManager.peripheralType peripheralReference:peripheralManager.peripheralReference];
        }
        
    }
    
    
    [peripheralManager startFromConnected];
    
}


- (void) centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    
    NSLog(@"centralManager:didFailToConnectPeripheral:%@ error:%@", peripheral, [error localizedDescription]);
    
    if (self.delegate) {
        
        if ([self.delegate respondsToSelector:@selector(bleScanFailed:)]) {
            [self.delegate bleScanFailed:error];
        }
        
    }
    
    
}


//- (void) centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
//
//    NSLog(@"centralManager:didDisconnectPeripheral:%@ error:%@", peripheral, [error localizedDescription]);
//    if (self.peripheral) {
//        [self.peripheral setDelegate:nil];
//        self.peripheral = nil;
//    }
//}


@end
