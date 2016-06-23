//
//  MLInputDodger.m
//  MLInputDodger
//
//  Created by molon on 15/7/27.
//  Copyright (c) 2015年 molon. All rights reserved.
//

#import "MLInputDodger.h"

#define CHILD(childClass,object) \
((childClass *)object) \
\

@interface MLInputDodger()

/**
 *  Current first responder view
 */
@property (nonatomic, weak) UIView *firstResponderView;

/**
 *  Views can be dodged
 */
@property (nonatomic, strong) NSHashTable *dodgeViews;

/**
 *  First responder view record because the last show of input view(keyboard)
 */
@property (nonatomic, weak) UIView *lastFirstResponderViewForShowInputView;
@property (nonatomic, assign) CGRect inputViewFrame;
@property (nonatomic, assign) NSInteger inputViewAnimationCurve;
@property (nonatomic, assign) NSTimeInterval inputViewAnimationDuration;

/**
 *  Common input accessory view who can hide input view
 */
@property (nonatomic, strong) MLInputDodgerRetractView *retractInputAccessoryView;

@end

@implementation MLInputDodger

+ (instancetype)dodger
{
    static id _dodger = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
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
        self.inputViewAnimationDuration = .25f;
        
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
    //remove the common input accessory view who can hide input view
    if ([_firstResponderView.inputAccessoryView isEqual:self.retractInputAccessoryView]) {
        [_firstResponderView performSelector:@selector(setInputAccessoryView:) withObject:nil];
    }
    
    _firstResponderView = firstResponderView;
    
    //if no, add the common input accessory view who can hide input view
    if (!firstResponderView.inputAccessoryView) {
        if (firstResponderView.dontUseDefaultRetractViewAsFirstResponderForMLInputDodger) {
            return;
        }
        
        //for textview especially
        if ([firstResponderView isKindOfClass:[UITextView class]]&&!((UITextView*)firstResponderView).editable) {
            return;
        }
        
        UIView *dodgeView = [self currentDodgeView];
        if (dodgeView&&!dodgeView.dontUseDefaultRetractViewAsDodgeViewForMLInputDodger) {
            self.retractInputAccessoryView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, kMLInputDodgerRetractViewDefaultHeight);
            [firstResponderView performSelector:@selector(setInputAccessoryView:) withObject:self.retractInputAccessoryView];
        }
    }
}

#pragma mark - outcall
- (void)firstResponderViewChangeTo:(UIView*)view
{
    NSAssert(view, @"firstResponderView cannot be changed to nil");
    
    //some view（like UIActionSheet in iOS7, webView）can become first responder, but it will not show the inputview(like keyboard), so we'd better ignore it.
    if (![view respondsToSelector:@selector(setInputAccessoryView:)]||![view respondsToSelector:@selector(setInputView:)]) {
        return;
    }
    
    self.firstResponderView = view;
    
    /*
     In iOS7,
     When the input view is already display, the first responder change to another , but the keyboard type and frame wouldn't be changed.
     Then `UIKeyboardWillShowNotification` notification will not be posted.
     So we check it in next runloop and do something.
     */
    if (self.lastFirstResponderViewForShowInputView) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (![self.lastFirstResponderViewForShowInputView isEqual:self.firstResponderView]) {
                self.lastFirstResponderViewForShowInputView = self.firstResponderView;
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

#pragma mark - notification
- (void)updateInputViewDetailWithKeyboardNotification:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    self.inputViewAnimationDuration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey]doubleValue];
    self.inputViewAnimationCurve = [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    self.inputViewFrame = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    //fix iOS8 bug:
    //In iOS8 and iPhone5s:
    //If vc1 keyboard type is numberPad and vc2 keyboard type is normal,then pop vc2 to vc1
    //`[[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].origin.y` will > 4000
    //So we must ignore the orgin.y in this case.
    if (self.inputViewFrame.origin.y>[UIScreen mainScreen].bounds.size.height) {
        CGRect adjustFrame = self.inputViewFrame;
        adjustFrame.origin.y = [UIScreen mainScreen].bounds.size.height-adjustFrame.size.height;
        self.inputViewFrame = adjustFrame;
    }
}

