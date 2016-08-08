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
 *  The original contentInset of dodge view
 */
@property (nonatomic, assign) UIEdgeInsets originalContentInsetAsDodgeViewForMLInputDodger;

/**
 register as a dodger with original contentInset
 
 @param originalContentInset the original contentInset of dodge view
 */
- (void)registerAsDodgeViewForMLInputDodgerWithOriginalContentInset:(UIEdgeInsets)originalContentInset;

@end
