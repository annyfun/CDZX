//
//  PaymentManager.h
//  ZDYK
//
//  Created by  YangShengchao on 14-5-20.
//  Copyright (c) 2014年 SCSD_TGO_TEAM. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^AliPaySuccess)();
typedef void (^AliPayFailed)(NSString *errorMessage);

@interface PaymentManager : NSObject

+ (void)payTheOrder:(NSString *)orderId            //订单id
         orderTitle:(NSString *)productName              //订单描述的标题
   orderDescription:(NSString *)productDescription        //订单描述正文
             amount:(NSString *)amount             //总金额
          partnerId:(NSString *)partnerId
           sellerId:(NSString *)sellerId
         privateKey:(NSString *)privateKey
         withParams:(NSDictionary *)params
            success:(AliPaySuccess)success
             failed:(AliPayFailed)failed;

+ (void)payTheOrder:(NSString *)orderId            //订单id
         orderTitle:(NSString *)title              //订单描述的标题
   orderDescription:(NSString *)description        //订单描述正文
             amount:(NSString *)amount             //总金额
         withParams:(NSDictionary *)params
            success:(AliPaySuccess)success
             failed:(AliPayFailed)failed;

@end