- (void)keyboardWillShow:(NSNotification *)notification
{
//    NSLog(@"keyboardWillShow:%@",NSStringFromCGRect([[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue]));
    BOOL animated = YES;
    if ([self.lastFirstResponderViewForShowInputView isEqual:self.firstResponderView]) {
        animated = NO;
    }
    
    self.lastFirstResponderViewForShowInputView = self.firstResponderView;
    
    [self updateInputViewDetailWithKeyboardNotification:notification];
    [self doDodgeWithAnimated:animated];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
//    NSLog(@"keyboardWillHide:%@",NSStringFromCGRect([[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue]));
    self.lastFirstResponderViewForShowInputView = nil;
    
    [self updateInputViewDetailWithKeyboardNotification:notification];
    [self doDodgeWithAnimated:YES];
}

#pragma mark - helper
/**
 *  Get the dodger view of current first responder view
 */
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
 *  If the dodger view is child of `UIScrollView`
 *  We will not change it's frame, replace with changing `contentOffset` and `contentInset`
 */
- (void)doDodgeWithAnimated:(BOOL)animated dodgeScrollView:(UIScrollView*)dodgeView
{
    if (!dodgeView) {
        return;
    }
    
    void(^dodgeBlock)(UIEdgeInsets,CGPoint) = ^(UIEdgeInsets inset,CGPoint offset){
        void (^changeDodgerViewBlock)() = ^{
            BOOL forShow = self.lastFirstResponderViewForShowInputView!=nil;
            
            dodgeView.contentInset = inset;
            if (forShow){
                [dodgeView setContentOffset:offset animated:NO];
            }
            
            if (self.animateAlongsideBlock) {
                self.animateAlongsideBlock(forShow,dodgeView,self.lastFirstResponderViewForShowInputView,self.inputViewFrame);
            }
            
            if (self.lastFirstResponderViewForShowInputView.animateAlongsideAsFirstResponderForMLInputDodgerBlock) {
                self.lastFirstResponderViewForShowInputView.animateAlongsideAsFirstResponderForMLInputDodgerBlock(forShow,dodgeView,self.lastFirstResponderViewForShowInputView,self.inputViewFrame);
            }else if (dodgeView.animateAlongsideAsDodgeViewForMLInputDodgerBlock){
                dodgeView.animateAlongsideAsDodgeViewForMLInputDodgerBlock(forShow,dodgeView,self.lastFirstResponderViewForShowInputView,self.inputViewFrame);
            }
        };
        
        if (animated) {
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:self.inputViewAnimationDuration];
            [UIView setAnimationCurve:self.inputViewAnimationCurve];
            [UIView setAnimationBeginsFromCurrentState:YES];
            
            changeDodgerViewBlock();
            
            [UIView commitAnimations];
        }else{
            changeDodgerViewBlock();
        }
    };

    
    UIEdgeInsets inset = dodgeView.originalContentInsetAsDodgeViewForMLInputDodger;
    CGPoint offset = dodgeView.contentOffset;
    
    //If do dodge for display
    if (self.lastFirstResponderViewForShowInputView) {
        CGFloat keyboardOrginY = self.inputViewFrame.origin.y;
        //If the input accessory view is common retract view, we ignore it's height
        //Because it's a little button, this is more appropriate
        if ([self.firstResponderView.inputAccessoryView isEqual:self.retractInputAccessoryView]) {
            keyboardOrginY+= CGRectGetHeight(self.retractInputAccessoryView.frame);
        }
        
        //Find the position which must be display
        CGFloat shiftHeight = self.firstResponderView.shiftHeightAsFirstResponderForMLInputDodger;
        if (shiftHeight==0) {
            shiftHeight = dodgeView.shiftHeightAsDodgeViewForMLInputDodger;
        }
        
        CGRect frameInDodgeView = [self.firstResponderView convertRect:self.firstResponderView.bounds toView:dodgeView];
        
        CGRect dodgeViewFrameInWindow = [dodgeView.superview convertRect:dodgeView.frame toView:dodgeView.window];
        CGFloat dodgeViewFrameBottomInWindow = CGRectGetMaxY(dodgeViewFrameInWindow);
        
        inset.bottom += MAX(0,dodgeViewFrameBottomInWindow-keyboardOrginY);
        
        CGFloat mustDisplayHeight = CGRectGetHeight(self.firstResponderView.frame)+shiftHeight;
        //the assert is not needed, if you use the library normally.
//        NSAssert(CGRectGetHeight(dodgeViewFrameInWindow)>=mustDisplayHeight+inset.top, @"the height of dodgeScrollView cannot be too small or shift height cannot be too large");
//        NSAssert(keyboardOrginY-dodgeViewFrameInWindow.origin.y>=mustDisplayHeight+inset.top, @"the y of dodgeScrollView cannot too low or shift height cannot be too large");
        
        offset.y = frameInDodgeView.origin.y-inset.top-(MIN(keyboardOrginY,dodgeViewFrameBottomInWindow)-dodgeViewFrameInWindow.origin.y-mustDisplayHeight-inset.top);
        offset.y = MIN(offset.y, dodgeView.contentSize.height-CGRectGetHeight(dodgeViewFrameInWindow)+inset.bottom);
        offset.y = MAX(offset.y, -inset.top);
        
        id nextResponder = [dodgeView nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            //with pop viewcontroller,the previous viewcontroller.view's frame will be reset.
            //so we detect it, and dodge again
            if ([CHILD(UIViewController, nextResponder).transitionCoordinator isAnimated]){
                [CHILD(UIViewController, nextResponder).transitionCoordinator animateAlongsideTransition:nil completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
                    dodgeBlock(inset,offset);
                }];
                return;
            }
        }
    }
    
    dodgeBlock(inset,offset);
}

