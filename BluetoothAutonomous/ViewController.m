//
//  ViewController.m
//  BluetoothAutonomous
//
//  Created by Markus Feng on 3/29/16.
//  Copyright © 2016 Markus Feng. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

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
}

@end
