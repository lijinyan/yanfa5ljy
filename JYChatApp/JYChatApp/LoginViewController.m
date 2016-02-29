//
//  LoginViewController.m
//  JYChatApp
//
//  Created by lanou3g on 16/2/25.
//  Copyright © 2016年 李金岩. All rights reserved.
//

#import "LoginViewController.h"
#import "XMPPManager.h"
#import "XMPPFramework.h"

@interface LoginViewController ()<XMPPStreamDelegate>
@property (weak, nonatomic) IBOutlet UITextField *UserNameField;

@property (weak, nonatomic) IBOutlet UITextField *passWordField;


@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    //添加代理
    [[XMPPManager shareInstance].xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    
    // Do any additional setup after loading the view.
}

#pragma mark 验证成功
- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)loginAction:(UIButton *)sender {
    NSString *name = self.UserNameField.text;
    NSString *password = self.passWordField.text;
    //执行登录
    [[XMPPManager shareInstance] loginWithUserName:name passWord:password];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
