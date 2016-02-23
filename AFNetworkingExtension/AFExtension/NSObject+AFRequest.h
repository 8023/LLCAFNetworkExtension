//
//  NSObject+AFRequest.h
//  AFNetworkingExtension
//
//  Created by LLC on 15/11/2.
//  Copyright (c) 2015年 12304. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


/**
 *  请求方法
 */
typedef NS_ENUM(NSUInteger, AFRequestMethod){
    
    GetMethod,
    
    PostMethod,
    
    PutMethod,
    
    DeleteMethod
};

typedef NS_ENUM(NSInteger, URLRequrestErrorCode) {
    
    URLRequestNotJson   = 10001,// 不是json
    URLRequestCodeError = 10002,// 返回码错误
};

/**
 *  请求结果回调
 */
typedef void (^requestResultBlock)(NSDictionary * result);


@interface NSObject (AFRequest)

/**
 *  创建网络请求
 *
 *  @param api          URL string
 *  @param method       请求方式
 *  @param params       请求参数
 *  @param showLoading  是否显示加载图层
 *  @param success      请求成功回调
 *  @param failed       请求失败回调
 */
- (void)startRequestWithApi:(NSString *)api method:(AFRequestMethod)method params:(NSDictionary*)params showLoading:(BOOL)showLoading success:(requestResultBlock)success failed:(requestResultBlock)failed;

/**
 *  上传图片
 *
 *  @param api             url
 *  @param image           图片
 *  @param imageKey        后台给的图片参数key
 *  @param params          其他参数
 *  @param showLoading     是否显示loading遮罩提示
 *  @param success 请求成功回调
 *  @param failed     请求失败回调
 */
- (void)uploadImageWithApi:(NSString *)api image:(UIImage *)image imageKey:(NSString *)imageKey params:(NSDictionary *)params showLoading:(BOOL)showLoading success:(requestResultBlock)success failed:(requestResultBlock)failed;

/**
 *  更具URSSgtring取消请求
 *
 *  @param URLString 被取消请求的URSSgtring
 */
- (void)cancelRequestWithURLString:(NSString *)URLString;

/**
 *  取消所有请求
 */
- (void)cancelAllRequest;

@end
