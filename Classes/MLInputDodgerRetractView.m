//
//  MLInputDodgerRetractView.m
//  MLInputDodger
//
//  Created by molon on 15/7/28.
//  Copyright (c) 2015年 molon. All rights reserved.
//

#import "MLInputDodgerRetractView.h"

@interface MLInputDodgerRetractView()

@property (nonatomic, strong) UIButton *button;

@end

@implementation MLInputDodgerRetractView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.button];
    }
    return self;
}

#pragma mark - getter
- (UIButton *)button
{
    if (!_button) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        
        //see https://github.com/CocoaPods/CocoaPods/issues/3226
        NSBundle *bundle = [NSBundle bundleForClass:NSClassFromString(@"MLInputDodger")];
        NSString *bundlePath = [bundle pathForResource:@"MLInputDodger" ofType:@"bundle"];
        UIImage *retractImage = [[UIImage alloc]initWithContentsOfFile:[bundlePath stringByAppendingPathComponent:@"retract.png"]];
        [button setImage:retractImage forState:UIControlStateNormal];
        [button addTarget:self action:@selector(retract) forControlEvents:UIControlEventTouchUpInside];
        
        button.layer.cornerRadius = 5.0f;
        button.layer.masksToBounds = NO;
        button.backgroundColor = [UIColor clearColor];
        button.layer.backgroundColor = [UIColor colorWithRed:0.906 green:0.910 blue:0.918 alpha:1.000].CGColor;
        button.layer.rasterizationScale = [UIScreen mainScreen].scale;
        
        _button = button;
    }
    return _button;
}

#pragma mark - event
- (void)retract
{
    if (self.didClickRetractButtonBlock) {
        self.didClickRetractButtonBlock();
    }
}

#pragma mark - layout
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    static CGFloat buttonWidth = 35.0f;
    self.button.frame = CGRectMake(CGRectGetWidth(self.frame)-buttonWidth, 0, buttonWidth, CGRectGetHeight(self.frame));
}

#pragma mark - penetrable

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    BOOL result = [super pointInside:point withEvent:event];
    
    if (result) {
        //penetrable except button
        if (!CGRectContainsPoint(self.button.frame, point)) {
            return NO;
        }
    }
    
    return result;
}
@end
