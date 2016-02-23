//
//  NSObject+AFRequest.m
//  AFNetworkingExtension
//
//  Created by LLC on 15/11/2.
//  Copyright (c) 2015年 12304. All rights reserved.
//

#import "NSObject+AFRequest.h"
#import "AFNetworking.h"
#import <objc/runtime.h>
#import <CommonCrypto/CommonDigest.h>

#pragma mark - Manager

@interface DefaultHttpManager : NSObject

/**
 *  请求头部信息
 */
+ (NSDictionary *)httpHeader;

/**
 *  请求超时
 */
+ (CGFloat)timeOutInterval;

/**
 *  返回数据解析可用类型
 */
+ (NSSet *)acceptableContentTypes;

@end

@implementation DefaultHttpManager

+ (NSDictionary *)httpHeader
{

    NSMutableDictionary * httpHeader = [NSMutableDictionary dictionaryWithCapacity:0];
    //如果需要token 或其他头部设置请自己添加
//    [httpHeader setObject:@"tokenString" forKey:@"token"];
    return httpHeader;
}

+ (CGFloat)timeOutInterval
{
    return 15.0f;
}

+ (NSSet *)acceptableContentTypes
{
   return [NSSet setWithObjects: @"text/plain", @"text/html", @"application/json", @"text/javascript",nil];
}

@end

#pragma mark - NSObject+AFRequest

static char * const managersKey = "managersDict";


@implementation NSObject (AFRequest)


-(void)startRequestWithApi:(NSString *)api method:(AFRequestMethod)method params:(NSDictionary *)params showLoading:(BOOL)showLoading success:(requestResultBlock)success failed:(requestResultBlock)failed
{
    NSString * urlString =  [api stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    AFHTTPRequestOperationManager * manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer.timeoutInterval =  [DefaultHttpManager timeOutInterval];
    manager.responseSerializer.acceptableContentTypes =  [DefaultHttpManager acceptableContentTypes];
    
//    if ([api hasPrefix:@"https"])
//    {
//        AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModePublicKey];
//        securityPolicy.allowInvalidCertificates = YES;
//        manager.securityPolicy = securityPolicy;
//    }
    
    for (NSString *key in  [[DefaultHttpManager httpHeader] allKeys])
    {
        [manager.requestSerializer setValue:[DefaultHttpManager httpHeader][key] forHTTPHeaderField:key];
    }
    
    [self addManager:manager ofUrl:urlString];
    
    switch (method) {
        case GetMethod:
        {

            NSLog(@"【Request】:\n %@",urlString);
            NSLog(@"【Params】:\n %@",params);

            [manager GET:urlString parameters:params success:^(AFHTTPRequestOperation * operation, id responseObject) {
                
                NSLog(@"【Response】:\n %@",responseObject);

                [self removeManagerOfUrl:urlString];
                
                if ([responseObject isKindOfClass:[NSDictionary class]]) {

                    if (success)
                    {
                        success(responseObject);
                    }
                }else
                {
                    NSError *error = [NSError  errorWithDomain:@"不是json数据" code:URLRequestNotJson userInfo:nil];
                    if (failed) {
                        failed(@{@"error":error,
                                    @"response" :responseObject==nil?@"nil":responseObject});
                    }
                    
                    NSMutableDictionary * wrongResultDict= [ NSMutableDictionary  dictionaryWithCapacity:1];
                    if (responseObject) {
                        [wrongResultDict setObject:responseObject forKey:@"response"];
                    }else{
                        [wrongResultDict setObject:@"返回数据是空" forKey:@"response"];
                    }
                    if (success)
                    {
                        success(wrongResultDict);
                    }
                }
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                
                [self removeManagerOfUrl:urlString];
                NSLog(@"【Error】:\n %@",error);

                NSMutableDictionary * errorDict = [ NSMutableDictionary  dictionaryWithCapacity:2];
                if ([error code] == NSURLErrorCancelled) {
                    NSLog(@"取消了请求:%@",urlString);
                }
                if (error) {
                    [errorDict setObject:error forKey:@"error"];
                }
                if (operation.responseObject) {
                    [errorDict setObject:operation.responseObject forKey:@"response"];
                }
                if (failed) {
                    failed(errorDict);
                }
            }];
        }
            break;
        case PostMethod:
        {
            [manager POST:urlString parameters:params success:^(AFHTTPRequestOperation * operation, id responseObject) {
                [self removeManagerOfUrl:urlString];
                
                if ([responseObject isKindOfClass:[NSDictionary class]]) {
                    
                    if (success)
                    {
                        success(responseObject);
                    }
                }else
                {
                    NSError *error = [NSError  errorWithDomain:@"不是json数据" code:URLRequestNotJson userInfo:nil];
                    if (failed) {
                        failed(@{@"error":error,
                                 @"response" :responseObject==nil?@"nil":responseObject});
                    }
                    
                    NSMutableDictionary * wrongResultDict= [ NSMutableDictionary  dictionaryWithCapacity:1];
                    if (responseObject) {
                        [wrongResultDict setObject:responseObject forKey:@"response"];
                    }else{
                        [wrongResultDict setObject:@"返回数据是空" forKey:@"response"];
                    }
                    if (success)
                    {
                        success(wrongResultDict);
                    }
                }
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                
                [self removeManagerOfUrl:urlString];
                
                NSMutableDictionary * errorDict = [ NSMutableDictionary  dictionaryWithCapacity:2];
                if ([error code] == NSURLErrorCancelled) {
                    NSLog(@"取消了请求:%@",urlString);
                }
                if (error) {
                    [errorDict setObject:error forKey:@"error"];
                }
                if (operation.responseObject) {
                    [errorDict setObject:operation.responseObject forKey:@"response"];
                }
                if (failed) {
                    failed(errorDict);
                }
            }];

        }
        default:
            break;
    }
}

- (void)uploadImageWithApi:(NSString *)api image:(UIImage *)image imageKey:(NSString *)imageKey params:(NSDictionary *)params showLoading:(BOOL)showLoading success:(requestResultBlock)success failed:(requestResultBlock)failed
{
    NSString * urlString =  [api stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    NSData * imageData = UIImageJPEGRepresentation(image, 0.95);        //压缩
    NSString * filePath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:@"/tmp.png"];
    
    [[NSFileManager defaultManager] createFileAtPath:filePath contents:imageData attributes:nil];
    
    AFHTTPRequestOperationManager * manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer.timeoutInterval =  [DefaultHttpManager timeOutInterval];
    manager.responseSerializer.acceptableContentTypes =  [DefaultHttpManager acceptableContentTypes];
    
    for (NSString *key in  [[DefaultHttpManager httpHeader] allKeys])
    {
        [manager.requestSerializer setValue:[DefaultHttpManager httpHeader][key] forHTTPHeaderField:key];
    }
    
    NSURL *filePathURL = [NSURL fileURLWithPath:filePath];
    [self addManager:manager ofUrl:urlString];

    [manager POST:urlString parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
        [formData appendPartWithFileURL:filePathURL name:imageKey error:nil];
        
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self removeManagerOfUrl:urlString];
        
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            
            if (success)
            {
                success(responseObject);
            }
        }else
        {
            NSError *error = [NSError  errorWithDomain:@"不是json数据" code:URLRequestNotJson userInfo:nil];
            if (failed) {
                failed(@{@"error":error,
                         @"response" :responseObject==nil?@"nil":responseObject});
            }
            
            NSMutableDictionary * wrongResultDict= [ NSMutableDictionary  dictionaryWithCapacity:1];
            if (responseObject) {
                [wrongResultDict setObject:responseObject forKey:@"response"];
            }else{
                [wrongResultDict setObject:@"返回数据是空" forKey:@"response"];
            }
            if (success)
            {
                success(wrongResultDict);
            }
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [self removeManagerOfUrl:urlString];
        
        NSMutableDictionary * errorDict = [ NSMutableDictionary  dictionaryWithCapacity:2];
        if ([error code] == NSURLErrorCancelled) {
            NSLog(@"取消了请求:%@",urlString);
        }
        if (error) {
            [errorDict setObject:error forKey:@"error"];
        }
        if (operation.responseObject) {
            [errorDict setObject:operation.responseObject forKey:@"response"];
        }
        if (failed) {
            failed(errorDict);
        }
    }];

}

