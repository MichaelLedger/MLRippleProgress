//
//  ViewController.m
//  MLRippleProgress-Demo
//
//  Created by MountainX on 2018/10/29.
//  Copyright © 2018年 MTX Software Technology Co.,Ltd. All rights reserved.
//

#import "ViewController.h"
#import "MLRippleProgress.h"

@interface ViewController ()

@property (nonatomic, assign) BOOL needIncrease;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
}

- (void)setupUI {
    MLRippleProgress *rippleProgress = [[MLRippleProgress alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.view.frame) - 180)/2, (CGRectGetHeight(self.view.frame) - 180) / 2, 180, 180)];
    rippleProgress.poolPercent = 0.2;
    [self.view addSubview:rippleProgress];
    [rippleProgress startWave];
    
    _needIncrease = YES;
    
    __block NSTimer *testTimer = [NSTimer timerWithTimeInterval:1.0 repeats:YES block:^(NSTimer * _Nonnull timer) {
        if (self->_needIncrease) {
            rippleProgress.poolPercent += 0.1;
        } else {
            rippleProgress.poolPercent -= 0.1;
        }
        if (rippleProgress.poolPercent >= 1.f) {
            self->_needIncrease = NO;
        }
        if (rippleProgress.poolPercent <= 0) {
            self->_needIncrease = YES;
        }
    }];
    [[NSRunLoop mainRunLoop] addTimer:testTimer forMode:NSRunLoopCommonModes];
    [testTimer fire];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(15.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [testTimer invalidate];
        testTimer = nil;
        [rippleProgress stopWave];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [rippleProgress startWave];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [rippleProgress resetWave];
            });
        });
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
