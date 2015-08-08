//
//  UIScrollView+MLInputDodger.m
//  MLInputDodger
//
//  Created by molon on 15/7/28.
//  Copyright (c) 2015年 molon. All rights reserved.
//

#import "UIScrollView+MLInputDodger.h"
#import <objc/runtime.h>
#import "UIView+MLInputDodger.h"
#import "MLInputDodger.h"

static char originalContentInsetAsDodgeViewForMLInputDodgerKey;

@implementation UIScrollView (MLInputDodger)

- (UIEdgeInsets)originalContentInsetAsDodgeViewForMLInputDodger
{
    return [objc_getAssociatedObject(self,&originalContentInsetAsDodgeViewForMLInputDodgerKey) UIEdgeInsetsValue];
}

- (void)setOriginalContentInsetAsDodgeViewForMLInputDodger:(UIEdgeInsets)originalContentInsetAsDodgeViewForMLInputDodger
{
    static NSString * key = @"originalContentInsetAsDodgeViewForMLInputDodger";
    
    [self willChangeValueForKey:key];
    objc_setAssociatedObject(self, &originalContentInsetAsDodgeViewForMLInputDodgerKey, [NSValue valueWithUIEdgeInsets:originalContentInsetAsDodgeViewForMLInputDodger], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self didChangeValueForKey:key];
}

- (void)registerAsDodgeViewForMLInputDodger
{
    if (![[MLInputDodger dodger] isRegisteredForDodgeView:self]) {
        if (UIEdgeInsetsEqualToEdgeInsets(UIEdgeInsetsZero, self.originalContentInsetAsDodgeViewForMLInputDodger)) {
            self.originalContentInsetAsDodgeViewForMLInputDodger = self.contentInset;
        }
    }
    [super registerAsDodgeViewForMLInputDodger];
}

@end
