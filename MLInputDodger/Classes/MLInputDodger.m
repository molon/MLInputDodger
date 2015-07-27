//
//  MLInputDodger.m
//  MLInputDodger
//
//  Created by molon on 15/7/27.
//  Copyright (c) 2015年 molon. All rights reserved.
//

#import "MLInputDodger.h"
#import <MLKit.h>

@interface MLInputDodger()

@property (nonatomic, weak) UIView *firstResponderView;

@property (nonatomic, strong) NSHashTable *dodgeViews;

@property (nonatomic, assign) BOOL isInputViewShowing;
@property (nonatomic, assign) double inputViewAnimationDuration;
@property (nonatomic, assign) CGRect inputViewFrame;
@property (nonatomic, assign) NSInteger inputViewAnimationCurve;

@end

@implementation MLInputDodger

+ (instancetype)dodger
{
    static id _dodger = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _dodger = [[[self class] alloc] init];
    });
    
    return _dodger;
}


#pragma mark - life cycle
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.inputViewAnimationDuration = .25f;
        self.inputViewAnimationCurve = 7;
        
        //add observer
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillShow:)
                                                     name:UIKeyboardWillShowNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillHide:)
                                                     name:UIKeyboardWillHideNotification
                                                   object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - getter
- (NSHashTable *)dodgeViews
{
    if (!_dodgeViews) {
        _dodgeViews = [NSHashTable weakObjectsHashTable];
    }
    return _dodgeViews;
}

#pragma mark - notification
- (void)updateInputViewDetailWithKeyboardNotification:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    self.inputViewAnimationDuration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    self.inputViewAnimationCurve = [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    self.inputViewFrame = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    self.isInputViewShowing = YES;
    [self updateInputViewDetailWithKeyboardNotification:notification];
    [self doDodgeWithMustAnimated:NO];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    self.isInputViewShowing = NO;
    [self updateInputViewDetailWithKeyboardNotification:notification];
    [self doDodgeWithMustAnimated:NO];
}


#pragma mark - helper
//根据当前的firstResponder找到对应的闪避view
- (UIView*)currentDodgeView
{
    if (!self.firstResponderView) {
        return nil;
    }
    
    UIView *superView= self.firstResponderView;
    while (superView) {
        if ([self.dodgeViews containsObject:superView]) {
            return superView;
        }
        superView = [superView superview];
    }
    return nil;
}

/**
 *  执行闪避和恢复
 */
- (void)doDodgeWithMustAnimated:(BOOL)mustAnimated
{
    DLOG(@"doDodgeWithMustAnimated:%d",mustAnimated);
    DLOG(@"%@",FunctionCallerMessage());
    
    UIView *dodgeView = [self currentDodgeView];
    if (!dodgeView) {
        return;
    }
    
    double duration = self.inputViewAnimationDuration;
    
    
    CGFloat oldY = dodgeView.originalYAsDodgeViewForMLInputDodger;
    CGFloat newY = oldY;
    if (self.isInputViewShowing) {
        CGFloat keyboardOrginY = self.inputViewFrame.origin.y;
        
        //找到必须要显示的位置
        CGFloat shiftHeight = self.firstResponderView.shiftHeightAsFirstResponderForMLInputDodger;
        if (shiftHeight==0) {
            shiftHeight = dodgeView.shiftHeightAsDodgeViewForMLInputDodger;
        }
        
        CGFloat mustVisibleYForWindow = [self.firstResponderView convertPoint:CGPointMake(0, self.firstResponderView.frame.size.height) toView:nil].y+shiftHeight;
        
        newY = MIN(oldY, keyboardOrginY - mustVisibleYForWindow + dodgeView.frameY);
        //保证不会往上移动过分了
        newY = MAX(newY, keyboardOrginY - dodgeView.frameHeight);
        //保证不会往下移动
        newY = MIN(newY, oldY);
    }
    
    if (!mustAnimated&&duration==0) {
        //这种时候不需要动画，否则效果会很差
        dodgeView.frameY = newY;
        return;
    }
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:duration];
    [UIView setAnimationCurve:self.inputViewAnimationCurve];
    [UIView setAnimationBeginsFromCurrentState:YES];
    
    dodgeView.frameY = newY;
    
    [UIView commitAnimations];
}

#pragma mark - outcall
- (void)firstResponderViewChangeTo:(UIView*)view
{
    if ([self.firstResponderView isEqual:view]) {
        return;
    }
    
    self.firstResponderView = view;
    if (self.isInputViewShowing) {
#warning 到这里的话不一定不会执行keyWillShow事件，也有可能执行，我们需要搞一搞，例如切换焦点的时候键盘也有改变
        [self doDodgeWithMustAnimated:YES];
    }
}


- (void)registerDodgeView:(UIView*)dodgeView
{
    if (![self.dodgeViews containsObject:dodgeView]) {
        [self.dodgeViews addObject:dodgeView];
    }
}

- (void)unregisterDodgeView:(UIView*)dodgeView
{
    [self.dodgeViews removeObject:dodgeView];
}

@end
