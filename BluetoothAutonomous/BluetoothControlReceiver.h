//
//  BluetoothControlReceiver.h
//  BluetoothAutonomous
//
//  Created by Markus Feng on 3/29/16.
//  Copyright © 2016 Markus Feng. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol BluetoothControlReceiver <NSObject>

-(void)updateData;

@end
