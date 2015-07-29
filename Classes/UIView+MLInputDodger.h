//
//  UIView+MLInputDodger.h
//  MLInputDodger
//
//  Created by molon on 15/7/27.
//  Copyright (c) 2015年 molon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (MLInputDodger)

@property (nonatomic, assign) CGFloat shiftHeightAsDodgeViewForMLInputDodger;
@property (nonatomic, assign) CGFloat shiftHeightAsFirstResponderForMLInputDodger;

/**
 *  作为dodgeView时候的原Y位置，在registerAsDodgeView时候如果发现为0的话会设置此值为当前Y
 */
@property (nonatomic, assign) CGFloat originalYAsDodgeViewForMLInputDodger;

/**
 *  注册闪避View，即为需要根据输入状态改变位置的view
 */
- (void)registerAsDodgeViewForMLInputDodger;
/**
 *  此方法不一定非得和unregister成对出现，如果需要提前禁用闪避的时候使用
 */
- (void)unregisterAsDodgeViewForMLInputDodger;

@end
