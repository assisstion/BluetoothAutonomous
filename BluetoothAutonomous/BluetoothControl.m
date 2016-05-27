//
//  BluetoothControl.m
//  BluetoothAutonomous
//
//  Created by Markus Feng on 3/29/16.
//  Copyright © 2016 Markus Feng. All rights reserved.
//
// An device that 
//
// Bluetooth Code:
// http://www.raywenderlich.com/52080/introduction-core-bluetooth-building-heart-rate-monitor
// http://code.tutsplus.com/tutorials/ios-7-sdk-core-bluetooth-practical-lesson--mobile-20741
// http://embeddedsoftdev.blogspot.ca/p/ehal-nrf51.html
// https://github.com/I-SYST/iOS/blob/master/BlinkyBle/BlinkyBle/ViewController.m


#import "BluetoothControl.h"

//Service UUID for general BLE serivces
#define TRANSFER_SERVICE_UUID           @"713D0000-503E-4C75-BA94-3148F18D941E"
//Characteristic UUID for the read characteristic
#define TRANSFER_READ_UUID              @"713D0002-503E-4C75-BA94-3148F18D941E"
//Characteristic UUID for the write characteristic
#define TRANSFER_WRITE_UUID             @"713D0003-503E-4C75-BA94-3148F18D941E"

#define NOTIFY_MTU 20

typedef struct
{
    double x;
    double y;
} Coords;

@implementation BluetoothControl

-(instancetype)initWithReceiver:(NSObject<BluetoothControlReceiver> *)receiver{
    self = [super init];
    if(self){
        self.receiver = receiver;
        self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    }
    return self;
}

-(void)stop{
    [self.centralManager stopScan];
}

#pragma mark - CBCentralManagerDelegate

//Bluetooth handlers

// method called whenever you have successfully connected to the BLE peripheral
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"Connected");
    
    [_centralManager stopScan];
    NSLog(@"Scanning stopped");
    
    peripheral.delegate = self;
    
    [peripheral discoverServices:@[[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]]];
}

// CBCentralManagerDelegate - This is called with the CBPeripheral class as its main input parameter. This contains most of the information there is to know about a BLE peripheral.
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    NSLog(@"Discovered %@ at %@", peripheral.name, RSSI);
    
    if (self.discoveredPeripheral != peripheral) {
        // Save a local copy of the peripheral, so CoreBluetooth doesn't get rid of it
        self.discoveredPeripheral = peripheral;
        
        // And connect
        NSLog(@"Connecting to peripheral %@", peripheral);
        [_centralManager connectPeripheral:peripheral options:nil];
    }
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"Failed to connect");
    [self cleanup];
}

- (void)cleanup {
    
    // See if we are subscribed to a characteristic on the peripheral
    if (self.discoveredPeripheral.services != nil) {
        for (CBService *service in self.discoveredPeripheral.services) {
            if (service.characteristics != nil) {
                for (CBCharacteristic *characteristic in service.characteristics) {
                    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:TRANSFER_READ_UUID]]) {
                        if (characteristic.isNotifying) {
                            [self.discoveredPeripheral setNotifyValue:NO forCharacteristic:characteristic];
                            return;
                        }
                    }
                }
            }
        }
    }
    
    [self.centralManager cancelPeripheralConnection:self.discoveredPeripheral];
}

// method called whenever the device state changes.
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    // If power is not turned on, return
    if (central.state != CBCentralManagerStatePoweredOn) {
        return;
    }
    
    if (central.state == CBCentralManagerStatePoweredOn) {
        // Scan for devices
        [self.centralManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]]
                                                    options:@{ CBCentralManagerScanOptionAllowDuplicatesKey : @YES }];
        NSLog(@"Scanning started");
    }
}

#pragma mark - CBPeripheralDelegate

//Peripheral handlers

// CBPeripheralDelegate - Invoked when you discover the peripheral's available services.
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    if (error) {
        [self cleanup];
        return;
    }
    
    // Discovers characteristics in peripheral
    for (CBService *service in peripheral.services) {
        [peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:TRANSFER_READ_UUID],
                                              [CBUUID UUIDWithString:TRANSFER_WRITE_UUID]] forService:service];
    }
}

