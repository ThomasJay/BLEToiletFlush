//
//  BleManager.h
//  Flush Counter
//
//  Created by Tom Jay on 9/19/15.
//  Copyright © 2015 Tom Jay. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol BleManagerDelegate <NSObject>

@required

- (void)bleScanTimeout;

-(void) bleScanFailed:(NSError *)error;

-(void) newValue:(NSString *) value;

-(void) newPeripheralConnected:(NSString*) dummy peripheralType:(NSString*) peripheralType peripheralReference:(NSString*) peripheralReference;


@end

@class PeripheralManager;

@interface BleManager : NSObject

+(BleManager *) sharedBleManager;

@property (strong, nonatomic) id<BleManagerDelegate> delegate;

-(NSString *) checkBleErrorState;

-(void) pair;

-(void) disconnectPrimary;

-(void) writePrimaryWithData:(NSData *)data;

-(void) newValue:(NSString*)chunk peripheralManager:(PeripheralManager*) peripheralManager;

@end
