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
 *  The config of original contentInset. When `registerAsDodgeViewForMLInputDodger`, if value of the property is `UIEdgeInsetsZero`, it's will be set with current contentInset
 */
@property (nonatomic, assign) UIEdgeInsets originalContentInsetAsDodgeViewForMLInputDodger;

@end
