//
//  RegisterViewController.m
//  JYChatApp
//
//  Created by lanou3g on 16/2/25.
//  Copyright © 2016年 李金岩. All rights reserved.
//

#import "RegisterViewController.h"
#import "XMPPManager.h"
#import "XMPPFramework.h"

@interface RegisterViewController ()<XMPPStreamDelegate >
@property (weak, nonatomic) IBOutlet UITextField *userName;

@property (weak, nonatomic) IBOutlet UITextField *passWord;

@end

@implementation RegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //添加代理
    [[XMPPManager shareInstance].xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    // Do any additional setup after loading the view.
}

#pragma mark 注册成功
-(void)xmppStreamDidRegister:(XMPPStream *)sender {
    //注册成功  自动登录
    [[XMPPManager shareInstance]loginWithUserName:self.userName.text passWord:self.passWord.text];
    
}


- (IBAction)registerAction:(UIButton *)sender {

    NSString *name = self.userName.text;
    NSString *password = self.passWord.text;
    [[XMPPManager shareInstance] registerWithUserName:name passWord:password];
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
