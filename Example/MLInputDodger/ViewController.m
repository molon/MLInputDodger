//
//  ViewController.m
//  MLInputDodger
//
//  Created by molon on 15/7/27.
//  Copyright (c) 2015年 molon. All rights reserved.
//

#import "ViewController.h"
#import "UIView+MLInputDodger.h"
#import "ListViewController.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UITextView *testView1;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.title = @"MLInputDodger";
    
    UITapGestureRecognizer *tapG = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap)];
    [self.view addGestureRecognizer:tapG];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //please use the method in viewDidAppear
    self.view.shiftHeightAsDodgeViewForMLInputDodger = 50.0f;
    [self.view registerAsDodgeViewForMLInputDodgerWithOriginalY:self.view.frame.origin.y];
}

- (IBAction)buttonPressed:(id)sender {
    ListViewController *vc = [ListViewController new];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - event
- (void)tap
{
    [self.view endEditing:YES];
}

@end
