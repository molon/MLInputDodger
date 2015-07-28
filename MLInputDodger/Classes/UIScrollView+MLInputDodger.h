//
//  UIScrollView+MLInputDodger.h
//  MLInputDodger
//
//  Created by molon on 15/7/28.
//  Copyright (c) 2015年 molon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIScrollView (MLInputDodger)

/**
 *  作为dodgeView时候的原contentInset位置，在registerAsDodgeView时候如果发现此值为Zero的话会设置此值为当前的
 */
@property (nonatomic, assign) UIEdgeInsets originalContentInsetAsDodgeViewForMLInputDodger;

@end
