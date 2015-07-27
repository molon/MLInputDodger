//
//  MLInputDodger.m
//  MLInputDodger
//
//  Created by molon on 15/7/27.
//  Copyright (c) 2015年 molon. All rights reserved.
//

#import "MLInputDodger.h"
#import <MLKit.h>

const double kInputViewAnimationDuration = .25f;

@interface MLInputDodger()

@property (nonatomic, weak) UIView *firstResponderView;

@property (nonatomic, strong) NSHashTable *dodgeViews;

//因为显示输入View关联的最后一个焦点view
@property (nonatomic, weak) UIView *lastFirstResponderViewForShowingInputView;
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
    self.inputViewAnimationCurve = [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    self.inputViewFrame = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    BOOL animated = YES;
    if ([self.lastFirstResponderViewForShowingInputView isEqual:self.firstResponderView]) {
        animated = NO;
    }
    
    self.lastFirstResponderViewForShowingInputView = self.firstResponderView;
    [self updateInputViewDetailWithKeyboardNotification:notification];
    
    
    [self doDodgeWithAnimated:animated];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    self.lastFirstResponderViewForShowingInputView = nil;
    [self updateInputViewDetailWithKeyboardNotification:notification];
    [self doDodgeWithAnimated:YES];
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
- (void)doDodgeWithAnimated:(BOOL)animated
{
    UIView *dodgeView = [self currentDodgeView];
    if (!dodgeView) {
        return;
    }
    
    CGFloat oldY = dodgeView.originalYAsDodgeViewForMLInputDodger;
    CGFloat newY = oldY;
    if (self.lastFirstResponderViewForShowingInputView) {
        CGFloat keyboardOrginY = self.inputViewFrame.origin.y;
        
        //找到必须要显示的位置
        CGFloat shiftHeight = self.firstResponderView.shiftHeightAsFirstResponderForMLInputDodger;
        if (shiftHeight==0) {
            shiftHeight = dodgeView.shiftHeightAsDodgeViewForMLInputDodger;
        }
        
        CGRect frameInWindow = [self.firstResponderView convertRect:self.firstResponderView.bounds toView:self.firstResponderView.window];
        
        CGFloat mustVisibleYForWindow = frameInWindow.origin.y+frameInWindow.size.height+shiftHeight;
        
        newY = MIN(oldY, keyboardOrginY - mustVisibleYForWindow + dodgeView.frameY);
        //保证不会往上移动过分了
        newY = MAX(newY, keyboardOrginY - dodgeView.frameHeight);
        //保证不会往下移动
        newY = MIN(newY, oldY);
        if (newY==0&& [FunctionCallerMessage()[@"Method"] isEqualToString:@"keyboardWillShow"]) {
            DLOG(@"异常");
        }
    }
    
    DLOG(@"doDodgeWithMustAnimated:%d, newY:%f",animated,newY);
    DLOG(@"%@",FunctionCallerMessage());
    
    if (animated) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:kInputViewAnimationDuration];
        [UIView setAnimationCurve:self.inputViewAnimationCurve];
        [UIView setAnimationBeginsFromCurrentState:YES];
        
        dodgeView.frameY = newY;
        
        [UIView commitAnimations];
    }else{
        dodgeView.frameY = newY;
    }
}

#pragma mark - outcall
- (void)firstResponderViewChangeTo:(UIView*)view
{
    if ([self.firstResponderView isEqual:view]) {
        return;
    }
    
    self.firstResponderView = view;
    if (self.lastFirstResponderViewForShowingInputView) {
        dispatch_async(dispatch_get_main_queue(), ^{
           //到下一个循环里，这时候检查是否当前因为keyboardWillShow事件已经处理了闪避，如果没这里就处理下
            //这种情况是由于当键盘类型和frame没改变的情况下，UIKeyboardWillShowNotification不会触发
            if (![self.lastFirstResponderViewForShowingInputView isEqual:self.firstResponderView]) {
                self.lastFirstResponderViewForShowingInputView = self.firstResponderView;
                [self doDodgeWithAnimated:YES];
            }
        });
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
