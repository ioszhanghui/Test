//
//  GMRouterConfig.h
//  GMURLRouter
//
//  Created by 小飞鸟 on 2019/03/11.
//  Copyright © 2019 Gome. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GMRouterConfig : NSObject

extern NSString * const GMRouterParamterOriginUrl;//缓存的原始路径
extern NSString * const GMRouterParmterCompletion;//跳转时给的回调
extern NSString * const GMRouterParamterClass;//跳转时 class名
extern NSString * const GMRouterParamterParams;//跳转时传递的参数
extern NSString * const GMRouterParamterPath;//存储原始路径
@end

NS_ASSUME_NONNULL_END
