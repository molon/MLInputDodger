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
 *  The config of original y. When `registerAsDodgeViewForMLInputDodger`, if value of the property is 0, it's will be set with current y.
 */
@property (nonatomic, assign) CGFloat originalYAsDodgeViewForMLInputDodger;

/**
 *  the shift height as dodger
 */
@property (nonatomic, assign) CGFloat shiftHeightAsDodgeViewForMLInputDodger;

/**
 *  the shift height as first responder , higher priority
 */
@property (nonatomic, assign) CGFloat shiftHeightAsFirstResponderForMLInputDodger;

/**
 *  Dont use default retract view as dodger , higher priority
 */
@property (nonatomic, assign) BOOL dontUseDefaultRetractViewAsDodgeViewForMLInputDodger;

/**
 *  Dont use default retract view as first responder
 */
@property (nonatomic, assign) BOOL dontUseDefaultRetractViewAsFirstResponderForMLInputDodger;


/**
 *  animate alongside block after dodgerView's frame(or contentInset，contentOffset) changed
 *  this block will NOT override the `animateAlongsideBlock` of MLInputDodger!!!!
 *  but it will be overrided with the `animateAlongsideAsFirstResponderForMLInputDodgerBlock`
 */
@property (nonatomic, copy) void(^animateAlongsideAsDodgeViewForMLInputDodgerBlock)(BOOL show,UIView *dodgerView,UIView *firstResponderView,CGRect inputViewFrame);

/**
 *  animate alongside block after dodgerView's frame(or contentInset，contentOffset) changed
 *  this block will NOT override the `animateAlongsideBlock` of MLInputDodger!!!!
 *  but it will override the `animateAlongsideAsDodgeViewForMLInputDodgerBlock`, higher priority
 */
@property (nonatomic, copy) void(^animateAlongsideAsFirstResponderForMLInputDodgerBlock)(BOOL show,UIView *dodgerView,UIView *firstResponderView,CGRect inputViewFrame);

/**
 *  register as a dodger conveniently
 */
- (void)registerAsDodgeViewForMLInputDodger;

/**
 *  unregister conveniently
 */
- (void)unregisterAsDodgeViewForMLInputDodger;

@end
