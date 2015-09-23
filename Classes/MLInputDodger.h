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
 *  check view is a dodger
 */
- (BOOL)isRegisteredForDodgeView:(UIView*)dodgeView;

/**
 *  register as a dodger
 */
- (void)registerDodgeView:(UIView*)dodgeView;

/**
 *  unregister, do not need to appear in pairs with `registerDodgeView:`
 */
- (void)unregisterDodgeView:(UIView*)dodgeView;

/**
 *  change the first responder view
 */
- (void)firstResponderViewChangeTo:(UIView*)view;

@end
