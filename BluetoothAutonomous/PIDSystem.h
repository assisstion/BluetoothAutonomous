//
//  PIDSystem.h
//  BluetoothAutonomous
//
//  Created by Markus Feng on 4/8/16.
//  Copyright © 2016 Markus Feng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PIDSystem : NSObject

@property double pConstant;
@property double iConstant;
@property double dConstant;
@property double target;
@property double min;
@property double max;

-(instancetype)init;
-(instancetype)initWithP:(double)p andI:(double)i andD: (double)d;
-(instancetype)initWithP:(double)p andI:(double)i andD: (double)d andTarget: (double)target;
-(instancetype)initWithP:(double)p andI:(double)i andD: (double)d andTarget: (double)target andMin:(double)min andMax:(double)max;

-(double)pid:(double)input;


@end
