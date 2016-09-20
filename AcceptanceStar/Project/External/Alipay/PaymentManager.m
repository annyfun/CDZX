//
//  PaymentManager.m
//  ZDYK
//
//  Created by  YangShengchao on 14-5-20.
//  Copyright (c) 2014年 SCSD_TGO_TEAM. All rights reserved.
//

#import "PaymentManager.h"
#import "Order.h"
#import "DataSigner.h"
#import <AlipaySDK/AlipaySDK.h>

#define AlipayPartnerID                 @"23424123423"
#define AlipaySellerID                  @"5234213422@qq.com"
#define AlipayPartnerPrivateKey         @"MItYxA6IXxBylEN6yGx0soG1nun2F2DQIDAQAB"

@implementation PaymentManager
+ (void)payTheOrder:(NSString *)orderId            //订单id
         orderTitle:(NSString *)productName              //订单描述的标题
   orderDescription:(NSString *)productDescription        //订单描述正文
             amount:(NSString *)amount             //总金额
          partnerId:(NSString *)partnerId
          sellerId:(NSString *)sellerId
          privateKey:(NSString *)privateKey
         withParams:(NSDictionary *)params
            success:(AliPaySuccess)success
             failed:(AliPayFailed)failed {
    
    /*
     *生成订单信息及签名
     */
    //将商品信息赋予AlixPayOrder的成员变量
    Order *order = [[Order alloc] init];
    order.partner = partnerId;
    order.seller = sellerId;
    order.notifyURL = kAlipayNotifyUrl;//回调URL
    order.tradeNO = orderId; //订单ID（由商家自行制定）
    order.productName = productName; //商品标题
    order.productDescription = productDescription; //商品描述
    order.amount = amount; //商品价格
    order.service = @"mobile.securitypay.pay";
    order.paymentType = @"1";
    order.inputCharset = @"utf-8";
    order.itBPay = @"30m";
    order.showUrl = @"m.alipay.com";
    if ([NSDictionary isNotEmpty:params]) {
        [order.extraParams addEntriesFromDictionary:params];
    }
    
    //应用注册scheme,在AlixPayDemo-Info.plist定义URL types
    NSString *appScheme = kAppScheme;
    
    //将商品信息拼接成字符串
    NSString *orderSpec = [order description];
    NSLog(@"orderSpec = %@",orderSpec);
    
    //获取私钥并将商户信息签名,外部商户可以根据情况存放私钥和签名,只需要遵循RSA签名规范,并将签名字符串base64编码和UrlEncode
    id<DataSigner> signer = CreateRSADataSigner(privateKey);
    NSString *signedString = [signer signString:orderSpec];
    
    //将签名成功字符串格式化为订单字符串,请严格按照该格式
    NSString *orderString = nil;
    if (signedString != nil) {
        orderString = [NSString stringWithFormat:@"%@&sign=\"%@\"&sign_type=\"%@\"", orderSpec, signedString, @"RSA"];
        [[AlipaySDK defaultService] payOrder:orderString fromScheme:appScheme callback:^(NSDictionary *resultDic) {
            NSLog(@"reslut = %@",resultDic);
            if (9000 == [resultDic[@"resultStatus"] integerValue]) {
                if (success) {
                    success();
                }
            }
            else {
                if (failed) {
                    failed(@"支付失败");
                }
            }
        }];
    }
    else {
        if (failed) {
            failed(@"支付错误");
        }
    }
}

+ (void)payTheOrder:(NSString *)orderId            //订单id
         orderTitle:(NSString *)productName              //订单描述的标题
   orderDescription:(NSString *)productDescription        //订单描述正文
             amount:(NSString *)amount             //总金额
         withParams:(NSDictionary *)params
            success:(AliPaySuccess)success
             failed:(AliPayFailed)failed {
    [self payTheOrder:orderId orderTitle:productName orderDescription:productDescription amount:amount partnerId:AlipayPartnerID sellerId:AlipaySellerID privateKey:AlipayPartnerPrivateKey withParams:params success:success failed:failed];
}

@end
