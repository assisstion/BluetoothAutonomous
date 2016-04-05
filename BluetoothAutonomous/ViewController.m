//
//  ViewController.m
//  BluetoothAutonomous
//
//  Created by Markus Feng on 3/29/16.
//  Copyright © 2016 Markus Feng. All rights reserved.
//
//  Accelerometer Code
//  https://github.com/stephsharp/SpiritLevelCircle

#import "ViewController.h"

@interface ViewController ()

@property bool started;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.control = [[BluetoothControl alloc] initWithReceiver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidDisappear:(BOOL)animated{
    [self.control stop];
}

-(void)updateData{
    self.bluetoothStatusLabel.text = self.control.bluetoothStatus;
}

- (IBAction)startAction:(id)sender {
    if(!self.started){
        NSLog(@"Begin");
        [self.control sendSpeedDataWithLeft:1 andRight:-1];
        [self.powerButton setTitle:@"Stop" forState:UIControlStateNormal];
        self.started = true;
    }
    else{
        NSLog(@"End");
        [self.control sendSpeedDataWithLeft:0 andRight:0];
        [self.powerButton setTitle:@"Start" forState:UIControlStateNormal];
        self.started = false;
    }
}

-(void)updateWithXRotation:(double)rotation{
    if(rotation > 0){
        //move backwards
        [self.control sendSpeedDataWithLeft:-1 andRight:-1];
    }
    else{
        //move forwards
        [self.control sendSpeedDataWithLeft:1 andRight:1];
    }
}

@end