#pragma mark -


- (void)addManager:(AFHTTPRequestOperationManager*)manager ofUrl:(NSString *)urlString
{
    NSMutableDictionary * managerDict = objc_getAssociatedObject(self, &managersKey);
    if (!managerDict ) {
        managerDict = [NSMutableDictionary dictionaryWithCapacity:0];
    }
    [managerDict setObject:manager forKey:[self md5:urlString]];
    
    objc_setAssociatedObject(self, &managersKey, managerDict, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
//    NSLog(@"add : %@",urlString);
}

- (void)removeManagerOfUrl:(NSString *)urlString
{
    NSMutableDictionary * managerDict = objc_getAssociatedObject(self, &managersKey);
    if (managerDict)
    {
        [managerDict removeObjectForKey:[self md5:urlString]];
        objc_setAssociatedObject(self, &managersKey, managerDict, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
//    NSLog(@"remove : %@",urlString);

}

- (void)cancelRequestWithURLString:(NSString *)urlString
{
    NSMutableDictionary * managerDict = objc_getAssociatedObject(self, &managersKey);
    if (managerDict)
    {
        AFHTTPRequestOperationManager * manager = [managerDict objectForKey:[self md5:urlString]];
        if (manager) {
            [manager.operationQueue cancelAllOperations];
        }
        
        [self removeManagerOfUrl:urlString];
    }
}

- (void)cancelAllRequest
{
    NSMutableDictionary * managerDict = objc_getAssociatedObject(self, &managersKey);
    if (managerDict)
    {
        for (NSString * key in managerDict) {
            AFHTTPRequestOperationManager * manager = [managerDict objectForKey:key];
            if (manager) {
                [manager.operationQueue cancelAllOperations];
            }
        }
    }
    objc_setAssociatedObject(self, &managersKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)md5:(NSString *)string {
    if (string == nil) {
        
        return nil;
    }
    
    const char *cstr = [string UTF8String];
    
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    
    CC_MD5(cstr, (int)strlen(cstr), result);
    
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}


@end
