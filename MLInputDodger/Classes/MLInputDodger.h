//
//  MLInputDodger.h
//  MLInputDodger
//
//  Created by molon on 15/7/27.
//  Copyright (c) 2015年 molon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIView+MLInputDodger.h"
#import "UIScrollView+MLInputDodger.h"

@interface MLInputDodger : NSObject

+ (instancetype)dodger;

@property (readonly, nonatomic, weak) UIView *firstResponderView;

/**
 *  注册闪避View，即为需要根据输入状态改变位置的view
 */
- (void)registerDodgeView:(UIView*)dodgeView;
/**
 *  此方法不一定非得和unregister成对出现，如果需要提前禁用闪避的时候使用
 */
- (void)unregisterDodgeView:(UIView*)dodgeView;


/**
 *  这个无需关心
 */
- (void)firstResponderViewChangeTo:(UIView*)view;

@end
