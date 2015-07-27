//
//  UIView+MLInputDodger.m
//  MLInputDodger
//
//  Created by molon on 15/7/27.
//  Copyright (c) 2015年 molon. All rights reserved.
//

#import "UIView+MLInputDodger.h"
#import <MLKit.h>
#import "MLInputDodger.h"
#import <objc/runtime.h>

static char shiftHeightAsDodgeViewForMLInputDodgerKey;
static char shiftHeightAsFirstResponderForMLInputDodgerKey;
static char originalYAsDodgeViewForMLInputDodgerKey;

@implementation UIView (MLInputDodger)

- (BOOL)hook_becomeFirstResponder
{
    if ([self canBecomeFirstResponder]) {
        [[MLInputDodger dodger] firstResponderViewChangeTo:self];
    }
    
    return [self hook_becomeFirstResponder];
}

+ (void)load
{
    Swizzle([self class], @selector(becomeFirstResponder), @selector(hook_becomeFirstResponder));
}

- (CGFloat)shiftHeightAsDodgeViewForMLInputDodger
{
    return [objc_getAssociatedObject(self,&shiftHeightAsDodgeViewForMLInputDodgerKey) doubleValue];
}

- (void)setShiftHeightAsDodgeViewForMLInputDodger:(CGFloat)shiftHeightAsDodgeViewForMLInputDodger
{
    static NSString * key = @"shiftHeightAsDodgeViewForMLInputDodger";
    
    [self willChangeValueForKey:key];
    objc_setAssociatedObject(self, &shiftHeightAsDodgeViewForMLInputDodgerKey, @(shiftHeightAsDodgeViewForMLInputDodger), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self didChangeValueForKey:key];
}

- (CGFloat)shiftHeightAsFirstResponderForMLInputDodger
{
    return [objc_getAssociatedObject(self,&shiftHeightAsFirstResponderForMLInputDodgerKey) doubleValue];
}

- (void)setShiftHeightAsFirstResponderForMLInputDodger:(CGFloat)shiftHeightAsFirstResponderForMLInputDodger
{
    static NSString * key = @"shiftHeightAsFirstResponderForMLInputDodger";
    
    [self willChangeValueForKey:key];
    objc_setAssociatedObject(self, &shiftHeightAsFirstResponderForMLInputDodgerKey, @(shiftHeightAsFirstResponderForMLInputDodger), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self didChangeValueForKey:key];
}

- (CGFloat)originalYAsDodgeViewForMLInputDodger
{
    return [objc_getAssociatedObject(self,&originalYAsDodgeViewForMLInputDodgerKey) doubleValue];
}

- (void)setOriginalYAsDodgeViewForMLInputDodger:(CGFloat)originalYAsDodgeViewForMLInputDodger
{
    
    static NSString * key = @"originalYAsDodgeViewForMLInputDodger";
    
    [self willChangeValueForKey:key];
    objc_setAssociatedObject(self, &originalYAsDodgeViewForMLInputDodgerKey, @(originalYAsDodgeViewForMLInputDodger), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self didChangeValueForKey:key];
}

#pragma mark - outcall
- (void)registerAsDodgeViewForMLInputDodger
{
    self.originalYAsDodgeViewForMLInputDodger = self.frameY;
    [[MLInputDodger dodger]registerDodgeView:self];
}

- (void)unregisterAsDodgeViewForMLInputDodger
{
    [[MLInputDodger dodger]unregisterDodgeView:self];
}


@end
