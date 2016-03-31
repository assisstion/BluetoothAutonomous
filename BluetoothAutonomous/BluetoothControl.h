//
//  BluetoothControl.h
//  BluetoothAutonomous
//
//  Created by Markus Feng on 3/29/16.
//  Copyright © 2016 Markus Feng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "BluetoothControlReceiver.h"

@interface BluetoothControl : NSObject <CBCentralManagerDelegate, CBPeripheralDelegate>

@property (strong, nonatomic) CBCentralManager *centralManager;
@property (strong, nonatomic) CBPeripheral *discoveredPeripheral;
@property (strong, nonatomic) CBCharacteristic * writeCharacteristic;
@property NSObject<BluetoothControlReceiver> * receiver;

-(instancetype)initWithReceiver:(NSObject<BluetoothControlReceiver> *)receiver;
-(void)stop;
-(void)writeData:(NSData *) data;
-(NSString *)bluetoothStatus;
-(bool)bluetoothIsOn;

@end
