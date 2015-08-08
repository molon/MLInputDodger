//
//  MLInputDodger.m
//  MLInputDodger
//
//  Created by molon on 15/7/27.
//  Copyright (c) 2015年 molon. All rights reserved.
//

#import "MLInputDodger.h"
#import "MLInputDodgerRetractView.h"

#define CHILD(childClass,object) \
((childClass *)object) \
\

const double kInputViewAnimationDuration = .25f;

@interface MLInputDodger()

@property (nonatomic, weak) UIView *firstResponderView;

@property (nonatomic, strong) NSHashTable *dodgeViews;

//因为显示输入View关联的最后一个焦点view
@property (nonatomic, weak) UIView *lastFirstResponderViewForShowingInputView;
@property (nonatomic, assign) CGRect inputViewFrame;
@property (nonatomic, assign) NSInteger inputViewAnimationCurve;

@property (nonatomic, strong) MLInputDodgerRetractView *retractInputAccessoryView;

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

- (MLInputDodgerRetractView *)retractInputAccessoryView
{
    if (!_retractInputAccessoryView) {
        _retractInputAccessoryView = [MLInputDodgerRetractView new];
        __weak __typeof(self)weakSelf = self;
        [_retractInputAccessoryView setDidClickRetractButtonBlock:^{
            __strong __typeof(weakSelf)sSelf = weakSelf;
            [sSelf.firstResponderView resignFirstResponder];
        }];
    }
    return _retractInputAccessoryView;
}

#pragma mark - setter
- (void)setFirstResponderView:(UIView *)firstResponderView
{
    if ([_firstResponderView.inputAccessoryView isEqual:self.retractInputAccessoryView]) {
        [_firstResponderView performSelector:@selector(setInputAccessoryView:) withObject:nil];
    }
    
    _firstResponderView = firstResponderView;
    
    if (!firstResponderView.inputAccessoryView) {
        UIView *dodgeView = [self currentDodgeView];
        if (dodgeView) {
            self.retractInputAccessoryView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, kMLInputDodgerRetractViewDefaultHeight);
            [firstResponderView performSelector:@selector(setInputAccessoryView:) withObject:self.retractInputAccessoryView];
        }
    }
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

