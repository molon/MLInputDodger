# MLInputDodger
[![License MIT](https://img.shields.io/badge/license-MIT-green.svg?style=flat)](https://raw.githubusercontent.com/molon/MLInputDodger/master/LICENSE)&nbsp;
[![CocoaPods](http://img.shields.io/cocoapods/v/MLInputDodger.svg?style=flat)](http://cocoapods.org/?q=MLInputDodger)&nbsp;
[![CocoaPods](http://img.shields.io/cocoapods/p/MLInputDodger.svg?style=flat)](http://cocoapods.org/?q=MLInputDodger)&nbsp;
[![Build Status](https://travis-ci.org/molon/MLInputDodger.svg?branch=master)](https://travis-ci.org/molon/MLInputDodger)&nbsp;
[![Apps Using](https://img.shields.io/badge/Apps%20Using-%3E344-28B9FE.svg)](http://cocoapods.org/pods/MLInputDodger)&nbsp;
[![Downloads](https://img.shields.io/badge/Total%20Downloads-%3E7,832-28B9FE.svg)](http://cocoapods.org/pods/MLInputDodger)&nbsp;

**My library does not seek any reward,
but if you use this library, star it if you like. :)**

![MLInputDodger](https://raw.githubusercontent.com/molon/MLInputDodger/master/MLInputDodger.gif)

# Advantage
- Automatic processing of keyboard-related events with little code, not affect global and no special view or viewController nee to be inherited, so it's flexible.
- Provide a optional default retractButton which can be clicked to hide keyboard. 
- Use `animateAlongsideBlock` to add your own dodge behaviors for other views or to trigger other behaviors.
- With transition complete of two vc, the dodge behavior would be triggered again, ensure dodge behavior.
- Fixed iOS8's bug: `UIKeyboardFrameEndUserInfoKey` return strange `origin.y` sometimes.
- Fixed SougouInput's bug: it produces a ungly spring animation sometimes.


# Principle

- The `dodgeView` means which view need to be change frame or change contentOffset(contentInset)
- All subviews which can `becomeFirstResponder` in the `dodgeView` will trigger the dodge behavior. 
- The `inputView` of subviews maybe not only keyboard. It's ok, this is why the library named `MLInputDodger` not `MLKeyboardDodger`. :)


# Usage  

```
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.view.shiftHeightAsDodgeViewForMLInputDodger = 50.0f;
    [self.view registerAsDodgeViewForMLInputDodgerWithOriginalY:self.view.frame.origin.y];
}
```   
Then the subviews which can becomeFirstResponder will trigger dodge.  
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

# Tips
You can add this category to disable automatic keyboard for `UITableViewController`, or it will affect the implementation of the library.
But `_adjustForAutomaticKeyboardInfo:animated:lastAdjustment:` is a private api, so...
```
@implementation UITableView(DisableAutomaticKeyboard)
- (void)_adjustForAutomaticKeyboardInfo:(id)arg1 animated:(BOOL)arg2 lastAdjustment:(float*)arg3 {
    return;
}
@end
```
