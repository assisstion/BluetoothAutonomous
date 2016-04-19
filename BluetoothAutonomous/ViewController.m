//
//  ViewController.m
//  BluetoothAutonomous
//
//  Created by Markus Feng on 3/29/16.
//  Copyright © 2016 Markus Feng. All rights reserved.
//
//  Accelerometer Code
//  https://github.com/acekiller/iOS-Samples/tree/master/BubbleLevel
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
    self.pid = [[PIDSystem alloc] initWithP:1 andI:0.03 andD:0.03];
    
    currentMaxAccelX = 0;
    currentMaxAccelY = 0;
    currentMaxAccelZ = 0;
    
    currentMaxRotX = 0;
    currentMaxRotY = 0;
    currentMaxRotZ = 0;
    self.motionManager = [[CMMotionManager alloc] init];
    self.motionManager.accelerometerUpdateInterval = 1.0;
    self.motionManager.gyroUpdateInterval = 1.0;
    
    [self.motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue]
                                             withHandler:^(CMAccelerometerData  *accelerometerData, NSError *error) {
                                                 [self outputAccelerationData:accelerometerData.acceleration];
                                                 if(error){
                                                     NSLog(@"%@", error);
                                                 }
                                             }];
    
    [self.motionManager startGyroUpdatesToQueue:[NSOperationQueue currentQueue]
                                    withHandler:^(CMGyroData *gyroData, NSError *error) {[self outputRotationData:gyroData.rotationRate];}];
    
    [self.motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMDeviceMotion * deviceMotion, NSError *error) {
        [self updateWithAttitude:deviceMotion.attitude];
    }];
}

//Motion Manager Functions
-(void)outputAccelerationData:(CMAcceleration)acceleration
{
    /*NSLog(@"x - acceleration %@",[NSString stringWithFormat:@" %.2fg",acceleration.x]);
    if(fabs(acceleration.x) > fabs(currentMaxAccelX))
    {
        currentMaxAccelX = acceleration.x;
    }
    NSLog(@"y-acceleration %@",[NSString stringWithFormat:@" %.2fg",acceleration.y]);
    if(fabs(acceleration.y) > fabs(currentMaxAccelY))
    {
        currentMaxAccelY = acceleration.y;
    }
    NSLog(@"z-acceleration%@",[NSString stringWithFormat:@" %.2fg",acceleration.z]);
    if(fabs(acceleration.z) > fabs(currentMaxAccelZ))
    {
        currentMaxAccelZ = acceleration.z;
    }
    
    NSLog(@"maxx-accel%@",[NSString stringWithFormat:@" %.2f",currentMaxAccelX]);
    NSLog(@"maxy-accel%@",[NSString stringWithFormat:@" %.2f",currentMaxAccelY]);
    NSLog(@"maxz-accel%@",[NSString stringWithFormat:@" %.2f",currentMaxAccelZ]);*/
    
    
}
-(void)outputRotationData:(CMRotationRate)rotation
{
    /*NSLog(@"x-rotation%@",[NSString stringWithFormat:@" %.2fr/s",rotation.x]);
    NSLog(@"y-rotation%@",[NSString stringWithFormat:@" %.2fr/s",rotation.y]);
    NSLog(@"z-rotation%@",[NSString stringWithFormat:@" %.2fr/s",rotation.z]);*/
    [self updateWithXRotation:rotation.x];
    
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
        //[self.control sendSpeedDataWithLeft:1 andRight:-1];
        [self.powerButton setTitle:@"Stop" forState:UIControlStateNormal];
        self.started = true;
    }
    else{
        NSLog(@"End");
        //[self.control sendSpeedDataWithLeft:0 andRight:0];
        [self.powerButton setTitle:@"Start" forState:UIControlStateNormal];
        self.started = false;
    }
}

-(void)updateWithXRotation:(double)rotation{
    
    /*if(self.started){
        double threshold = 0.5;
        if(rotation > threshold){
            //move forwards
            [self.control sendSpeedDataWithLeft:1 andRight:1];
        }
        else if(rotation < -threshold){
            //move backwards
            [self.control sendSpeedDataWithLeft:-1 andRight:-1];
        }
        else{
            //stop
            [self.control sendSpeedDataWithLeft:0 andRight:0];
        }
    }
    else{
        //stop
        [self.control sendSpeedDataWithLeft:0 andRight:0];
    }*/
}

-(void)updateWithAttitude:(CMAttitude *)attitude{
    /*
    NSLog(@"roll%@",[NSString stringWithFormat:@" %.2f",attitude.roll]);
    NSLog(@"pitch%@",[NSString stringWithFormat:@" %.2f",attitude.pitch]);
    NSLog(@"yaw%@",[NSString stringWithFormat:@" %.2f",attitude.yaw]);
     */
    double orientation = attitude.pitch;
    double oconst = 3.1415926/2;
    double orientationPID = (orientation+oconst)/oconst;
    double orientationResult = [self.pid pid:orientationPID];
    double data = (orientationResult);
    NSLog(@"%f, %f, %f",orientation, orientationPID, data);
    
    if(self.started){
        [self.control sendSpeedDataWithLeft:data andRight:data];
        /*double threshold = 0.02;
        if(orientation > threshold){
            //move forwards
            [self.control sendSpeedDataWithLeft:1 andRight:1];
        }
        else if(orientation < -threshold){
            //move backwards
            [self.control sendSpeedDataWithLeft:-1 andRight:-1];
        }
        else{
            //stop
            [self.control sendSpeedDataWithLeft:0 andRight:0];
        }*/
    }
    else{
        //stop
        [self.control sendSpeedDataWithLeft:0 andRight:0];
    }
}

@end
