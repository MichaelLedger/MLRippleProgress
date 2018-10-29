//
//  MLRippleProgress.h
//  MLRippleProgress-Demo
//
//  Created by MountainX on 2018/10/29.
//  Copyright © 2018年 MTX Software Technology Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MLRippleProgress : UIView

/**
 水波颜色组
 */
@property (nonatomic, strong) NSArray <UIColor *> *waveColors;

/**
 水量百分比 (0~1)
 */
@property (nonatomic, assign) CGFloat poolPercent;

/**
 水波振幅
 */
@property (nonatomic, assign) CGFloat waveAmplitude;

/**
 水波传播速度
 */
@property (nonatomic, assign) CGFloat waveFlowSpeed;

/**
 水波上涨速度
 */
@property (nonatomic, assign) CGFloat waveGrowSpeed;

-(void)startWave;

-(void)stopWave;

-(void)resetWave;

@end
