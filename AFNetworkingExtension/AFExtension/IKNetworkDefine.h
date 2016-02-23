//
//  IKNetworkDefine.h
//  IKNetworkService
//
//  Created by LLC on 16/2/19.
//  Copyright © 2016年 LLC. All rights reserved.
//

#ifndef IKNetworkDefine_h
#define IKNetworkDefine_h


#if DEBUG

#define _SERVER_IP              @"http://hylapi.yuandalu.com"       //测试服务器

#else

#define _SERVER_IP              @"http://hylapi.yuandalu.com"        //正式服务器

#endif



#pragma mark - 

#define _REQUEST_GET_REGION   [NSString stringWithFormat:@"%@/region",_SERVER_IP]

#define _REQUEST_GET_BANNER   [NSString stringWithFormat:@"%@/banner",_SERVER_IP]


#endif /* IKNetworkDefine_h */
