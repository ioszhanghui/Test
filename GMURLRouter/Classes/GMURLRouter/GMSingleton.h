
//
//  GMSingleton.h
//  GMURLRouter
//
//  Created by Gome on 2019/3/4.
//  Copyright © 2019年 Gome. All rights reserved.
//

// .h文件
#define GMSingletonH(name) + (instancetype)shared##name;
// .m文件
#define GMSingletonM(name) \
static id _instance; \
\
+ (instancetype)allocWithZone:(struct _NSZone *)zone \
{ \
static dispatch_once_t onceToken; \
dispatch_once(&onceToken, ^{ \
_instance = [super allocWithZone:zone]; \
}); \
return _instance; \
} \
\
+ (instancetype)shared##name \
{ \
static dispatch_once_t onceToken; \
dispatch_once(&onceToken, ^{ \
_instance = [[self alloc] init]; \
}); \
return _instance; \
} \
\
- (id)copyWithZone:(NSZone *)zone \
{ \
return _instance; \
}
