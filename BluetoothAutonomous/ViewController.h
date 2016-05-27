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
#import "PIDSystem.h"
#import <CoreMotion/CoreMotion.h>

double currentMaxAccelX;
double currentMaxAccelY;
double currentMaxAccelZ;
double currentMaxRotX;
double currentMaxRotY;
double currentMaxRotZ;

@interface ViewController : UIViewController <BluetoothControlReceiver, UITextFieldDelegate>

@property BluetoothControl * control;
@property (weak, nonatomic) IBOutlet UILabel *bluetoothStatusLabel;
@property (weak, nonatomic) IBOutlet UIButton *powerButton;
@property (strong, nonatomic) CMMotionManager *motionManager;
@property (strong, nonatomic) PIDSystem *pid;
@property (weak, nonatomic) IBOutlet UITextField *proportional;
@property (weak, nonatomic) IBOutlet UITextField *integral;
@property (weak, nonatomic) IBOutlet UITextField *derivative;
@property (weak, nonatomic) IBOutlet UITextField *exponent;
@property (weak, nonatomic) IBOutlet UISlider *calibration;
@property (weak, nonatomic) IBOutlet UILabel *orientationLabel;

@end

