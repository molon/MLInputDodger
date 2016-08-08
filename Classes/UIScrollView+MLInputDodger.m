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

- (CGFloat)originalYAsDodgeViewForMLInputDodger
{
    NSAssert(NO, @"`originalYAsDodgeViewForMLInputDodger` cannot be used for %@",NSStringFromClass([self class]));
    return [super originalYAsDodgeViewForMLInputDodger];
}

- (void)setOriginalYAsDodgeViewForMLInputDodger:(CGFloat)originalYAsDodgeViewForMLInputDodger
{
    NSAssert(NO, @"`setOriginalYAsDodgeViewForMLInputDodger:` cannot be used for %@",NSStringFromClass([self class]));
    [super setOriginalYAsDodgeViewForMLInputDodger:originalYAsDodgeViewForMLInputDodger];
}

- (void)registerAsDodgeViewForMLInputDodgerWithOriginalY:(CGFloat)originalY
{
    NSAssert(NO, @"`registerAsDodgeViewForMLInputDodgerWithOriginalY:` cannot be used for %@",NSStringFromClass([self class]));
    [super registerAsDodgeViewForMLInputDodgerWithOriginalY:originalY];
}

- (void)registerAsDodgeViewForMLInputDodgerWithOriginalContentInset:(UIEdgeInsets)originalContentInset
{
    self.originalContentInsetAsDodgeViewForMLInputDodger = originalContentInset;
    
    [[MLInputDodger dodger]registerDodgeView:self];
}

@end
