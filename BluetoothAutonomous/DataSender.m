//
//  DataSender.m
//  BluetoothAutonomous
//
//  Created by Markus Feng on 5/30/16.
//  Copyright © 2016 Markus Feng. All rights reserved.
//

#import "DataSender.h"

@implementation DataSender{
    NSInputStream *inputStream;
    NSOutputStream *outputStream;
    bool connected;
    volatile bool done;
}

-(instancetype)initWithAddress:(NSString *)address andPort:(uint)port{
    self = [super init];
    if(self){
        CFReadStreamRef readStream;
        CFWriteStreamRef writeStream;
        CFStreamCreatePairWithSocketToHost(NULL, (__bridge CFStringRef)address, port, &readStream, &writeStream);
        inputStream = (__bridge NSInputStream *)readStream;
        outputStream = (__bridge NSOutputStream *)writeStream;
    }
    return self;
}

-(void)sendData:(NSString*) string{
    if(done){
        NSData *data = [[NSData alloc] initWithData:[string dataUsingEncoding:NSASCIIStringEncoding]];
        [outputStream write:[data bytes] maxLength:[data length]];
    }
}

-(void)connect{
    if(connected){
        return;
    }
    connected = true;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [inputStream open];
        [outputStream open];
        done = true;
    });
}

@end
