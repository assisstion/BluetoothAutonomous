//
//  VideoProcessor.m
//  BluetoothAutonomous
//
//  Created by Markus Feng on 4/19/16.
//  Copyright © 2016 Markus Feng. All rights reserved.
//
//Image creation code: http://stackoverflow.com/questions/11201251/implementing-sample-buffer-delegate-method-iphone

#import "VideoProcessor.h"

@implementation VideoProcessor

-(instancetype)init{
    self = [super init];
    if(self){
        self.session = [[AVCaptureSession alloc] init];
        self.session.sessionPreset = AVCaptureSessionPresetMedium;
        self.device = [self frontCamera];
        NSError *err = nil;
        self.input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:&err];
        if(!self.input){
            //Handle error
            NSLog(@"Error in initializing video processor");
        }
        else{
            [self.session addInput:self.input];
            self.output = [[AVCaptureVideoDataOutput alloc] init];
            [self.session addOutput:self.output];
            self.output.videoSettings = @{(NSString*)
                                          kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_32BGRA)};
            //self.output.minFrameDuration = CMTimeMake(1, 15);
            dispatch_queue_t queue = dispatch_queue_create("MyQueue", NULL);
            [self.output setSampleBufferDelegate:self queue:queue];
            //dispatch_release(queue);
            
        }
    }
    return self;
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection{
   UIImage *img = [self imageFromSampleBuffer:sampleBuffer];
    dispatch_async(dispatch_get_main_queue(), ^{
        if(self.imageView != nil){
            self.imageView.image=img;
        }
    });
}

// Create a UIImage from sample buffer data
- (UIImage *) imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer
{
    
    // Get a CMSampleBuffer's Core Video image buffer for the media data
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    // Lock the base address of the pixel buffer
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    
    // Get the number of bytes per row for the pixel buffer
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    // Get the pixel buffer width and height
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    
    
    // Get the number of bytes per row for the pixel buffer
    u_int8_t *baseAddress = (u_int8_t *)malloc(bytesPerRow*height);
    memcpy( baseAddress, CVPixelBufferGetBaseAddress(imageBuffer), bytesPerRow * height     );
    
    // size_t bufferSize = CVPixelBufferGetDataSize(imageBuffer);
    
    // Create a device-dependent RGB color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // Create a bitmap graphics context with the sample buffer data
    
    //The context draws into a bitmap which is `width'
    //  pixels wide and `height' pixels high. The number of components for each
    //      pixel is specified by `space'
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8,
                                                 bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipFirst);
    
    // Create a Quartz image from the pixel data in the bitmap graphics context
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    
    // Unlock the pixel buffer
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    
    
    // Free up the context and color space
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    // Create an image object from the Quartz image
    UIImage *image = [UIImage imageWithCGImage:quartzImage scale:1.0 orientation:UIImageOrientationRight];
    
    free(baseAddress);
    // Release the Quartz image
    CGImageRelease(quartzImage);
    
    
    return (image);
}


-(void)checkCamera{
    NSString *mediaType = AVMediaTypeVideo;
    
    [AVCaptureDevice requestAccessForMediaType:mediaType completionHandler:^(BOOL granted) {
        if (granted)
        {
            //Granted access to mediaType
            self.authorized = true;
        }
        else
        {
            //Not granted access to mediaType
            dispatch_async(dispatch_get_main_queue(), ^{
                [[[UIAlertView alloc] initWithTitle:@"AVCam!"
                                            message:@"AVCam doesn't have permission to use Camera, please change privacy settings"
                                           delegate:self
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil] show];
                self.authorized = false;
            });
        }
    }];
}

-(void)start{
    [self.session startRunning];
}

-(void)stop{
    [self.session stopRunning];
}

- (AVCaptureDevice *)frontCamera {
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if ([device position] == AVCaptureDevicePositionFront) {
            return device;
        }
    }
    return nil;
}


@end
