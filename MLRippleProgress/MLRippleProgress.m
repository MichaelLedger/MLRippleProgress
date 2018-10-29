//
//  MLRippleProgress.m
//  MLRippleProgress-Demo
//
//  Created by MountainX on 2018/10/29.
//  Copyright © 2018年 MTX Software Technology Co.,Ltd. All rights reserved.
//

#import "MLRippleProgress.h"

@interface MLRippleProgress ()

@property (nonatomic, strong) NSMutableArray <CAShapeLayer *> *waveLayers;

@property (nonatomic, strong) CADisplayLink *waveDisplayLink;//计时器

@property (nonatomic, assign) CGFloat lastPoolPercent;//上次水量百分比

@property (nonatomic, assign) CGFloat waveOffsetX;//波纹X位移

@property (nonatomic, assign) CGFloat variableWaveAmplitude;//波幅仿真变量

@property (nonatomic, assign) BOOL needIncrease;//波幅仿真是否增大

@end

@implementation MLRippleProgress

#pragma mark - Initialize
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        [self initData];
        [self drawWaves];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        self.backgroundColor = [UIColor clearColor];
        [self initData];
        [self drawWaves];
    }
    return self;
}

#pragma mark - Init Data
- (void)initData {
    _waveColors = @[[self randamColor],[self randamColor]];
    _poolPercent = 0;
    _waveAmplitude = 5;
    _waveFlowSpeed = 0.4/M_PI;
    _waveGrowSpeed = 0.002;
}

#pragma mark - Public Method
- (void)startWave {
    [self validateDisplayLink];
}

- (void)stopWave {
    [self invalideDisplayLink];
}

- (void)resetWave {
    _poolPercent = 0;
    _needIncrease = NO;
    _variableWaveAmplitude = 0;
    [self invalideDisplayLink];
    [self.waveLayers enumerateObjectsUsingBlock:^(CAShapeLayer * _Nonnull waveLayer, NSUInteger idx, BOOL * _Nonnull stop) {
        [waveLayer removeFromSuperlayer];
    }];
    [self drawWaves];
}

#pragma mark - Draw Waves
- (void)drawWaves {
    [_waveColors enumerateObjectsUsingBlock:^(UIColor * _Nonnull waveColor, NSUInteger idx, BOOL * _Nonnull stop) {
        CAShapeLayer *waveLayer = [CAShapeLayer layer];
        waveLayer.fillColor = waveColor.CGColor;
        [self.layer addSublayer:waveLayer];
        [self.waveLayers addObject:waveLayer];
    }];
    
}

#pragma mark - Validate DisplayLink
- (void)validateDisplayLink {
    [self.waveDisplayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

#pragma mark - Invalide DisplayLink
- (void)invalideDisplayLink {
    [self.waveDisplayLink removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

#pragma mark - DisplayLink Fire
- (void)checkPoolPercent {
    _waveOffsetX += _waveFlowSpeed;
    [self drawWavePath];
}

#pragma mark - Emulation Wave
- (void)emulationWave {
    if (_needIncrease) {
        _variableWaveAmplitude += 0.01;
    } else {
        _variableWaveAmplitude -= 0.01;
    }
    
    if (_variableWaveAmplitude <= 1.0) {
        _needIncrease = YES;
    } else if (_variableWaveAmplitude > 1.6 - fabs(_poolPercent - 0.5)) {
        _needIncrease = NO;
    }
}

#pragma mark - DrawWavePath
- (void)drawWavePath {
    [self emulationWave];
    
    CGFloat adjustPoolPercent = _lastPoolPercent;
    if (_poolPercent > _lastPoolPercent) {//increase
        adjustPoolPercent = _lastPoolPercent + _waveGrowSpeed;
    } else {//decrease
        adjustPoolPercent = _lastPoolPercent - _waveGrowSpeed;
    }
    
    [self.waveLayers enumerateObjectsUsingBlock:^(CAShapeLayer * _Nonnull waveLayer, NSUInteger idx, BOOL * _Nonnull stop) {
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathMoveToPoint(path, nil, 0, adjustPoolPercent);
        for (CGFloat x = 0.f; x <= self.bounds.size.width; x++) {
            CGFloat y = self.bounds.size.height * (1 - adjustPoolPercent);
            if (idx % 2) {
                y += self->_waveAmplitude * self->_variableWaveAmplitude * sin(1.29 * M_PI / self.bounds.size.width * x + self->_waveOffsetX);
            } else {
                y += self->_waveAmplitude * self->_variableWaveAmplitude * cos(1.29 * M_PI / self.bounds.size.width * x + self->_waveOffsetX);
            }
            
            CGPathAddLineToPoint(path, nil, x, y);
        }
        CGPathAddLineToPoint(path, nil, self.bounds.size.width, self.bounds.size.height);
        CGPathAddLineToPoint(path, nil, 0, self.bounds.size.height);
        CGPathCloseSubpath(path);
        waveLayer.path = path;
        CGPathRelease(path);
    }];
    _lastPoolPercent = adjustPoolPercent;
}

#pragma mark - Lazy Loader
- (NSMutableArray<CAShapeLayer *> *)waveLayers {
    if (!_waveLayers) {
        _waveLayers = [NSMutableArray array];
    }
    return _waveLayers;
}

- (CADisplayLink *)waveDisplayLink {
    if (!_waveDisplayLink) {
        _waveDisplayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(checkPoolPercent)];
    }
    return _waveDisplayLink;
}

#pragma mark - Setter
- (void)setPoolPercent:(CGFloat)poolPercent {
    _poolPercent = poolPercent;
    if (_poolPercent >= 1) {
        [self invalideDisplayLink];
    } else {
        [self validateDisplayLink];
    }
}

#pragma mark - Helper
- (UIColor *)randamColor {
    return [UIColor colorWithRed:(arc4random() % 255 / 255.f) green:(arc4random() % 255 / 255.f) blue:(arc4random() % 255 / 255.f) alpha:1.f];
}

#pragma mark - LayoutSubviews
- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.layer.cornerRadius = MIN(CGRectGetHeight(self.frame)/2, CGRectGetWidth(self.frame)/2);
    self.layer.masksToBounds = YES;
}

#pragma mark - Dealloc
- (void)dealloc {
    [self invalideDisplayLink];
}

@end
