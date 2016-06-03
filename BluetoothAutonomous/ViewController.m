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
#import "VideoProcessor.h"
#import "DataSender.h"

@interface ViewController ()

@property bool started;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
//@property VideoProcessor * processor;
//@property DataSender * sender;

@end

@implementation ViewController{
    bool toCalibrate;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.control = [[BluetoothControl alloc] initWithReceiver:self];
    
    self.proportional.text = @"4.0";
    self.integral.text = @"0.05";
    self.derivative.text = @"0.05";
    self.exponent.text = @"0.5";
    
    self.proportional.delegate = self;
    self.integral.delegate = self;
    self.derivative.delegate = self;
    
    [self.proportional setReturnKeyType:UIReturnKeyDone];
    [self.integral setReturnKeyType:UIReturnKeyDone];
    [self.derivative setReturnKeyType:UIReturnKeyDone];
    
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
    /*
    self.processor = [[VideoProcessor alloc] init];
    self.processor.imageView = self.imageView;
    [self.processor checkCamera];
    [self.processor start];
     */
    
    toCalibrate = false;
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
        self.pid = [[PIDSystem alloc] initWithP:[self.proportional.text doubleValue] andI:[self.integral.text doubleValue] andD:[self.derivative.text doubleValue]];
        //self.sender = [[DataSender alloc] initWithAddress:@"169.254.15.26" andPort:48484];
        toCalibrate = true;
        //[self.sender connect];
        [self.control sendOptionDataWithOption:1];
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
    double orientation = [self powMag:attitude.pitch to:[self.exponent.text doubleValue]];
    double oconst = 3.1415926/2;
    if(toCalibrate){
        self.calibration.value = orientation * -10;
        toCalibrate = false;
    }
    double calibrationOffset = self.calibration.value * 0.1;
    [self.orientationLabel setText:[NSString stringWithFormat:@"%f", [self displayRound:orientation +calibrationOffset]]];
    double orientationPID = (orientation+oconst+calibrationOffset)/oconst;
    double orientationResult = [self.pid pid:orientationPID];
    double data = (orientationResult);
    NSLog(@"%f, %f, %f",orientation, orientationPID, data);
    
    if(self.started){
        [self.control sendSpeedDataWithLeft:data andRight:data];
        //[self.sender sendData:[NSString stringWithFormat:@"%f\n", orientation]];
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

-(double)displayRound:(double)value{
    return ((long)(value * 100))/100.0;
}
-(double)powMag:(double)base to:(double)exponent{
    if(base < 0){
        return -pow(-base, exponent);
    }
    else{
        return pow(base, exponent);
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return true;
}

@end