// Invoked when you discover the characteristics of a specified service.
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    if (error) {
        [self cleanup];
        return;
    }
    
    //Register characteristics
    for (CBCharacteristic *characteristic in service.characteristics) {
        NSLog(@"Discovered characteristic %@", characteristic);
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:TRANSFER_WRITE_UUID]]) {
            self.writeCharacteristic = characteristic;
            [self.receiver updateData];
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
        }
    }
}

// Invoked when you retrieve a specified characteristic's value, or when the peripheral device notifies your app that the characteristic's value has changed.
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        NSLog(@"Error");
        return;
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    
    if (![characteristic.UUID isEqual:[CBUUID UUIDWithString:TRANSFER_READ_UUID]]) {
        return;
    }
    
    if (characteristic.isNotifying) {
        NSLog(@"Notification began on %@", characteristic);
        
    } else {
        // Notification has stopped
        [self.centralManager cancelPeripheralConnection:peripheral];
    }
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    self.discoveredPeripheral = nil;
    
    [self.receiver updateData];
    
    [self.centralManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]]
                                                options:@{ CBCentralManagerScanOptionAllowDuplicatesKey : @YES }];
}

//Sends the speed data to the bluetooth robot based on the x and y coordinate of the direction to travel in (-1 to 1 each)
-(void)sendSpeedDataWithX:(double)x andY:(double)y{
    Coords coords = [self convertX:x andY:y];
    [self sendSpeedDataWithLeft:coords.x andRight:coords.y];
}

//Sends the speed data with a given left motor value and right motor value (-1 to 1 each)
-(void)sendSpeedDataWithLeft:(double)x andRight:(double)y{
    double x2 = x * fabs(x);
    double y2 = y * fabs(y);
    UInt8 fx = (x2 + 1) * 127 + 1;
    UInt8 fy = (y2 + 1) * 127 + 1;
    NSLog(@"left: %i right: %i", fx, fy);
    UInt8 data[3] = {fx, fy, 0};
    
    
    [self writeData:[NSData dataWithBytes:data length:3]];
}

-(void)sendOptionDataWithOption:(UInt8)option{
    UInt8 data[3] = {1, 1, option};
    [self writeData:[NSData dataWithBytes:data length:3]];
}

//Writes the data to the bluetooth robot
-(void)writeData:(NSData *) data{
    if([self bluetoothIsOn]){
        NSLog(@"Sent data");
        //Send a bluetooth event
        [self.discoveredPeripheral writeValue:data forCharacteristic:self.writeCharacteristic type:CBCharacteristicWriteWithoutResponse];
    }
}

//Converts from x and y of the direction to travel in to the left and right motor power
-(Coords)convertX: (double) x andY:(double) y{
    double r = sqrt(x*x + y*y);
    double theta = atan2(x, y);
    //Rotate by 45 degrees
    theta = theta + M_PI/4;
    //Convert from polar to rectangular
    double newX = r * cos(theta);
    double newY = r * sin(theta);
    //Gets the maximum of the original value
    double maxValue = fmax(fabs(x), fabs(y));
    if(maxValue == 0){
        return [self makeCoordWithX:newX andY:newY];
    }
    double newMax = fmax(fabs(newX), fabs(newY));
    //Normalizes the current value to the maximum of the original value
    double ratio = newMax / maxValue;
    return [self makeCoordWithX: newX / ratio andY: newY / ratio];
}

//Creates a new Coords struct with the given x and y values
-(Coords)makeCoordWithX: (double) x andY: (double) y{
    Coords coord;
    coord.x = x;
    coord.y = y;
    return coord;
}

//Returns a string representation of the current bluetooth status
-(NSString *)bluetoothStatus{
    if([self bluetoothIsOn]){
        return @"Bluetooth connected";
    }
    else{
        return @"Bluetooth not connected";
    }
}

//Returns true if bluetooth is currently connected
-(bool)bluetoothIsOn{
    return self.discoveredPeripheral != nil && self.writeCharacteristic != nil;
}

@end
