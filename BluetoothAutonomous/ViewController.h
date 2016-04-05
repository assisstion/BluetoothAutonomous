//
//  ViewController.h
//  BluetoothAutonomous
//
//  Created by Markus Feng on 3/29/16.
//  Copyright © 2016 Markus Feng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BluetoothControlReceiver.h"
#import "BluetoothControl.h"

@interface ViewController : UIViewController <BluetoothControlReceiver>

@property BluetoothControl * control;
@property (weak, nonatomic) IBOutlet UILabel *bluetoothStatusLabel;
@property (weak, nonatomic) IBOutlet UIButton *powerButton;

@end

