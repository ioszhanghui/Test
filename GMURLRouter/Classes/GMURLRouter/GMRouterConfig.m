//
//  GMRouterConfig.m
//  GMURLRouter
//
//  Created by 小飞鸟 on 2019/03/11.
//  Copyright © 2019 Gome. All rights reserved.
//

#import "GMRouterConfig.h"

@implementation GMRouterConfig

NSString * const GMRouterParamterOriginUrl = @"GMRouterParamterOriginUrl";//缓存的原始路径
NSString * const GMRouterParmterCompletion = @"GMRouterParmterCompletion";//跳转时给的回调
NSString * const GMRouterParamterClass = @"GMRouterParamterClass";//跳转时 class名
NSString * const GMRouterParamterParams = @"GMRouterParamterParams";//跳转时传递的参数
NSString * const GMRouterParamterPath = @"GMRouterParamterPath";//存储原始路径

@end
