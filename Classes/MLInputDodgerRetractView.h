//
//  MLInputDodgerRetractView.h
//  MLInputDodger
//
//  Created by molon on 15/7/28.
//  Copyright (c) 2015年 molon. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kMLInputDodgerRetractViewDefaultHeight 30.0f
@interface MLInputDodgerRetractView : UIView

@property (nonatomic, copy) void(^didClickRetractButtonBlock)();

@end
