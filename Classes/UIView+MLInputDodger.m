//
//  UIView+MLInputDodger.m
//  MLInputDodger
//
//  Created by molon on 15/7/27.
//  Copyright (c) 2015年 molon. All rights reserved.
//

#import "UIView+MLInputDodger.h"
#import "MLInputDodger.h"
#import <objc/runtime.h>

static char originalYAsDodgeViewForMLInputDodgerKey;

static char shiftHeightAsDodgeViewForMLInputDodgerKey;
static char shiftHeightAsFirstResponderForMLInputDodgerKey;

static char dontUseDefaultRetractViewAsDodgeViewForMLInputDodgerKey;
static char dontUseDefaultRetractViewAsFirstResponderForMLInputDodgerKey;

static char animateAlongsideAsDodgeViewForMLInputDodgerBlockKey;
static char animateAlongsideAsFirstResponderForMLInputDodgerBlockKey;

@implementation UIView (MLInputDodger)

- (BOOL)__MLInputDodger_hookBecomeFirstResponder
{
    if ([self canBecomeFirstResponder]) {
        [[MLInputDodger dodger] firstResponderViewChangeTo:self];
    }
    return [self __MLInputDodger_hookBecomeFirstResponder];
}

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Method originalMethod = class_getInstanceMethod(self, @selector(becomeFirstResponder));
        Method newMethod = class_getInstanceMethod(self, @selector(__MLInputDodger_hookBecomeFirstResponder));
        method_exchangeImplementations(originalMethod,newMethod);
    });
}

#pragma mark - getter and setter

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

- (BOOL)dontUseDefaultRetractViewAsDodgeViewForMLInputDodger
{
    return [objc_getAssociatedObject(self,&dontUseDefaultRetractViewAsDodgeViewForMLInputDodgerKey) boolValue];
}

- (void)setDontUseDefaultRetractViewAsDodgeViewForMLInputDodger:(BOOL)dontUseDefaultRetractViewAsDodgeViewForMLInputDodger
{
    static NSString * key = @"dontUseDefaultRetractViewAsDodgeViewForMLInputDodger";
    
    [self willChangeValueForKey:key];
    objc_setAssociatedObject(self, &dontUseDefaultRetractViewAsDodgeViewForMLInputDodgerKey, @(dontUseDefaultRetractViewAsDodgeViewForMLInputDodger), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self didChangeValueForKey:key];
}

- (BOOL)dontUseDefaultRetractViewAsFirstResponderForMLInputDodger
{
    return [objc_getAssociatedObject(self,&dontUseDefaultRetractViewAsFirstResponderForMLInputDodgerKey) boolValue];
}

- (void)setDontUseDefaultRetractViewAsFirstResponderForMLInputDodger:(BOOL)dontUseDefaultRetractViewAsFirstResponderForMLInputDodger
{
    static NSString * key = @"dontUseDefaultRetractViewAsFirstResponderForMLInputDodger";
    
    [self willChangeValueForKey:key];
    objc_setAssociatedObject(self, &dontUseDefaultRetractViewAsFirstResponderForMLInputDodgerKey, @(dontUseDefaultRetractViewAsFirstResponderForMLInputDodger), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self didChangeValueForKey:key];
}

-(void (^)(BOOL, UIView *, UIView *, CGRect))animateAlongsideAsDodgeViewForMLInputDodgerBlock
{
    return objc_getAssociatedObject(self,&animateAlongsideAsDodgeViewForMLInputDodgerBlockKey);
}

-(void)setAnimateAlongsideAsDodgeViewForMLInputDodgerBlock:(void (^)(BOOL, UIView *, UIView *, CGRect))animateAlongsideAsDodgeViewForMLInputDodgerBlock
{
    static NSString * key = @"animateAlongsideAsDodgeViewForMLInputDodgerBlock";
    
    [self willChangeValueForKey:key];
    objc_setAssociatedObject(self, &animateAlongsideAsDodgeViewForMLInputDodgerBlockKey, animateAlongsideAsDodgeViewForMLInputDodgerBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
    [self didChangeValueForKey:key];
}

-(void (^)(BOOL, UIView *, UIView *, CGRect))animateAlongsideAsFirstResponderForMLInputDodgerBlock
{
    return objc_getAssociatedObject(self,&animateAlongsideAsFirstResponderForMLInputDodgerBlockKey);
}

-(void)setAnimateAlongsideAsFirstResponderForMLInputDodgerBlock:(void (^)(BOOL, UIView *, UIView *, CGRect))animateAlongsideAsFirstResponderForMLInputDodgerBlock
{
    static NSString * key = @"animateAlongsideAsFirstResponderForMLInputDodgerBlock";
    
    [self willChangeValueForKey:key];
    objc_setAssociatedObject(self, &animateAlongsideAsFirstResponderForMLInputDodgerBlockKey, animateAlongsideAsFirstResponderForMLInputDodgerBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
    [self didChangeValueForKey:key];
}

#pragma mark - outcall
- (void)registerAsDodgeViewForMLInputDodgerWithOriginalY:(CGFloat)originalY
{
    self.originalYAsDodgeViewForMLInputDodger = originalY;

    [[MLInputDodger dodger]registerDodgeView:self];
}

- (void)unregisterAsDodgeViewForMLInputDodger
{
    [[MLInputDodger dodger]unregisterDodgeView:self];
}


@end
