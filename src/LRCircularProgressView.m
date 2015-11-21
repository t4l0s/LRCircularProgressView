//
//   The MIT License (MIT)
//   Copyright (c) 2015 Lukas Riebel ( https://github.com/t4l0s )
//
//   Permission is hereby granted, free of charge, to any person obtaining a copy
//   of this software and associated documentation files (the "Software"), to deal
//   in the Software without restriction, including without limitation the rights
//   to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//   copies of the Software, and to permit persons to whom the Software is
//   furnished to do so, subject to the following conditions:
//
//   The above copyright notice and this permission notice shall be included in
//   all copies or substantial portions of the Software.
//
//   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//   IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//   FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
//   AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//   LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//   OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//   THE SOFTWARE.

#import "LRCircularProgressView.h"

#define CLAMP(x, low, high) ({\
    __typeof__(x) __x = (x); \
    __typeof__(low) __low = (low);\
    __typeof__(high) __high = (high);\
    __x > __high ? __high : (__x < __low ? __low : __x);\
})

static inline float easeInterpolation(float t, float start, float end)
{
    return (start - end) * t * (t-2) + start;
}

NSString *const LRCircularProgressPlaceholderKey = @"LRCircularProgressPlaceholderKey";

@interface LRCircularProgressView ()

@property (nonatomic, strong) CALayer *containerLayer;

@property (nonatomic, strong) CAShapeLayer *trackLayer;
@property (nonatomic, strong) CAShapeLayer *tintLayer;
@property (nonatomic, strong) CAShapeLayer *remainderTintLayer;

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, assign) float lastProgress;

@end

@implementation LRCircularProgressView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        CALayer *containerLayer = [CALayer new];
        self.containerLayer = containerLayer;
        [self.layer addSublayer: containerLayer];
        
        CAShapeLayer *trackLayer = [CAShapeLayer new];
        trackLayer.fillColor = nil;
        self.trackLayer = trackLayer;
        [containerLayer addSublayer: trackLayer];
        
        CAShapeLayer *tintLayer = [CAShapeLayer new];
        tintLayer.fillColor = nil;
        self.tintLayer = tintLayer;
        [containerLayer addSublayer: tintLayer];
        
        CAShapeLayer *remainderTintLayer = [CAShapeLayer new];
        remainderTintLayer.fillColor = nil;
        self.remainderTintLayer = remainderTintLayer;
        [containerLayer addSublayer: remainderTintLayer];
        
        UILabel *titleLabel = [UILabel new];
        self.titleLabel = titleLabel;
        self.titleLabel.numberOfLines = 0;
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview: titleLabel];
        
        self.progressTintColor = [UIColor colorWithRed:0.976f green:0.251f blue:0.196f alpha:1.00f];
        self.progressRemainderTintColor = [UIColor colorWithRed:0.976f green:0.686f blue:0.031f alpha:1.00f];
        
        self.progressTrackWidth = 7.5f;
        self.progress = 0.;
        self.animationDuration = 2.;
        self.animateText = YES;
        self.textInset = 2.f;
    }
    
    return self;
}

#if TARGET_INTERFACE_BUILDER

- (void)prepareForInterfaceBuilder
{
    self.titleLabel.attributedText = [[NSAttributedString alloc] initWithString: [NSString stringWithFormat: @"Progess\n%.0f%%", self.progress * 100]];
}

#endif

#pragma mark - Getter / Setter

- (void)setProgressTintColor:(UIColor *)progressTintColor
{
    _progressTintColor = progressTintColor;
    
    self.tintLayer.strokeColor = progressTintColor.CGColor;
}

- (void)setProgressTrackColor:(UIColor *)progressTrackColor
{
    _progressTrackColor = progressTrackColor;
    
    self.trackLayer.strokeColor = progressTrackColor.CGColor;
}

- (void)setProgressRemainderTintColor:(UIColor *)progressRemainderTintColor
{
    _progressRemainderTintColor = progressRemainderTintColor;
    
    self.remainderTintLayer.strokeColor = progressRemainderTintColor.CGColor;
}

- (void)setProgressTrackWidth:(CGFloat)progressTrackWidth
{
    _progressTrackWidth = progressTrackWidth;

    self.trackLayer.lineWidth         = progressTrackWidth;
    self.remainderTintLayer.lineWidth = progressTrackWidth;
    self.tintLayer.lineWidth          = progressTrackWidth;
}

- (void)setTextInset:(CGFloat)textInset
{
    _textInset = CLAMP(textInset, 0, CGFLOAT_MAX);
    
    [self setNeedsLayout];
}

- (void)setProgress:(float)progress
{
    [self setProgress: progress animated: NO];
}

