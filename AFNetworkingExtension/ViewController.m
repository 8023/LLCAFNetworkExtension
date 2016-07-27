//
//  ViewController.m
//  AFNetworkingExtension
//
//  Created by LLC on 15/11/2.
//  Copyright (c) 2015年 12304. All rights reserved.
//

#import "ViewController.h"
#import "NSObject+AFRequest.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    UIButton * addButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [addButton setTitle:@"请求一个" forState:UIControlStateNormal];
    addButton.backgroundColor  = [UIColor greenColor];
    [addButton addTarget:self action:@selector(beginReqeust) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:addButton];
    
    UIButton * add2Button = [UIButton buttonWithType:UIButtonTypeCustom];
    [add2Button setTitle:@"请求另一个" forState:UIControlStateNormal];
    add2Button.backgroundColor  = [UIColor blueColor];
    [add2Button addTarget:self action:@selector(begin2Reqeust) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:add2Button];
    
    UIButton * deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [deleteButton setTitle:@"取消所有请求" forState:UIControlStateNormal];
    deleteButton.backgroundColor = [UIColor redColor];
    [deleteButton addTarget:self action:@selector(removeRequest) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:deleteButton];
    
    
    UIButton * delete1Button = [UIButton buttonWithType:UIButtonTypeCustom];
    [delete1Button setTitle:@"取消第一个请求" forState:UIControlStateNormal];
    delete1Button.backgroundColor = [UIColor redColor];
    [delete1Button addTarget:self action:@selector(remove1Request) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:delete1Button];

    
    UIButton * delete2Button = [UIButton buttonWithType:UIButtonTypeCustom];
    [delete2Button setTitle:@"取消第二个请求" forState:UIControlStateNormal];
    delete2Button.backgroundColor = [UIColor redColor];
    [delete2Button addTarget:self action:@selector(remove2Request) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:delete2Button];
    
    addButton.frame = CGRectMake(60, 60, 200, 50);
    add2Button.frame = CGRectMake(60, 130, 200, 50);
    delete1Button.frame = CGRectMake(60, 200, 200, 50);
    delete2Button.frame = CGRectMake(60, 270, 200, 50);
    deleteButton.frame = CGRectMake(60, 340, 200, 50);


}


- (void)beginReqeust
{
//http://127.0.0.1:63342/LCPhpNetwork/localrequest.php
//    http://192.168.99.194:8964/oauth2/token
    [self startRequestWithApi:@"http://192.168.99.194:8964/oauth2/captcha" method:GetMethod params:nil success:^(NSURLSessionDataTask * task ,id result) {
        NSHTTPURLResponse * response = (NSHTTPURLResponse *) task.response;
        NSLog(@"%@",response.allHeaderFields);
    } failed:^(NSURLSessionDataTask * task ,id result) {
        
    } respondMethod:AFSerializeTypeHttp];
    
    

    //dkdkdkdkdk
    
//    [self startRequestWithApi:@"http://hylapi.yuandalu.com/region" method:GetMethod params:nil success:^(NSDictionary *result) {
//        NSLog(@"success: %@",result);
//    } failed:^(NSDictionary *result) {
//        NSLog(@"failed: %@",result);
//    }];
}

- (void)removeRequest
{
    [self cancelAllRequest];
}

- (void)remove1Request
{
    [self cancelRequestWithURLString:@"http://hylapi.yuandalu.com/region"];
}

- (void)remove2Request
{
    [self cancelRequestWithURLString:@"http://hylapi.yuandalu.com/banner"];

}

- (void)begin2Reqeust
{
    [self startRequestWithApi:@"http://hylapi.yuandalu.com/banner" method:GetMethod params:nil  success:^(NSURLSessionDataTask * task ,id result) {
        
        NSLog(@"success: %@",result);
    } failed:^(NSURLSessionDataTask * task ,id result) {
        NSLog(@"failed: %@",result);
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
