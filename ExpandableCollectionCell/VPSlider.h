//
//  VPSlider.h
//  VPhoenix
//
//  Created by 韩元旭 on 2020/10/27.
//  Copyright © 2020 Yueranzhishang Technology. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, VPSliderType) {
    VPSliderTypeSingleEnded, // 单端样式
    VPSliderTypeDoubleEnded,
};

@interface VPSlider : UISlider

- (instancetype)initWithFrame:(CGRect)frame type:(VPSliderType)type;

@end

NS_ASSUME_NONNULL_END