- (void)setProgress:(float)progress animated:(BOOL)animated
{
    float parent = _progress;
    
    progress = CLAMP(progress, 0.f, 1.f);

    _lastProgress = progress;
    _progress     = progress;

    float diff = ABS(parent - progress);
    NSTimeInterval duration = self.animationDuration * diff;
    
    [NSObject cancelPreviousPerformRequestsWithTarget: self
                                             selector: @selector(layerUpdateCallback:)
                                               object: nil];
    
    [CATransaction begin];
    [CATransaction setDisableActions: !animated];
    [CATransaction setAnimationDuration: duration];
    
    self.tintLayer.strokeStart = 0.f;
    self.tintLayer.strokeEnd = progress;
    
    self.remainderTintLayer.strokeStart = 1.f - (1.f - progress);
    self.remainderTintLayer.strokeEnd = 1.f;
    
    [CATransaction commit];
    
    __block BOOL hasPlaceholder = NO;
    
    [self.title enumerateAttributesInRange: NSMakeRange(0, self.title.length)
                                   options: kNilOptions
                                usingBlock:^(NSDictionary* attrs, NSRange range, BOOL * stop) {
                                    
                                    if (attrs[LRCircularProgressPlaceholderKey])
                                    {
                                        hasPlaceholder = YES;
                                        *stop = YES;
                                    }
                                }];
    
    if (hasPlaceholder)
    {
        if (animated && self.animatesText)
        {
            for (NSTimeInterval i = 0.; i < duration; i += 0.02)
            {
                [self performSelector: @selector(layerUpdateCallback:)
                           withObject: @(parent + easeInterpolation(i / duration, 0., 1.) * (progress - parent))
                           afterDelay: i];
            }
        } else
        {
            [self updatePlaceholderWithProgress: progress];
        }
    }
}

- (void)setTitle:(NSAttributedString *)title
{
    _title = title;
    
    [self updatePlaceholderWithProgress: self.lastProgress];
}

- (void)setAnimationDuration:(NSTimeInterval)animationDuration
{
    _animationDuration = CLAMP(animationDuration, 0, DBL_MAX);
}

#pragma mark - animation

- (NSAttributedString *)attributedStringForProgress:(float)progress
{
    NSMutableAttributedString *attributedString = self.title.mutableCopy;
    
    __block NSUInteger idx = 0;
    __block NSString *val = nil;
    
    [self.title enumerateAttributesInRange: NSMakeRange(0, self.title.length)
                                   options: kNilOptions
                                usingBlock:^(NSDictionary* attrs, NSRange range, BOOL * stop) {
                                    
                                    if ((val = attrs[LRCircularProgressPlaceholderKey]))
                                    {
                                        idx = range.location + range.length;
                                        *stop = YES;
                                    }
                                }];
    
    if (idx != NSNotFound)
    {
        [attributedString insertAttributedString: [[NSAttributedString alloc] initWithString: [NSString stringWithFormat: (val != nil && val != (id) [NSNull null] ? val : @"%.0f"), progress * 100.f]]
                                         atIndex: idx];
    }
    
    return attributedString;
}

- (void)updatePlaceholderWithProgress:(float)progress
{
    _lastProgress = progress;

    self.titleLabel.attributedText = [self attributedStringForProgress: progress];
}

- (void)layerUpdateCallback:(NSNumber *)t
{
    [self updatePlaceholderWithProgress: t.floatValue];
}

- (CGSize)sizeThatFits:(CGSize)size
{
    CGSize t = [self.titleLabel sizeThatFits: size];
    
    CGFloat max = MAX(t.width, t.height);
    max += self.textInset * self.textInset;
    max = ceilf(sqrtf(ceilf(2.f * max * max)));
    max += self.progressTrackWidth * 2.f;
    max = MAX(30, max);
    
    return CGSizeMake(max, max);
}

- (CGSize)intrinsicContentSize
{
    return [self sizeThatFits: CGSizeZero];
}

#pragma mark - Layout

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat size = MIN(CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));

    self.containerLayer.frame = (CGRect) { .size = CGSizeMake(size, size) };
    self.containerLayer.position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    
    CGPoint center = CGPointMake(size / 2.f, size / 2.f);
    CGFloat radius = (size / 2.f - self.progressTrackWidth / 2.f);
    
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter: center radius: radius startAngle: - M_PI_2 endAngle: M_PI_2 * 3 clockwise: YES];
    
    self.trackLayer.path         = path.CGPath;
    self.tintLayer.path          = path.CGPath;
    self.remainderTintLayer.path = path.CGPath;

    CGFloat diameter = size - self.progressTrackWidth;
    CGFloat textWidth = ceilf(sqrtf((diameter * diameter) / 2.f));
    CGFloat inset = (CGRectGetWidth(self.containerLayer.bounds) - textWidth) / 2.;
    
    inset += self.textInset * 2.f;
    
    self.titleLabel.frame = CGRectInset(self.containerLayer.frame, inset, inset);
}

@end