- (void)doDodgeWithAnimated:(BOOL)animated dodgeScrollView:(UIScrollView*)dodgeView
{
    if (!dodgeView) {
        return;
    }
    
    void(^dodgeBlock)(UIEdgeInsets,CGPoint,BOOL) = ^(UIEdgeInsets inset,CGPoint offset,BOOL forHide){
        if (animated) {
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:kInputViewAnimationDuration];
            [UIView setAnimationCurve:self.inputViewAnimationCurve];
            [UIView setAnimationBeginsFromCurrentState:YES];
            
            dodgeView.contentInset = inset;
            if (!forHide){
                [dodgeView setContentOffset:offset animated:NO];
            }
            
            [UIView commitAnimations];
        }else{
            dodgeView.contentInset = inset;
            if (!forHide){
                [dodgeView setContentOffset:offset animated:NO];
            }
        }
    };

    
    UIEdgeInsets inset = dodgeView.originalContentInsetAsDodgeViewForMLInputDodger;
    CGPoint offset = dodgeView.contentOffset;
    
    //对于UIScrollView的话，我们不修改其frame，只修改其contentInset和offset吧。
    if (self.lastFirstResponderViewForShowingInputView) {
        CGFloat keyboardOrginY = self.inputViewFrame.origin.y;
        //如果inputAccessoryView是我们的收起键盘的按钮就忽略它的高度
        if ([self.firstResponderView.inputAccessoryView isEqual:self.retractInputAccessoryView]) {
            keyboardOrginY+= CGRectGetHeight(self.retractInputAccessoryView.frame);
        }
        
        //找到必须要显示的位置
        CGFloat shiftHeight = self.firstResponderView.shiftHeightAsFirstResponderForMLInputDodger;
        if (shiftHeight==0) {
            shiftHeight = dodgeView.shiftHeightAsDodgeViewForMLInputDodger;
        }
        
        CGRect frameInDodgeView = [self.firstResponderView convertRect:self.firstResponderView.bounds toView:dodgeView];
        
        CGRect dodgeViewFrameInWindow = [dodgeView.superview convertRect:dodgeView.frame toView:dodgeView.window];
        CGFloat dodgeViewFrameBottomInWindow = CGRectGetMaxY(dodgeViewFrameInWindow);
        
        inset.bottom += MAX(0,dodgeViewFrameBottomInWindow-keyboardOrginY);
        
        CGFloat mustDisplayHeight = CGRectGetHeight(self.firstResponderView.frame)+shiftHeight;
        NSAssert(CGRectGetHeight(dodgeViewFrameInWindow)>=mustDisplayHeight+inset.top, @"对应的dodgeScrollView的高度不可太小或者shiftHeight太大");
        NSAssert(keyboardOrginY-dodgeViewFrameInWindow.origin.y>=mustDisplayHeight+inset.top, @"对应的dodgeScrollView的Y位置太低或者shiftHeight太大");
        
        offset.y = frameInDodgeView.origin.y-inset.top-(MIN(keyboardOrginY,dodgeViewFrameBottomInWindow)-dodgeViewFrameInWindow.origin.y-mustDisplayHeight-inset.top);
        offset.y = MIN(offset.y, dodgeView.contentSize.height-CGRectGetHeight(dodgeViewFrameInWindow)+inset.bottom);
        offset.y = MAX(offset.y, -inset.top);
        
        id nextResponder = [dodgeView nextResponder];
#warning 在iOS8下 左边当前是数字键盘，然后右边以文字键盘返回的话会出问题，直接返回的话会发现位置不对，交互返回的话键盘会消失了, 还需要研究，真机没测
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            //这个是为了解决导航器pop后 viewController.view 的frame会被transition重置
            if ([CHILD(UIViewController, nextResponder).transitionCoordinator isAnimated]){
                [CHILD(UIViewController, nextResponder).transitionCoordinator animateAlongsideTransition:nil completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
                    dodgeBlock(inset,offset,self.lastFirstResponderViewForShowingInputView==nil);
                }];
                return;
            }
        }
    }
    
    dodgeBlock(inset,offset,self.lastFirstResponderViewForShowingInputView==nil);
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
    
    if ([dodgeView isKindOfClass:[UIScrollView class]]) {
        [self doDodgeWithAnimated:animated dodgeScrollView:CHILD(UIScrollView, dodgeView)];
        return;
    }
    
    void(^dodgeBlock)(CGFloat) = ^(CGFloat completeY){
        CGRect frame = dodgeView.frame;
        frame.origin.y = completeY;
        if (animated) {
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:kInputViewAnimationDuration];
            [UIView setAnimationCurve:self.inputViewAnimationCurve];
            [UIView setAnimationBeginsFromCurrentState:YES];
            
            dodgeView.frame = frame;
            
            [UIView commitAnimations];
        }else{
            dodgeView.frame = frame;
        }
    };
    
    
    CGFloat oldY = dodgeView.originalYAsDodgeViewForMLInputDodger;
    CGFloat newY = oldY;
    if (self.lastFirstResponderViewForShowingInputView) {
        CGFloat keyboardOrginY = self.inputViewFrame.origin.y;
        //如果inputAccessoryView是我们的收起键盘的按钮就忽略它的高度
        if ([self.firstResponderView.inputAccessoryView isEqual:self.retractInputAccessoryView]) {
            keyboardOrginY+= CGRectGetHeight(self.retractInputAccessoryView.frame);
        }
        
        //找到必须要显示的位置
        CGFloat shiftHeight = self.firstResponderView.shiftHeightAsFirstResponderForMLInputDodger;
        if (shiftHeight==0) {
            shiftHeight = dodgeView.shiftHeightAsDodgeViewForMLInputDodger;
        }
        
        CGRect frameInWindow = [self.firstResponderView convertRect:self.firstResponderView.bounds toView:self.firstResponderView.window];
        
        CGFloat mustVisibleYForWindow = frameInWindow.origin.y+frameInWindow.size.height+shiftHeight;
        
        newY = MIN(oldY, keyboardOrginY - mustVisibleYForWindow + dodgeView.frame.origin.y);
        //保证不会往上移动过分了，也就是尽量键盘和dodgeView的底部之间没缝隙
        newY = MAX(newY, keyboardOrginY - CGRectGetHeight(dodgeView.frame));
        //保证不会往下移动，在以上的处理后，这是最终需要考虑的。
        newY = MIN(newY, oldY);
        
        id nextResponder = [dodgeView nextResponder];
#warning 在iOS8下 左边当前是数字键盘，然后右边以文字键盘返回的话会出问题，直接返回的话会发现位置不对，交互返回的话键盘会消失了, 还需要研究，真机没测
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            //这个是为了解决导航器pop后 viewController.view 的frame会被transition重置
            if ([CHILD(UIViewController, nextResponder).transitionCoordinator isAnimated]){
                [CHILD(UIViewController, nextResponder).transitionCoordinator animateAlongsideTransition:nil completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
                    dodgeBlock(newY);
                }];
                return;
            }
        }
    }
    
    dodgeBlock(newY);
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
    if (![self isRegisteredForDodgeView:dodgeView]) {
        [self.dodgeViews addObject:dodgeView];
    }
}

- (void)unregisterDodgeView:(UIView*)dodgeView
{
    [self.dodgeViews removeObject:dodgeView];
}

- (BOOL)isRegisteredForDodgeView:(UIView*)dodgeView
{
    return [self.dodgeViews containsObject:dodgeView];
}
@end
