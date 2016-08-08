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
 *  The original origin.y of dodge view
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
 register as a dodger with original origin.y
 
 @param originalY the original origin.y of dodge view
 */
- (void)registerAsDodgeViewForMLInputDodgerWithOriginalY:(CGFloat)originalY;

/**
 *  unregister conveniently, do not need to appear in pairs with `registerAsDodgeViewForMLInputDodger...:`
 */
- (void)unregisterAsDodgeViewForMLInputDodger;

@end
