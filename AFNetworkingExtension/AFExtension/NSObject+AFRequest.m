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

+ (NSString *)base64String:(NSString *)str;

@end

@implementation DefaultHttpManager

+ (NSDictionary *)httpHeader
{

    /**
     2f6cebf8-ed1e-11e5-b7ad-acbc32acde63
     1ee28ee1-3036-4828-a98a-c12a053b5bde
     */
    NSMutableDictionary * httpHeader = [NSMutableDictionary dictionaryWithCapacity:0];
    //如果需要token 或其他头部设置请自己添加
    NSString * str = @"2f6cebf8-ed1e-11e5-b7ad-acbc32acde63:1ee28ee1-3036-4828-a98a-c12a053b5bde";
    NSString * basic = [DefaultHttpManager base64String:str];
    [httpHeader setObject:[NSString stringWithFormat:@"Basic %@",basic] forKey:@"Authorization"];
    return httpHeader;
}

+ (CGFloat)timeOutInterval
{
    return 15.0f;
}

+ (NSSet *)acceptableContentTypes
{
   return [NSSet setWithObjects: @"text/plain", @"text/html", @"application/json", @"text/javascript",@"image/jpeg",nil];
}

+ (NSString *)base64String:(NSString *)str
{
    NSData *theData = [str dataUsingEncoding: NSASCIIStringEncoding];
    const uint8_t* input = (const uint8_t*)[theData bytes];
    NSInteger length = [theData length];
    
    static char table[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
    
    NSMutableData* data = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
    uint8_t* output = (uint8_t*)data.mutableBytes;
    
    NSInteger i;
    for (i=0; i < length; i += 3) {
        NSInteger value = 0;
        NSInteger j;
        for (j = i; j < (i + 3); j++) {
            value <<= 8;
            
            if (j < length) {
                value |= (0xFF & input[j]);
            }
        }
        
        NSInteger theIndex = (i / 3) * 4;
        output[theIndex + 0] =                    table[(value >> 18) & 0x3F];
        output[theIndex + 1] =                    table[(value >> 12) & 0x3F];
        output[theIndex + 2] = (i + 1) < length ? table[(value >> 6)  & 0x3F] : '=';
        output[theIndex + 3] = (i + 2) < length ? table[(value >> 0)  & 0x3F] : '=';
    }
    
    return [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
}


@end

#pragma mark - NSObject+AFRequest

static char * const tasksKey = "tasksDict";


@implementation NSObject (AFRequest)

- (void)startRequestWithApi:(NSString *)api method:(AFRequestMethod)method params:(NSDictionary*)params success:(requestResultBlock)success failed:(requestResultBlock)failed
{
    [self startRequestWithApi:api method:method params:params success:success failed:failed respondMethod:AFSerializeTypeJson];
}

-(void)startRequestWithApi:(NSString *)api method:(AFRequestMethod)method params:(NSDictionary *)params success:(requestResultBlock)success failed:(requestResultBlock)failed  respondMethod:(AFSerializeType)serializeType
{
    NSString * urlString =  [api stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    AFHTTPSessionManager * manager = [AFHTTPSessionManager manager];
    
    switch (serializeType) {
        case AFSerializeTypeHttp:
        {
            manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        }
            break;
        case AFSerializeTypeJson:
        {
            manager.responseSerializer = [AFJSONResponseSerializer serializer];
            
        }
            break;
        default:
            break;
    }
    
    manager.responseSerializer.acceptableContentTypes = [DefaultHttpManager acceptableContentTypes];
    if ([api hasPrefix:@"https"])
    {
        manager.securityPolicy.allowInvalidCertificates = YES;
    }

    for (NSString *key in  [[DefaultHttpManager httpHeader] allKeys])
    {
        if([DefaultHttpManager httpHeader][key])
        {
            [manager.requestSerializer setValue:[DefaultHttpManager httpHeader][key] forHTTPHeaderField:key];
        }
    }

   
    NSURLSessionDataTask * task;
    switch (method) {
        case GetMethod:
        {
            NSLog(@"【GET】:\n %@",urlString);
            NSLog(@"【Params】:\n %@",params);
            
            task = [manager GET:urlString parameters:params progress:^(NSProgress * _Nonnull downloadProgress){
                
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                
                [self removeManagerOfUrl:urlString];
                
                NSLog(@"【Response】:\n %@",responseObject);
                
                if (success)
                {
                    success(task,responseObject);
                }

            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                
                [self removeManagerOfUrl:urlString];

                NSLog(@"【Error】:\n %@",error);
                if ([error code] == NSURLErrorCancelled) {
                    NSLog(@"取消了请求:%@",urlString);
                }
                
                if (failed) {
                    failed(task,@{@"error":error});
                }
            }];
          
        }
            break;
            
        case PostMethod:
        case PostMethod_Json:
        {
            NSLog(@"【POST】:\n %@",urlString);
            NSLog(@"【Params】:\n %@",params);
            
            task =  [manager POST:urlString parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {

            } progress:^(NSProgress * _Nonnull uploadProgress) {
                
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                
                [self removeManagerOfUrl:urlString];

                NSLog(@"【Response】:\n %@",responseObject);
                if (success)
                {
                    success(task,responseObject);
                }
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                
                [self removeManagerOfUrl:urlString];

                NSLog(@"【Error】:\n %@",error);
                if ([error code] == NSURLErrorCancelled) {
                    NSLog(@"取消了请求:%@",urlString);
                }
                
                if (failed) {
                    failed(task,@{@"error":error});
                }
            }];
            
            break;
        }
        case PostMethod_Form:
        {
            NSLog(@"【POST】:\n %@",urlString);
            NSLog(@"【Params】:\n %@",params);
            
            //表单
            [manager.requestSerializer setValue:@"application/x-www-form-urlencoded"  forHTTPHeaderField:@"Content-Type"];
            
            [manager  POST:urlString parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                
                [self removeManagerOfUrl:urlString];
                
                NSLog(@"【Response】:\n %@",responseObject);
                if (success)
                {
                    success(task,responseObject);
                }
                
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                
                [self removeManagerOfUrl:urlString];
                
                NSLog(@"【Error】:\n %@",error);
                if ([error code] == NSURLErrorCancelled) {
                    NSLog(@"取消了请求:%@",urlString);
                }
                
                if (failed) {
                    failed(task,@{@"error":error});
                }
            }];
            
            break;
        }
        default:
            break;
    }
    
    [self addTask:task ofUrl:urlString];
}

- (void)uploadImageWithApi:(NSString *)api image:(UIImage *)image imageKey:(NSString *)imageKey params:(NSDictionary *)params success:(requestResultBlock)success failed:(requestResultBlock)failed
{
    
    
    NSString * urlString =  [api stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSData * imageData = UIImageJPEGRepresentation(image, 0.95);        //压缩
    NSString * fileName = @"tmp.png";   //本地文件的名字。可以用时间戳
    NSString * filePath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingFormat:@"/%@",fileName];
    [[NSFileManager defaultManager] createFileAtPath:filePath contents:imageData attributes:nil];

    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:urlString parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileURL:[NSURL fileURLWithPath:filePath] name:imageKey fileName:fileName mimeType:@"image/png" error:nil];
    } error:nil];

    AFHTTPSessionManager * manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [DefaultHttpManager acceptableContentTypes];
    if ([api hasPrefix:@"https"])
    {
        manager.securityPolicy.allowInvalidCertificates = YES;
    }
    for (NSString *key in  [[DefaultHttpManager httpHeader] allKeys])
    {
        if([DefaultHttpManager httpHeader][key])
        {
            [manager.requestSerializer setValue:[DefaultHttpManager httpHeader][key] forHTTPHeaderField:key];
        }
    }

    NSLog(@"【POST】:\n %@",urlString);
    NSLog(@"【Params】:\n %@",params);

    NSURLSessionUploadTask *uploadTask = [manager uploadTaskWithStreamedRequest:request progress:^(NSProgress * _Nonnull uploadProgress) {
        
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [progressView setProgress:uploadProgress.fractionCompleted];
//        });
        
    } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        
        [self removeManagerOfUrl:urlString];

        if (error) {
            NSLog(@"【Error】:\n %@",error);
            if ([error code] == NSURLErrorCancelled) {
                NSLog(@"取消了请求:%@",urlString);
            }
            
            if (failed) {
                failed(uploadTask,@{@"error":error});
            }
        
        } else {
            
            NSLog(@"【Response】:\n %@",responseObject);
            
            if (success)
            {
                success(uploadTask,responseObject);
            }
        }
    }];
    [self addTask:uploadTask ofUrl:urlString];
}

