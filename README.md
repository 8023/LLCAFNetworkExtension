# LLCAFNetworkExtension

#### Config

#### GET

* Response Serialize Json

	```
    [self startRequestWithApi:@"http://test.com/api"
                       method:GetMethod params:@{@"param":@"testParam"}
                      success:^(NSURLSessionDataTask * task ,id result) {}
                       failed:^(NSURLSessionDataTask * task ,id result) {}
     ];
	```
	
	or
	
	```
	 [self startRequestWithApi:@"http://hylapi.yuandalu.com/banner"
                       method:GetMethod params:nil
                      success:^(NSURLSessionDataTask * task ,id result) {}
                       failed:^(NSURLSessionDataTask * task ,id result) {}
                respondMethod:AFSerializeTypeJson
     ];

	```

* Response Serialize Http

	```
	    [self startRequestWithApi:@"http://test.com/api"
                       method:GetMethod
                       params:nil
                      success:^(NSURLSessionDataTask * task ,id result) {
                          
                          NSHTTPURLResponse * response = (NSHTTPURLResponse *) task.response;

                      } failed:^(NSURLSessionDataTask * task ,id result) { }
                respondMethod:AFSerializeTypeHttp
     ];

	```

#### POST