/**
 *  do dodge with common view, change it's frame
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
        
        //see:https://github.com/molon/MLInputDodger/issues/23#issuecomment-173836788
        //Because when use SouGou input,it would add a spring animation to dodge view.
        //So we need to remove it.
        CAAnimation *animation = [dodgeView.layer animationForKey:@"position"];
        if (animation&&[animation isKindOfClass:[CASpringAnimation class]]) {
            [dodgeView.layer removeAnimationForKey:@"position"];
        }
        
        void (^changeDodgerViewBlock)() = ^{
            dodgeView.frame = frame;
            
            BOOL forShow = self.lastFirstResponderViewForShowInputView!=nil;
            
            if (self.animateAlongsideBlock) {
                self.animateAlongsideBlock(forShow,dodgeView,self.lastFirstResponderViewForShowInputView,self.inputViewFrame);
            }
            
            if (self.lastFirstResponderViewForShowInputView.animateAlongsideAsFirstResponderForMLInputDodgerBlock) {
                self.lastFirstResponderViewForShowInputView.animateAlongsideAsFirstResponderForMLInputDodgerBlock(forShow,dodgeView,self.lastFirstResponderViewForShowInputView,self.inputViewFrame);
            }else if (dodgeView.animateAlongsideAsDodgeViewForMLInputDodgerBlock){
                dodgeView.animateAlongsideAsDodgeViewForMLInputDodgerBlock(forShow,dodgeView,self.lastFirstResponderViewForShowInputView,self.inputViewFrame);
            }
        };
        
        if (animated) {
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:self.inputViewAnimationDuration];
            [UIView setAnimationCurve:self.inputViewAnimationCurve];
            [UIView setAnimationBeginsFromCurrentState:YES];
            
            changeDodgerViewBlock();
            
            [UIView commitAnimations];
        }else{
            changeDodgerViewBlock();
        }
    };
    
    
    CGFloat oldY = dodgeView.originalYAsDodgeViewForMLInputDodger;
    CGFloat newY = oldY;
    if (self.lastFirstResponderViewForShowInputView) {
        CGFloat keyboardOrginY = self.inputViewFrame.origin.y;
        //If the input accessory view is common retract view, we ignore it's height
        //Because it's a little button, this is more appropriate
        if ([self.firstResponderView.inputAccessoryView isEqual:self.retractInputAccessoryView]) {
            keyboardOrginY+= CGRectGetHeight(self.retractInputAccessoryView.frame);
        }
        
        //Find the position which must be display
        CGFloat shiftHeight = self.firstResponderView.shiftHeightAsFirstResponderForMLInputDodger;
        if (shiftHeight==0) {
            shiftHeight = dodgeView.shiftHeightAsDodgeViewForMLInputDodger;
        }
        
        CGRect frameInWindow = [self.firstResponderView convertRect:self.firstResponderView.bounds toView:self.firstResponderView.window];
        
        CGFloat mustVisibleYForWindow = frameInWindow.origin.y+frameInWindow.size.height+shiftHeight;
        
        newY = MIN(oldY, keyboardOrginY - mustVisibleYForWindow + dodgeView.frame.origin.y);
        //ensure that the view will not move up excessively
        newY = MAX(newY, keyboardOrginY - CGRectGetHeight(dodgeView.frame));
        //ensure that the view will not move down
        newY = MIN(newY, oldY);
        
        id nextResponder = [dodgeView nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            //with pop viewcontroller,the previous viewcontroller.view's frame will be reset.
            //so we detect it, and dodge again
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

@end
