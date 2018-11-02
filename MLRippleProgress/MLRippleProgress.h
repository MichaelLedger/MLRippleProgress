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
 Color of Waves
 水波颜色组
 */
@property (nonatomic, strong) NSArray <UIColor *> *waveColors;

/**
 Pool Water Percent
 水量百分比 (0~1)
 */
@property (nonatomic, assign) CGFloat poolPercent;

/**
 Record Pool Water Percent
 上次水量百分比
 */
@property (nonatomic, assign) CGFloat lastPoolPercent;

/**
 Wave Amplitude
 水波振幅
 */
@property (nonatomic, assign) CGFloat waveAmplitude;

/**
 Wave Flow Speed
 水波传播速度
 */
@property (nonatomic, assign) CGFloat waveFlowSpeed;

/**
 Wave Grow Speed
 水波上涨速度
 */
@property (nonatomic, assign) CGFloat waveGrowSpeed;

/**
 Wave Begin Flow
 开始流动
 */
-(void)startWave;

/**
 Wave Stop Flow
 停止流动
 #warning -  Superview must call this method in superview's dealloc to remove CADisplayLink, otherwise will cause memory leak!!!
 父视图必须在其Dealloc方法中调用此方法来移除定时器，否则会造成内存泄露！！！
 e.g.
 @implementation MLRippleDownloadBtn
 
 #pragma mark - Dealloc
 - (void)dealloc {
 [(MLRippleProgress *)self.progress stopWave];
 }
 
 @end
 */
-(void)stopWave;

/**
 Restart water flooding
 重新注水
 */
-(void)resetWave;

/**
 Restart water flooding without animation
 无动画重新注水
 */
-(void)resetWaveWithoutAnimation;

@end
