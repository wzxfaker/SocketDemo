//
//  ViewController.m
//  SocketDemo
//
//  Created by admin on 2018/3/28.
//  Copyright © 2018年 admin. All rights reserved.
//

//打开mac命令行终端 输入 nc -lk 端口号
//即可把本机当成服务器
#import "ViewController.h"
#import "XNativeSocketManager.h"
#import "XAsyncSocketManager.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UITextField *inputTF;
/** <##> */
@property (nonatomic, strong) XNativeSocketManager *nativeManager;
/** <##> */
@property (nonatomic, strong) XAsyncSocketManager *asyncManager;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.nativeManager = [XNativeSocketManager sharedManager];
    self.asyncManager = [XAsyncSocketManager sharedManager];
}

- (IBAction)sendClick:(UIButton *)sender {
//    [self.nativeManager sendMsg:self.inputTF.text];
    [self.asyncManager sendMsg:self.inputTF.text];
}

- (IBAction)connectClick:(UIButton *)sender {
//    [self.nativeManager connect];
    [self.asyncManager connect];
}

- (IBAction)disConnectClick:(UIButton *)sender {
//    [self.nativeManager disConnect];
    [self.asyncManager disConnect];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
