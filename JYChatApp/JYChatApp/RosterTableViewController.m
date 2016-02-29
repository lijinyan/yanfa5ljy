//
//  RosterTableViewController.m
//  JYChatApp
//
//  Created by lanou3g on 16/2/25.
//  Copyright © 2016年 李金岩. All rights reserved.
//

#import "RosterTableViewController.h"
#import "XMPPManager.h"
#import "XMPPFramework.h"
#import "ChatViewController.h"


@interface RosterTableViewController ()<XMPPRosterDelegate,XMPPRosterStorage>
@property(nonatomic, strong) NSMutableArray *friendsArray;
@end

@implementation RosterTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.friendsArray = [NSMutableArray array];
    
    //添加代理
    [[XMPPManager shareInstance].xmppRoster addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

#pragma mark XMPPRosterDelegate


#pragma mark 接收到好友请求
- (void)xmppRoster:(XMPPRoster *)sender didReceivePresenceSubscriptionRequest:(XMPPPresence *)presence {
    
    //接受好友请求
    XMPPJID *jid = presence.from;
    
    //获取好友花名册
//    XMPPRoster *roster = [XMPPManager shareInstance].xmppRoster;
    //判断是否已经是好友
    if ([[XMPPManager shareInstance].coreDataStorage userExistsWithJID:jid xmppStream:[XMPPManager shareInstance].xmppStream]) {
        NSLog(@"你们已经是好友");
        return;
    }
    
    [[XMPPManager shareInstance].xmppRoster acceptPresenceSubscriptionRequestFrom:jid andAddToRoster:YES];
    
    //拒绝好友请求
//    [[XMPPManager shareInstance].xmppRoster rejectPresenceSubscriptionRequestFrom:jid];
    
    NSLog(@"接收到好友请求");
}

#pragma mark 开始检索
-(void)xmppRosterDidBeginPopulating:(XMPPRoster *)sender {
    NSLog(@"开始检索");
}


#pragma mark 结束检索
- (void)xmppRosterDidEndPopulating:(XMPPRoster *)sender {
    NSLog(@"结束检索");
}

#pragma mark 一次检索出一个好友
- (void)xmppRoster:(XMPPRoster *)sender didReceiveRosterItem:(DDXMLElement *)item {
    NSString *jidStr = [[item attributeForName:@"jid"] stringValue];
    
    
    //转换成XMPPJID对象
    XMPPJID *jid = [XMPPJID jidWithString:jidStr];
    
    //判断是否已经添加过
    if ([self.friendsArray containsObject:jid]) {
        return;
    }
    
    [self.friendsArray addObject:jid];
    
    
    [self.tableView reloadData];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.friendsArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    XMPPJID *jid = self.friendsArray[indexPath.row];
    
    cell.textLabel.text = jid.user;
    
    return cell;
}

- (IBAction)addAction:(UIBarButtonItem *)sender {
    
    //弹框
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"添加好友" message:@"输入好友名字" preferredStyle:UIAlertControllerStyleAlert];
    //输入框
    [controller addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        
    }];
    
    //按钮
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"添加" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //获取好友名字
        NSString *name = controller.textFields.firstObject.text;
        
        XMPPJID *jid = [XMPPJID jidWithUser:name domain:kDomin resource:kResource];
        //发送好友请求
        [[XMPPManager shareInstance].xmppRoster subscribePresenceToUser:jid];
        //判断是否已经是好友
        if ([[XMPPManager shareInstance].coreDataStorage userExistsWithJID:jid xmppStream:[XMPPManager shareInstance].xmppStream]) {
            NSLog(@"你们已经是好友");
            return;
        }
    }];
    
    [controller addAction:action];
    
    [self.navigationController presentViewController:controller animated:YES completion:nil];
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    //获取cell
    UITableViewCell *cell = sender;
    
    //获取NSindexpath
    NSIndexPath *path = [self.tableView indexPathForCell:cell];
    //获取到jid
    XMPPJID *jid = self.friendsArray[path.row];
    //获取聊天控制器
//    ChatViewController *chatVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"chatVC"];
    
    ChatViewController *chatVC = segue.destinationViewController;
    chatVC.friendJid = jid;
    
    
}


@end
