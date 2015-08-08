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

static char shiftHeightAsDodgeViewForMLInputDodgerKey;
static char shiftHeightAsFirstResponderForMLInputDodgerKey;
static char originalYAsDodgeViewForMLInputDodgerKey;

//静态就交换静态，实例方法就交换实例方法
void MLInputDodger_Swizzle(Class c, SEL origSEL, SEL newSEL)
{
    //获取实例方法
    Method origMethod = class_getInstanceMethod(c, origSEL);
    Method newMethod = nil;
    if (!origMethod) {
        //获取静态方法
        origMethod = class_getClassMethod(c, origSEL);
        newMethod = class_getClassMethod(c, newSEL);
    }else{
        newMethod = class_getInstanceMethod(c, newSEL);
    }
    
    if (!origMethod||!newMethod) {
        return;
    }
    
    //自身已经有了就添加不成功，直接交换即可
    if(class_addMethod(c, origSEL, method_getImplementation(newMethod), method_getTypeEncoding(newMethod))){
        //添加成功一般情况是因为，origSEL本身是在c的父类里。这里添加成功了一个继承方法。
        class_replaceMethod(c, newSEL, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
    }else{
        method_exchangeImplementations(origMethod, newMethod);
    }
}

@implementation UIView (MLInputDodger)

- (BOOL)__MLInputDodger_hook_becomeFirstResponder
{
    if ([self canBecomeFirstResponder]) {
        [[MLInputDodger dodger] firstResponderViewChangeTo:self];
    }
    
    return [self __MLInputDodger_hook_becomeFirstResponder];
}

+ (void)load
{
    MLInputDodger_Swizzle([self class], @selector(becomeFirstResponder), @selector(__MLInputDodger_hook_becomeFirstResponder));
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
    if (![[MLInputDodger dodger] isRegisteredForDodgeView:self]) {
        if (self.originalYAsDodgeViewForMLInputDodger==0) {
            self.originalYAsDodgeViewForMLInputDodger = self.frame.origin.y;
        }
    }
    [[MLInputDodger dodger]registerDodgeView:self];
}

- (void)unregisterAsDodgeViewForMLInputDodger
{
    [[MLInputDodger dodger]unregisterDodgeView:self];
}


@end
