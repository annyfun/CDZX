//
//  EnumType.h
//  YSCKit
//
//  Created by  YangShengchao on 14-3-6.
//  Copyright (c) 2014年 yangshengchao. All rights reserved.
//

typedef NS_ENUM(NSInteger, GenderType) {
    GenderTypeNotSet = 0,
    GenderTypeMale,
    GenderTypeFeMale
};

typedef NS_ENUM(NSInteger, BackType) {
    BackTypeDefault = 0,
    BackTypeImage,
    BackTypeSliding,
    BackTypeDismiss NS_DEPRECATED_IOS(2_0, 3_0)
};

typedef NS_ENUM(NSInteger, RegexType) {
    RegexTypeEmail          = 0,
    RegexTypeMobilePhone,
    RegexTypeUserName,
    RegexTypePassword,
    RegexTypeNickName,
    RegexTypeIdentityCard,
    RegexTypeAllNumbers
};

typedef NS_ENUM(NSInteger, VersionCompareResult) {
    VersionCompareResultAscending = -1,
    VersionCompareResultSame = 0,
    VersionCompareResultDescending = 1
};

typedef NS_ENUM(NSInteger, AudioType) {
    AudioTypeStart = 0,
    AudioTypeMoreItem,
    AudioTypePanicSuccess,
    AudioTypeMore,
    AudioTypeMenuOpen,
    AudioTypeMenuClose,
    AudioTypeShare,
    AudioTypeHeartbeat,
    AudioTypePush,
    AudioTypeAddAlert
};

typedef NS_ENUM(NSInteger, ShareType) {
    ShareTypeWeiboSina = 1,     //新浪微博(分享+登陆)
    ShareTypeMobileQQ = 2,      //手机QQ(登陆)
    ShareTypeWeiXin = 3,        //微信(登陆)
    ShareTypeAlipay,            //暂时没有用!
    ShareTypeWeiboTencent,      //腾讯微博(分享)
    ShareTypeQQZone,            //QQ空间(分享)
    ShareTypeWechatSession,     //微信好友(分享)
    ShareTypeWechatTimeline,    //微信朋友圈(分享)
    ShareTypeWechatFavorite,    //微信收藏(分享)
    
};

typedef NS_ENUM(NSInteger, BannerType) {
    BannerTypeIndex         = 0,//默认什么都不做
    BannerTypeProduct       = 1,
    BannerTypeShop          = 2,
    BannerTypeSpecialSale   = 3,
    BannerTypeURL           = 4
};

typedef NS_ENUM(NSInteger, OpenType) {
    OpenTypeNormal = 0,
    OpenTypeWeiboSina = 1,
    OpenTypeWeiboTencent = 2,
    OpenTypeAlipay = 3,
    OpenTypeWeiXin = 4
};

typedef NS_ENUM(NSInteger, UserType) {
    UserTypeEmployee = 0,   //员工
    UserTypeDealer,         //经销商
    UserTypeVIPClient       //VIP客户
};


// 订单状态
typedef NS_ENUM(NSInteger, OrderStatusType) {
    OrderStatusTypeCancel           = 0,    //已取消
    OrderStatusTypeReadyToPay       = 10,   //待付款
    OrderStatusTypeAlreadyPaid      = 20,   //已付款
    OrderStatusTypeAlreadyShipped   = 30,   //已发货
    OrderStatusTypeAlreadySigned    = 40,   //已收货
    OrderStatusTypeReturning        = 45,   //买家申请退货
    OrderStatusTypeReturned         = 47,   //退货完成，已结束
    OrderStatusTypeReturnRefused    = 48,   //卖家拒绝退货
    OrderStatusTypeReturnFailed     = 49,   //退货失败
    OrderStatusTypeFinished         = 50,   //已完成，已评价 *
    OrderStatusTypeOver             = 60,   //已结束 *
    OrderStatusTypeUncommentable    = 65    //已结束，不可评价 *
};

//发票类型
typedef NS_ENUM(NSInteger, InvoiceType) {
    InvoiceTypeNormal = 1,
    InvoiceTypeVAT = 2
};

//报价平台类型
typedef NS_ENUM(NSInteger, PriceType) {
    PriceTypeBuy          = 1,    //买票信息
    PriceTypeSell         = 2,    //卖票信息
    PriceTypeQuotePrice   = 3,    //机构报价
    PriceTypeReSale       = 4,    //转贴信息
    PriceTypeRePurchase   = 5,    //回购信息
};

//发票类型
typedef NS_ENUM(NSInteger, InvoiceContentType) {
    InvoiceContentTypeMaterial  = 1, //耗材
    InvoiceContentTypeOffice    = 2, //办公用品
    InvoiceContentTypeProduct   = 3  //商品明细
};

//实物订单类型
typedef NS_ENUM(NSInteger, OrderFromType) {
    OrderFromTypeShoppingCart   = 1,  //来自购物车
    OrderFromTypeBuying         = 2   //来自商品详情立即购买
};

//消费记录类型
typedef NS_ENUM(NSInteger, ConsumeType) {
    ConsumeTypeAll          = 0,    //全部
    ConsumeTypeIncome       = 1,    //收入
    ConsumeTypeWithdrawal   = 2,    //提现
    ConsumeTypeBuySomething = 3     //买东西
};

/*  图片质量
 *  高质量：原图
 *  中等质量：原图大小的70%。最小宽度：480 最大宽度：720
 *  低质量：原图大小的50%。最小宽度：320 最大宽度：480
 */
typedef NS_ENUM(NSInteger, ImageQuality) {
    ImageQualityLow = 0,        //低质量图片
    ImageQualityNormal = 1,     //中等质量图片
    ImageQualityHigh = 2,       //高质量图片
    ImageQualityAuto = 10       //根据网络自动选择图片质量
};
