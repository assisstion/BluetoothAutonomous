//
//  PIDSystem.m
//  BluetoothAutonomous
//
//  Created by Markus Feng on 4/8/16.
//  Copyright © 2016 Markus Feng. All rights reserved.
//

#import "PIDSystem.h"

@implementation PIDSystem{
    double proportional;
    double integral;
    double derivative;
    double lastValue;
    bool started;
}

-(instancetype)init{
    self = [super init];
    return self;
}

-(instancetype)initWithP:(double)p andI:(double)i andD: (double)d{
    self = [super init];
    if(self){
        self.pConstant = p;
        self.iConstant = i;
        self.dConstant = d;
        self.target = 1;
        self.min = -1;
        self.max = 1;
    }
    return self;
}

-(instancetype)initWithP:(double)p andI:(double)i andD: (double)d andTarget: (double)target{
    self = [super init];
    if(self){
        self.pConstant = p;
        self.iConstant = i;
        self.dConstant = d;
        self.target = target;
        self.min = -target;
        self.max = target;
    }
    return self;
}

-(instancetype)initWithP:(double)p andI:(double)i andD: (double)d andTarget: (double)target andMin:(double)min andMax:(double)max{
    self = [super init];
    if(self){
        self.pConstant = p;
        self.iConstant = i;
        self.dConstant = d;
        self.target = target;
        self.min = min;
        self.max = max;
    }
    return self;
}


-(double)pid:(double)input{
    if(!started){
        lastValue = input;
        started = true;
        return 0;
    }
    double pid = [self pidInternal:input];
    if(pid > self.max){
        pid = self.max;
    }
    if(pid < self.min){
        pid = self.min;
    }
    lastValue = input;
    return pid;
}

-(double)pidInternal:(double)input{
    double error = self.target - input;
    proportional = error;
    integral = integral + error;
    if(integral > self.max){
        integral = self.max;
    }
    if(integral < self.min){
        integral = self.min;
    }
    derivative = input - lastValue;
    return self.pConstant * proportional + self.iConstant * integral + self.dConstant * derivative;
}

@end
