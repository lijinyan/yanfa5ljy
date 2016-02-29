//
//  ChatViewController.m
//  JYChatApp
//
//  Created by lanou3g on 16/2/26.
//  Copyright © 2016年 李金岩. All rights reserved.
//

#import "ChatViewController.h"
#import "XMPPManager.h"


@interface ChatViewController ()<UITableViewDataSource, UITableViewDelegate, XMPPStreamDelegate>

@property (weak, nonatomic) IBOutlet UITableView *chatTableView;

@property (weak, nonatomic) IBOutlet UITextField *messageField;

@property(nonatomic, strong)NSMutableArray *messageArray;


@end

@implementation ChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.messageArray = [NSMutableArray array];
    
    //添加代理
    [[XMPPManager shareInstance].xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    NSLog(@"jid = %@", self.friendJid);
    
    //进入聊天页面就查询聊天记录
    [self searchMessage];
    
    // Do any additional setup after loading the view.
}

#pragma mark XMPPStreamDelegate

#pragma mark 接收到消息
-(void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message {
    NSLog(@"接收到消息");
    //查询新的聊点记录
    [self searchMessage];
}

#pragma mark 消息发送失败
- (void)xmppStream:(XMPPStream *)sender didFailToSendMessage:(XMPPMessage *)message error:(NSError *)error {
    NSLog(@"消息发送失败");
}

#pragma mark 消息发送成功
- (void)xmppStream:(XMPPStream *)sender didSendMessage:(XMPPMessage *)message {
    
    NSLog(@"消息发送成功");
    //查询新的聊天记录
    [self searchMessage];
}


#pragma mark 获取聊天信息
- (void)searchMessage {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPMessageArchiving_Message_CoreDataObject" inManagedObjectContext:[XMPPManager shareInstance].context];
    [fetchRequest setEntity:entity];
    // Specify criteria for filtering which objects to fetch
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"streamBareJidStr == %@ AND bareJidStr == %@", [XMPPManager shareInstance].xmppStream.myJID.bare, self.friendJid.bare];
    [fetchRequest setPredicate:predicate];
    // Specify how the fetched objects should be sorted
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timestamp"
                                                                   ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [[XMPPManager shareInstance].context executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {
        NSLog(@"查询失败：%@", error);
    }
    //先清空数组
    [self.messageArray removeAllObjects];
    //然后添加数据
    [self.messageArray addObjectsFromArray:fetchedObjects];
     NSIndexPath *path = [NSIndexPath indexPathForRow:self.messageArray.count - 1 inSection:0];
    
    
    //刷新
    [self.chatTableView reloadData];
    if (self.messageArray.count == 0) {
        return;
    }
    //自动滑动到最后一行
    [self.chatTableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    
//    NSLog(@"%@", self.messageArray);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.messageArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"chat" forIndexPath:indexPath];
    
    
    if (cell) {
        XMPPMessageArchiving_Message_CoreDataObject *message = self.messageArray[indexPath.row];
        
        if (!message.isOutgoing) {
            //发出的消息
            cell.textLabel.textAlignment = NSTextAlignmentLeft;
            
            cell.detailTextLabel.hidden = YES;
            cell.textLabel.hidden = NO;
            
            
            
            
            cell.textLabel.text = message.body;
        } else {
            //接受的消息
            cell.detailTextLabel.textAlignment = NSTextAlignmentRight;
            
            cell.textLabel.hidden = YES;
            cell.detailTextLabel.hidden = NO;
            
            
            cell.detailTextLabel.text = message.body;
        }
        
    }
    
    
    return cell;
}


//发送按钮事件
- (IBAction)sendAction:(UIButton *)sender {
    
    //创建消息对象
    XMPPMessage *message = [XMPPMessage messageWithType:@"chat" to:self.friendJid];
    
    //设置消息内容
    [message addBody:self.messageField.text];
    
    //发送消息
    [[XMPPManager shareInstance].xmppStream sendElement:message];
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
    RosterTableViewController *rvc = [[RosterTableViewController alloc] init];
    
    
}
*/

@end
