//
//  ViewController.m
//  RAC_Login
//
//  Created by yl on 2017/7/13.
//  Copyright © 2017年 yl. All rights reserved.
//

#import "ViewController.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "YJJTextField.h"
@interface ViewController ()
@property (nonatomic, assign) YJJTextField *userNameField;
@property (nonatomic, assign) YJJTextField *passwordField;
@property (nonatomic, strong) UIButton *loginBtn;
@property (nonatomic, strong) NSArray *textFieldArr;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
 
    [self setupUI];
    
    [self setRACSignal];
}

- (void)setupUI
{
    
    YJJTextField *userNameField = [YJJTextField yjj_textField];
    userNameField.frame = CGRectMake(0, 60, self.view.frame.size.width, 60);
    userNameField.maxLength = 11;
    userNameField.errorStr = @"*字数长度不得超过11位";
    userNameField.placeholder = @"请输入手机号";
    userNameField.historyContentKey = @"userName";
    [self.view addSubview:userNameField];
    self.userNameField = userNameField;
    
    YJJTextField *passwordField = [YJJTextField yjj_textField];
    passwordField.frame = CGRectMake(0, 120, self.view.frame.size.width, 60);
    passwordField.maxLength = 8;
    passwordField.errorStr = @"*密码长度不得超过8位";
    passwordField.placeholder = @"请输入密码";
    passwordField.historyContentKey = @"password";
    passwordField.leftImageName = @"password_login";
    passwordField.showHistoryList = NO;
    [self.view addSubview:passwordField];
    self.passwordField = passwordField;
    
    self.textFieldArr = @[userNameField,passwordField];
    
    UIButton *loginBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
    loginBtn.frame = CGRectMake(20, CGRectGetMaxY(passwordField.frame) + 40, self.view.frame.size.width - 40, 35);
    [loginBtn setTitle:@"LOGIN" forState:(UIControlStateNormal)];
    [loginBtn setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
    loginBtn.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:loginBtn];
    self.loginBtn = loginBtn;
}

- (void)setRACSignal
{
    // 创建用户名信号道
    RACSignal *userNameSignal = [self.userNameField.textField.rac_textSignal map:^id(id value) {
        return @([self isValidUsername:value]);
    }];
    
    // 创建密码信号道
    RACSignal *passwordSignal = [self.passwordField.textField.rac_textSignal map:^id(id value) {
        return @([self isValidPassword:value]);
    }];
    
    // 通过信号道返回的值，设置文本字体颜色
    RAC(self.userNameField.textField, textColor) = [userNameSignal map:^id(id value) {
        return [value boolValue] ? [UIColor lightGrayColor] : [UIColor redColor];
    }];
    
    // 通过信号道返回的值，设置文本字体颜色
    RAC(self.passwordField.textField, textColor) = [passwordSignal map:^id(id value) {
        return [value boolValue] ? [UIColor lightGrayColor] : [UIColor redColor];
    }];
    
    // 创建登陆按钮信号道，并合并用户名和密码信号道
    RACSignal *loginSignal = [RACSignal combineLatest:@[userNameSignal, passwordSignal] reduce:^id(NSNumber *userNameValue, NSNumber *passwordValue){
        return @([userNameValue boolValue] && [passwordValue boolValue]);
    }];
    
    // 订阅信号
    [loginSignal subscribeNext:^(id boolValue) {
        if ([boolValue boolValue]) {
            self.loginBtn.userInteractionEnabled = YES;
            [self.loginBtn setBackgroundColor:[UIColor orangeColor]];
        }else {
            self.loginBtn.userInteractionEnabled = NO;
            [self.loginBtn setBackgroundColor:[UIColor lightGrayColor]];
        }
    }];
    
    [[self.loginBtn rac_signalForControlEvents:(UIControlEventTouchUpInside)] subscribeNext:^(UIButton *sender) {
        NSLog(@"------%@===我点击了按钮",sender);
    }];
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    for (YJJTextField *textField in self.textFieldArr) {
        
        [textField setPlaceHolderLabelHidden:YES];
        [textField dismissTheHistoryContentTableView];
    }
    [self.view endEditing:YES];
}


// 验证用户名
- (BOOL)isValidUsername:(NSString *)username {
    
    // 验证用户名 - 手机号码
    NSString *regEx = @"^1[3|4|5|7|8][0-9]\\d{8}$";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regEx];
    
    return [phoneTest evaluateWithObject:username];
}

// 验证密码 - 由数字和26个英文字母组成的字符串
- (BOOL)isValidPassword:(NSString *)password {
    
    NSString *regEx = @"^(?![0-9]+$)(?![a-zA-Z]+$)[0-9A-Za-z]{8,20}$";
    NSPredicate *passwordTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regEx];
    return [passwordTest evaluateWithObject:password];
}


@end
