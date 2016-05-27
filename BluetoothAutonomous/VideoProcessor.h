//
//  VideoProcessor.h
//  BluetoothAutonomous
//
//  Created by Markus Feng on 4/19/16.
//  Copyright © 2016 Markus Feng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

@interface VideoProcessor : NSObject<AVCaptureVideoDataOutputSampleBufferDelegate>

@property AVCaptureSession * session;
@property AVCaptureDevice * device;
@property AVCaptureDeviceInput * input;
@property AVCaptureVideoDataOutput * output;
@property bool authorized;
@property UIImageView * imageView;

-(void)checkCamera;
-(void)start;
-(void)stop;

@end
