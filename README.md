# MLInputDodger
MLInputDodger

The keyboard dodger for input.

**My library does not seek any reward,
but if you use this library, tell me if you like. :)**

![MLInputDodger](https://raw.githubusercontent.com/molon/MLInputDodger/master/MLInputDodger.gif)

# Advantage
- Automatic processing of keyboard-related events with little code, not affect global and no special view or viewController to inherit, so it's flexible.
- Provied a optional default retractButton which can be clicked to hide keyboard. 
- Use `animateAlongsideBlock` to add your own dodge behaviors for other view or trigger other behavior.
- With transition complete of two vc, the dodge behavior would be triggered again, ensure dodge behavior.
- Fixed iOS8's bug: sometimes `UIKeyboardFrameEndUserInfoKey` return strange `origin.y`
- Fixed SougouInput's bug: sometimes it will produces a ungly spring animation.


# Principle

- The `dodgeView` means which view need to be change frame or change contentOffset(contentInset)
- All subviews who can `becomeFirstResponder` of the `dodgeView` will trigger the dodge behavior. 
- The `inputView` of subviews maybe not only keyboard. It's ok, this is why the library named `MLInputDodger` not `MLKeyboardDodger`. :)


# Usage  

```
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.view.shiftHeightAsDodgeViewForMLInputDodger = 50.0f;
    [self.view registerAsDodgeViewForMLInputDodger];
}
```   
Then the subviews who can becomeFirstResponder will trigger dodge.  
If you need custom shiftHeight for special responder, just set the `shiftHeightAsFirstResponderForMLInputDodger` property.  
   
   
Disbale default retract input accessory view:

```
self.view.dontUseDefaultRetractViewAsDodgeViewForMLInputDodger = NO; //for all subviews of self.view

self.testView1.dontUseDefaultRetractViewAsFirstResponderForMLInputDodger = NO; //for sepecial
```

AnimateAlongside:

```
[[MLInputDodger dodger]setAnimateAlongsideBlock:^(BOOL show,UIView *dodgerView,UIView *firstResponderView,CGRect inputViewFrame) {
        if ([dodgerView isKindOfClass:[UIScrollView class]]) {
            ((UIScrollView*)dodgerView).scrollIndicatorInsets = ((UIScrollView*)dodgerView).contentInset;
        }
    }];
```

```
__weak __typeof(self)weakSelf = self;
    [self.tableView setAnimateAlongsideAsDodgeViewForMLInputDodgerBlock:^(BOOL show,UIView *dodgerView,UIView *firstResponderView,CGRect inputViewFrame) {
        __strong __typeof(weakSelf)sSelf = weakSelf;
        CGRect frame = sSelf.testAnimateAlongsideLabel.frame;
        if (show) {
            frame.origin.y = inputViewFrame.origin.y+kMLInputDodgerRetractViewDefaultHeight-kLabelBottomMargin-kLabelHeight;
        }else{
            frame.origin.y = sSelf.view.frame.size.height-kLabelBottomMargin-kLabelHeight;
        }
        sSelf.testAnimateAlongsideLabel.frame = frame;
    }];
```
