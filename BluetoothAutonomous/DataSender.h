//
//  DataSender.h
//  BluetoothAutonomous
//
//  Created by Markus Feng on 5/30/16.
//  Copyright © 2016 Markus Feng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataSender : NSObject

-(instancetype)initWithAddress:(NSString *)address andPort:(uint)port;
-(void)sendData:(NSString*) string;
-(void)connect;

@end
