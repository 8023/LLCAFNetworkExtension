//
//  IKNetworkConfig.h
//  IKNetworkService
//
//  Created by LLC on 16/2/19.
//  Copyright © 2016年 LLC. All rights reserved.
//

#ifndef IKNetworkConfig_h
#define IKNetworkConfig_h

#import <Foundation/Foundation.h>

//设置超时
static const float defaultTimeout = 30.0f;

//返回码
typedef NS_ENUM(NSUInteger, IKRespondCode) {

    RESPONSE_STATUS_SUCCESS                  = 200,  //请求成功
    RESPONSE_STATUS_ERROR_NOT_MODIFIED       = 304,  //HTTP缓存无效
    RESPONSE_STATUS_ERROR_REQUEST_DIRTY_DATA = 400,  //请求参数错误
    RESPONSE_STATUS_ERROR_AUTHOR_FAILED      = 401,  //身份验证错误  需要重新登录
    RESPONSE_STATUS_ERROR_RESPOND_DATA_ERROR = 404,   //请求的资源或接口不存在
    RESPONSE_STATUS_REQUEST_MOTHORD_ERROR    = 405,   //该http方法不被允许
    RESPONSE_STATUS_RESPOND_DATA_INAVILIABLE = 410,  //这个url对应的资源现在不可用
    RESPONSE_STATUS_REQUEST_MEDIA_TYPE_ERROR = 415,  //请求类型错误
    RESPONSE_STATUS_ENTITY_UNSUPPORTED_ERROR = 422,  //校验错误
    RESPONSE_STATUS_REQUEST_BUSSIE_ERROR     = 429,  //请求过多
    RESPONSE_STATUS_RESPOND_NORMAL_ERROR     = 500,
    RESPONSE_STATUS_ERROR_LOGIN_BY_OTHER     = 911,  //您的账号已在其他设备登陆
    RESPONSE_STATUS_ERROR_WITHOUT_VERTIFY    = 912,  //非法操作 未认证

    RESPONSE_STATUS_NOT_JSON                 = 1001,  //自定义 不是json
    RESPONSE_STATUS_TIME_OUT                 = 1002   //自定义 请求超时

};


/**
 *  请求方式
 */
typedef NS_ENUM(NSUInteger, IKRequestMethod) {
    /**
     *  GET
     */
    GetMethod = 1,
    /**
     *  POST
     */
    PostMethod,
    /**
     *  PUT
     */
    PutMethod,
    /**
     *  DELETE
     */
    DeleteMethod
};


#endif /* IKNetworkConfig_h */
