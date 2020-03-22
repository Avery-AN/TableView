//
//  RootViewController.m
//  TableView
//
//  Created by Avery An on 2019/11/19.
//  Copyright © 2019 Avery. All rights reserved.
//

#import "RootViewController.h"
#import "RichTextViewController.h"
#import "ScratchablelatexViewController.h"


@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    UIButton *button_1 = [UIButton buttonWithType:UIButtonTypeCustom];
    button_1.backgroundColor = [UIColor orangeColor];
    button_1.frame = CGRectMake(60, 160, 256, 60);
    [button_1 setTitle:@"RichText Cell" forState:UIControlStateNormal];
    [button_1 addTarget:self action:@selector(action_1) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button_1];
    
    UIButton *button_2 = [UIButton buttonWithType:UIButtonTypeCustom];
    button_2.backgroundColor = [UIColor orangeColor];
    button_2.frame = CGRectMake(60, 260, 256, 60);
    [button_2 setTitle:@"九宫格" forState:UIControlStateNormal];
    [button_2 addTarget:self action:@selector(action_2) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button_2];
}
- (void)action_1 {
    RichTextViewController *vc = [RichTextViewController new];
    [self.navigationController pushViewController:vc animated:YES];
}
- (void)action_2 {
    ScratchablelatexViewController *vc = [ScratchablelatexViewController new];
    [self.navigationController pushViewController:vc animated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
