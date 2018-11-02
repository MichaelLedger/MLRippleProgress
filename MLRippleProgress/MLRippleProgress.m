//
//  MLRippleProgress.m
//  MLRippleProgress-Demo
//
//  Created by MountainX on 2018/10/29.
//  Copyright © 2018年 MTX Software Technology Co.,Ltd. All rights reserved.
//

#import "MLRippleProgress.h"

#define RGB(r, g, b)    [UIColor colorWithRed:(r)/255.f green:(g)/255.f blue:(b)/255.f alpha:1.f]
#define RGBA(r, g, b, a)    [UIColor colorWithRed:(r)/255.f green:(g)/255.f blue:(b)/255.f alpha:a]
#define RGBHEX(hex) [UIColor colorWithRed:((float)((hex & 0xFF0000) >> 16)) / 255.0 green:((float)((hex & 0xFF00) >> 8)) / 255.0 blue:((float)(hex & 0xFF)) / 255.0 alpha:1]
#define RGBHEXA(hex,a) [UIColor colorWithRed:((float)(((hex) & 0xFF0000) >> 16))/255.0 green:((float)(((hex) & 0xFF00)>>8))/255.0 blue: ((float)((hex) & 0xFF))/255.0 alpha:(a)]

@interface MLRippleProgress ()

@property (nonatomic, strong) NSMutableArray <CAShapeLayer *> *waveLayers;

/**
 Timer
 计时器
 */
@property (nonatomic, strong) CADisplayLink *waveDisplayLink;

/**
 Record wave horizontal offset
 波纹X位移
 */
@property (nonatomic, assign) CGFloat waveOffsetX;

/**
 Varialbe for emulation wave amplitude changing
 波幅仿真变量
 */
@property (nonatomic, assign) CGFloat variableWaveAmplitude;

/**
 Whether increase Varialbe for emulation wave amplitude changing
 波幅仿真是否增大
 */
@property (nonatomic, assign) BOOL needIncrease;

@end

@implementation MLRippleProgress

#pragma mark - Initialize
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
//        self.userInteractionEnabled = NO;//If superview is UIButton, need add this.
        [self initData];
        [self drawWaves];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        self.backgroundColor = [UIColor clearColor];
//        self.userInteractionEnabled = NO;//If superview is UIButton, need add this.
        [self initData];
        [self drawWaves];
    }
    return self;
}

#pragma mark - Init Data
- (void)initData {
    _waveColors = @[RGBA(0,186,128,0.8), RGBA(111,224,195,1)];
    _poolPercent = 0;
    _waveAmplitude = self.bounds.size.width / 20;
    _waveFlowSpeed = 0.4/M_PI;
    _waveGrowSpeed = 0.002;
    _variableWaveAmplitude = 0;
    _lastPoolPercent = 0;
}

#pragma mark - Public Method
- (void)startWave {
    [self validateDisplayLink];
}

- (void)stopWave {
    [self invalideDisplayLink];
}

- (void)resetWave {
    _variableWaveAmplitude = 0;
    _lastPoolPercent = 0;
    [self removeWaves];
    [self drawWaves];
    [self startWave];
}

- (void)resetWaveWithoutAnimation {
    _variableWaveAmplitude = 0;
    _lastPoolPercent = _poolPercent;
    [self removeWaves];
    [self drawWaves];
    [self startWave];
}

#pragma mark - Draw Waves
- (void)drawWaves {
    __weak __typeof(self) weakSelf = self;
    
    [_waveColors enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(UIColor * _Nonnull waveColor, NSUInteger idx, BOOL * _Nonnull stop) {
        CAShapeLayer *waveLayer = [CAShapeLayer layer];
        waveLayer.fillColor = waveColor.CGColor;
        [weakSelf.layer addSublayer:waveLayer];
        [weakSelf.waveLayers addObject:waveLayer];
    }];
}

#pragma mark - Remove Waves
- (void)removeWaves {
    [self.waveLayers enumerateObjectsUsingBlock:^(CAShapeLayer * _Nonnull waveLayer, NSUInteger idx, BOOL * _Nonnull stop) {
        [waveLayer removeFromSuperlayer];
    }];
}

#pragma mark - Validate DisplayLink
- (void)validateDisplayLink {
    if (!_waveDisplayLink) {
        _waveDisplayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(checkPoolPercent)];
        [_waveDisplayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    }
}

#pragma mark - Invalide DisplayLink
- (void)invalideDisplayLink {
    if (_waveDisplayLink) {
        [_waveDisplayLink removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
        [_waveDisplayLink invalidate];
        _waveDisplayLink = nil;
    }
}

#pragma mark - DisplayLink Fire
- (void)checkPoolPercent {
    [self drawWavePath];
}

#pragma mark - Emulation Wave
- (void)emulationWave {
    if (_needIncrease) {
        _variableWaveAmplitude += arc4random() % 10 * 0.001;
    } else {
        _variableWaveAmplitude -= arc4random() % 10 * 0.001;
    }
    
    if (_variableWaveAmplitude <= 0) {
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
        adjustPoolPercent = (_lastPoolPercent + _waveGrowSpeed) > _poolPercent ? _poolPercent : (_lastPoolPercent + _waveGrowSpeed);
    } else {//decrease
        adjustPoolPercent = (_lastPoolPercent - _waveGrowSpeed) < 0 ? 0 : (_lastPoolPercent - _waveGrowSpeed);
    }
    
    _waveOffsetX += _waveFlowSpeed * (0.5 + _variableWaveAmplitude);
    
    __weak __typeof(self) weakSelf = self;
    [self.waveLayers enumerateObjectsUsingBlock:^(CAShapeLayer * _Nonnull waveLayer, NSUInteger idx, BOOL * _Nonnull stop) {
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathMoveToPoint(path, nil, 0, adjustPoolPercent);
        CGFloat diffOffsetX = weakSelf.bounds.size.width / weakSelf.waveLayers.count * idx;
        for (CGFloat x = 0.f; x <= weakSelf.bounds.size.width; x++) {
            CGFloat y = weakSelf.bounds.size.height * (1 - adjustPoolPercent);
                y += weakSelf.waveAmplitude * weakSelf.variableWaveAmplitude * sin(1.29 * M_PI / weakSelf.bounds.size.width * (x - M_PI/weakSelf.waveLayers.count * idx) + weakSelf.waveOffsetX + diffOffsetX);
            CGPathAddLineToPoint(path, nil, x, y);
        }
        CGPathAddLineToPoint(path, nil, weakSelf.bounds.size.width, weakSelf.bounds.size.height);
        CGPathAddLineToPoint(path, nil, 0, weakSelf.bounds.size.height);
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
    [self stopWave];
}

@end
