//
//  VPSlider.m
//  VPhoenix
//
//  Created by 韩元旭 on 2020/10/27.
//  Copyright © 2020 Yueranzhishang Technology. All rights reserved.
//

#import "VPSlider.h"

@interface VPSlider () <UIGestureRecognizerDelegate>
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
@property (nonatomic, assign) VPSliderType type;
@end

@implementation VPSlider

#pragma mark - Initailize

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame type:VPSliderTypeSingleEnded];
}

- (instancetype)initWithFrame:(CGRect)frame type:(VPSliderType)type {
    self = [super initWithFrame:frame];
    if (self) {
        self.type = type;
        [self commonInit];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapAction:)];
        tap.delegate = self;
        [self addGestureRecognizer:tap];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    if (self.type == VPSliderTypeDoubleEnded) {
        self.maximumTrackTintColor = UIColor.clearColor;
        self.minimumTrackTintColor = UIColor.clearColor;
        CGFloat sliderWidth = self.bounds.size.width;
        CGFloat sliderHeight = self.bounds.size.height;
        if (sliderWidth == 0 || sliderHeight == 0) {
#if VP_DEBUG
            VPLogInfo(@"😜sliderWidth and sliderHeight shouldn't be zero.");
#endif
            self.maximumTrackTintColor = UIColor.blueColor;
            self.minimumTrackTintColor = UIColor.redColor;
            [self setThumbImage:[UIImage imageNamed:@"icon_slider_control"] forState:UIControlStateNormal];
            return;
        }
        CGFloat height = 2;
        self.minimumValueImage = [VPSlider drawLineImageWithColor:UIColor.redColor size:CGSizeMake(sliderWidth, height)];
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, (sliderHeight - height) / 2, sliderWidth, height)];
        lineView.backgroundColor = UIColor.blueColor;
        [self insertSubview:lineView atIndex:0];
        UIView *dotView = [[UIView alloc] initWithFrame:CGRectMake(sliderWidth / 2 - 3, (sliderHeight - 6) * 0.5, 6, 6)];
        dotView.layer.cornerRadius = dotView.bounds.size.width / 2;
        dotView.backgroundColor = UIColor.redColor;
        [self insertSubview:dotView atIndex:1];
    } else {
        self.maximumTrackTintColor = UIColor.blueColor;
        self.minimumTrackTintColor = UIColor.redColor;
    }
    [self setThumbImage:[UIImage imageNamed:@"icon_slider_control"] forState:UIControlStateNormal];
}
#pragma mark - utlity

+ (UIImage *)drawLineImageWithColor:(UIColor *)color size:(CGSize)size {
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, 0, 0);
    CGPathAddLineToPoint(path, NULL, size.width, 0);
    [UIColor.redColor setStroke];
    CGContextSetLineWidth(context, size.height * UIScreen.mainScreen.scale);
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextAddPath(context, path);
    CGContextStrokePath(context);
    UIImage *lineImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return lineImage;
}

#pragma mark - Actions

- (void)handleTapAction:(UITapGestureRecognizer *)tap {
    
//    if(@available(iOS 12.0, *)){
//
//        CGFloat width = self.frame.size.width;
//        CGPoint tapPoint= [tap locationInView:self];
//        float fPercent = tapPoint.x / width;
//        int nNewValue = (self.maximumValue - self.minimumValue) * fPercent + 0.5 + self.minimumValue;
//        if (nNewValue != self.value) {
//            self.value = nNewValue;
//            [self sendActionsForControlEvents:UIControlEventTouchUpInside];
//        }
//    } else {
        CGPoint point = [tap locationInView:self];
        CGFloat value = point.x / self.frame.size.width;
        value = MAX(0, MIN(value, 1.0));
        value = round(value * 100 / 5) * 5 / 100; // 点击时. 将精度控制在5的一个级别
        // 这时value为0～1的范围，转换一下
        value = value * (self.maximumValue - self.minimumValue) + self.minimumValue;
        if (self.value != value) {
            self.value = value;
            [self sendActionsForControlEvents:UIControlEventTouchUpInside];
        }
   // }
}

#pragma mark - UIGestureRecognizerDelegate

//- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
//    if (gestureRecognizer != self.tapGesture) {
//        return YES;
//    }
//
//    // TODO: 判断点击拖拽条就不响应
//}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    return CGRectContainsPoint(CGRectInset(self.bounds, -10, -5), point);
}

#pragma mark - Override

- (CGRect)trackRectForBounds:(CGRect)bounds {
    const CGFloat padding = 0;
    const CGFloat height = 2;
    return CGRectMake(padding, (self.frame.size.height - height) * 0.5, self.frame.size.width - padding * 2, height);
}

- (CGRect)thumbRectForBounds:(CGRect)bounds trackRect:(CGRect)rect value:(float)value {
    static CGFloat const padding = 5;
    rect.origin.x = rect.origin.x - padding;
    rect.size.width = rect.size.width + padding * 2;
    CGRect thumbRect = CGRectInset([super thumbRectForBounds:bounds trackRect:rect value:value], padding , padding);
    if (thumbRect.origin.x < - padding / 2) {
        thumbRect.origin.x = - padding / 2;
    }
    return thumbRect;
}

- (CGRect)minimumValueImageRectForBounds:(CGRect)bounds {
    CGRect rect = [super minimumValueImageRectForBounds:bounds];
    if (self.minimumValue < 0 && self.type == VPSliderTypeDoubleEnded) {
        CGFloat width = (rect.size.width / 2) * fabsf(self.value / 100);
        if (self.value > 0) {
            rect.origin.x = rect.size.width / 2;
            
        } else {
            rect.origin.x = rect.size.width / 2 - width;
        }
        rect.size.width = width;
    }
    return rect;
}

// 解决iOS 12滑动条回弹的问题
//- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
//
//    if(@available(iOS 12.0, *)){
//
//        CGFloat width = self.frame.size.width;
//        CGPoint tapPoint= [touch locationInView:self];
//        float fPercent = tapPoint.x / width;
//        int nNewValue = (self.maximumValue - self.minimumValue) * fPercent + 0.5 + self.minimumValue;
//
//        if (nNewValue != self.value) {
//            self.value = nNewValue;
//        }
//
//    }
//    return YES;
//
//}


@end