#pragma mark -


- (void)addTask:(NSURLSessionDataTask *)task ofUrl:(NSString *)urlString
{
    if (!task)
    {
        return;
    }
    NSMutableDictionary * taskDict = objc_getAssociatedObject(self, &tasksKey);
    if (!taskDict ) {
        taskDict = [NSMutableDictionary dictionaryWithCapacity:0];
    }
    [taskDict setObject:task forKey:[self md5:urlString]];
    
    objc_setAssociatedObject(self, &tasksKey, taskDict, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
}

- (void)removeManagerOfUrl:(NSString *)urlString
{
    NSMutableDictionary * taskDict = objc_getAssociatedObject(self, &tasksKey);
    if (taskDict)
    {
        [taskDict removeObjectForKey:[self md5:urlString]];
        objc_setAssociatedObject(self, &tasksKey, taskDict, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

- (void)cancelRequestWithURLString:(NSString *)urlString
{
    NSMutableDictionary * taskDict = objc_getAssociatedObject(self, &tasksKey);
    if (taskDict)
    {
        NSURLSessionDataTask * task = [taskDict objectForKey:[self md5:urlString]];
        if (task) {
            [task cancel];
        }
        
        [self removeManagerOfUrl:urlString];
    }
}

- (void)cancelAllRequest
{
    NSMutableDictionary * taskDict = objc_getAssociatedObject(self, &tasksKey);
    if (taskDict)
    {
        for (NSString * key in taskDict) {
            NSURLSessionDataTask * task = [taskDict objectForKey:key];
            if (task) {
                [task cancel];
            }
        }
    }
    objc_setAssociatedObject(self, &tasksKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
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
