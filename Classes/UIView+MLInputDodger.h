//
//  UIView+MLInputDodger.h
//  MLInputDodger
//
//  Created by molon on 15/7/27.
//  Copyright (c) 2015年 molon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (MLInputDodger)

/**
 *  the shift height as dodger
 */
@property (nonatomic, assign) CGFloat shiftHeightAsDodgeViewForMLInputDodger;

/**
 *  the shift height as first responder , higher priority
 */
@property (nonatomic, assign) CGFloat shiftHeightAsFirstResponderForMLInputDodger;

/**
 *  The config of original y. When `registerAsDodgeViewForMLInputDodger`, if value of the property is 0, it's will be set with current y.
 */
@property (nonatomic, assign) CGFloat originalYAsDodgeViewForMLInputDodger;

/**
 *  register as a dodger conveniently
 */
- (void)registerAsDodgeViewForMLInputDodger;

/**
 *  unregister conveniently
 */
- (void)unregisterAsDodgeViewForMLInputDodger;

@end
