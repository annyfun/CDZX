//
//  UMengConstants.h
//  YSCKit
//
//  Created by  YangShengchao on 14-4-21.
//  Copyright (c) 2014年 yangshengchao. All rights reserved.
//

#ifndef YSCKit_UMengConstants_h
#define YSCKit_UMengConstants_h

#import "UMMobClick/MobClick.h"
#import "UMSocial.h"
#import "UMFeedback.h"

#import "UMSocialWechatHandler.h"
#import "UMSocialQQHandler.h"
#import "UMSocialSinaHandler.h"

#import "UMessage.h"

#pragma mark - Umeng param
//统一放在AppConfigManager中进行组装和判断
#define UMengParamValue(name,channel,version)   [MobClick getConfigParams:[[AppConfigManager sharedInstance] UMengParamName:(name) withChannel:(channel) andVersion:(version)]]


#pragma mark - Umeng Event Key
//首页事件统计
#define UMEventKeyHomeLogoImage                 @"HomeLogoImage"
#define UMEventKeyHomeSearchBox                 @"HomeSearchBox"
#define UMEventKeyHomeScanning                  @"HomeScanning"
#define UMEventKeyHomeBanner                    @"HomeBanner"
#define UMEventKeyHomeGroupBuying               @"HomeGroupBuying"
#define UMEventKeyHomeRecharge                  @"HomeRecharge"
#define UMEventKeyHomeBrand                     @"HomeBrand"
#define UMEventKeyHomeCoupon                    @"HomeCoupon"
#define UMEventKeyHomeAdvertising               @"HomeAdvertising"
#define UMEventKeyHomeAdvertising1              @"HomeAdvertising1"
#define UMEventKeyHomeAdvertising2              @"HomeAdvertising2"
#define UMEventKeyHomeAdvertising3              @"HomeAdvertising3"
#define UMEventKeyHomeAdvertising4              @"HomeAdvertising4"
#define UMEventKeyHomeRecommendBrand            @"HomeRecommendBrand"
#define UMEventKeyHomeOthersBuying              @"HomeOthersBuying"
#define UMEventKeyHomeRecommendProduct          @"HomeRecommendProduct"

//特卖专场
#define UMEventKeySpecialSaleList               @"SpecialSaleList"

//购物车
#define UMEventKeyShoppingCartEnter             @"ShoppingCartEnter"
#define UMEventKeyShoppingCartAccountButton     @"ShoppingCartAccountButton"
#define UMEventKeyShoppingCartSelectAll         @"ShoppingCartSelectAll"
#define UMEventKeyShoppingCartSelectSectionAll  @"ShoppingCartSelectSectionAll"
#define UMEventKeyShoppingCartSelectProduct     @"ShoppingCartSelectProduct"
#define UMEventKeyShoppingCartEdit              @"ShoppingCartEdit"
#define UMEventKeyShoppingCartNumber            @"ShoppingCartNumber"
#define UMEventKeyShoppingCartOrderProduct      @"ShoppingCartOrderProduct"

//分类
#define UMEventKeyCategoryLogoImage             @"CategoryLogoImage"
#define UMEventKeyCategorySearchBox             @"CategorySearchBox"
#define UMEventKeyCategoryScanning              @"CategoryScanning"
#define UMEventKeyCategoryProduct               @"CategoryProduct"
#define UMEventKeyCategoryBrand                 @"CategoryBrand"
#define UMEventKeyCategoryProductList           @"CategoryProductList"
#define UMEventKeyCategoryBrandList             @"CategoryBrandList"

//个人中心
#define UMEventKeyUserCenterConfig              @"UserCenterConfig"
#define UMEventKeyUserCenterAvatar              @"UserCenterAvatar"
#define UMEventKeyUserCenterLogin               @"UserCenterLogin"
#define UMEventKeyUserCenterAddress             @"UserCenterAddress"
#define UMEventKeyUserCenterProductOrder        @"UserCenterProductOrder"
#define UMEventKeyUserCenterOtherOrder          @"UserCenterOtherOrder"
#define UMEventKeyUserCenterMyCollection        @"UserCenterMyCollection"
#define UMEventKeyUserCenterBrowseHistory       @"UserCenterBrowseHistory"
#define UMEventKeyUserCenterMyCoupon            @"UserCenterMyCoupon"
#define UMEventKeyUserCenterContactUs           @"UserCenterContactUs"

//下拉刷新
#define UMEventKeyPullToRefresh                 @"PullToRefresh"
//通过其它APP激活
#define UMEventKeyReActiveByUrlScheme           @"ReActiveByUrlScheme"
//点击返回按钮
#define UMEventKeyBackViewController            @"BackViewController"
//返回上一级
#define UMEventKeyPopViewController             @"PopViewController"

//商品详情
#define UMEventKeyProductDetail                 @"ProductDetail"
#define UMEventKeyProductSNSShare               @"ProductSNSShare"
#define UMEventKeyProductCollection             @"ProductCollection"
#define UMEventKeyProductImages                 @"ProductImages"
#define UMEventKeyProductSelectSkuView          @"ProductSelectSkuView"
#define UMEventKeyProductCommentList            @"ProductCommentList"
#define UMEventKeyProductGoIntoShopIndex        @"ProductGoIntoShopIndex"
#define UMEventKeyProductShopCollection         @"ProductShopCollection"
#define UMEventKeyProductGotoShoppingCart       @"ProductGotoShoppingCart"
#define UMEventKeyProductAddToCart              @"ProductAddToCart"
#define UMEventKeyProductAddToCartSuccess       @"ProductAddToCartSuccess"
#define UMEventKeyProductBuyNow                 @"ProductBuyNow"
#define UMEventKeyProductBuyNowSuccess          @"ProductBuyNowSuccess"
#define UMEventKeyProductNumber                 @"ProductNumber"

//分享
#define UMEventKeyShareWeiboSina                @"ShareWeiboSina"
#define UMEventKeyShareWeiboTencent             @"ShareWeiboTencent"
#define UMEventKeyShareWechatSession            @"ShareWechatSession"
#define UMEventKeyShareWechatTimeline           @"ShareWechatTimeline"
#define UMEventKeyShareSuccess                  @"ShareSuccess"

//搜索
#define UMEventKeySearchInput                   @"SearchInput"
#define UMEventKeySearchHotKeyword              @"SearchHotKeyword"
#define UMEventKeySearchDoSearch                @"SearchDoSearch"       //BarButton Return
#define UMEventKeySearchHistoryKeyword          @"SearchHistoryKeyword"
#define UMEventKeySearchClearHistory            @"SearchClearHistory"
#define UMEventKeySearchResultDoSearch          @"SearchResultDoSearch" //BarButton Return
#define UMEventKeySearchResultBySortType        @"SearchResultBySortType" //Sold Price Comment
#define UMEventKeySearchResultShoppingCart      @"SearchResultShoppingCart"

//团购
#define UMEventKeyGroupBuyingHotKeyword         @"GroupBuyingHotKeyword"
#define UMEventKeyGroupBuyingProduct            @"GroupBuyingProduct"

//扫码
#define UMEventKeyScanningRecognizeError        @"ScanningRecognizeError"
#define UMEventKeyScanningRecognizeOK           @"ScanningRecognizeOK"
#define UMEventKeyScanningFindNoResult          @"ScanningFindNoResult"
#define UMEventKeyScanningNoResultDoSearch      @"ScanningNoResultDoSearch"

//结算中心
#define UMEventKeyPaymentCenterAddress          @"PaymentCenterAddress"
#define UMEventKeyPaymentCenterInvoiceType      @"PaymentCenterInvoiceType"
#define UMEventKeyPaymentCenterUseCoupon        @"PaymentCenterUseCoupon"
#define UMEventKeyPaymentCenterSubmit           @"PaymentCenterSubmit"
#define UMEventKeyPaymentCenterSubmitSuccess    @"PaymentCenterSubmitSuccess"//成功提交订单 计算变量
#define UMEventKeyPaymentCenterAlipaySuccess    @"PaymentCenterAlipaySuccess"  //支付宝支付成功

//登陆
#define UMEventKeyLoginSendCaptcha              @"LoginSendCaptcha"
#define UMEventKeyLoginShowPassword             @"LoginShowPassword"
#define UMEventKeyLoginResetPassword            @"LoginResetPassword"
#define UMEventKeyLoginDoLogin                  @"LoginDoLogin"
#define UMEventKeyLoginDoRegister               @"LoginDoRegister"
#define UMEventKeyLoginSinaWeibo                @"LoginSinaWeibo"
#define UMEventKeyLoginTencentQQ                @"LoginTencentQQ"
#define UMEventKeyLoginWeiXin                   @"LoginWeiXin"
#define UMEventKeyLoginSNSSuccess               @"LoginSNSSuccess"
#define UMEventKeyLoginSuccess                  @"LoginSuccess"

//设置
#define UMEventKeyConfigDownloadImage           @"ConfigDownloadImage"
#define UMEventKeyConfigClearCaches             @"ConfigClearCaches"
#define UMEventKeyConfigChangePassword          @"ConfigChangePassword"
#define UMEventKeyConfigFeedBack                @"ConfigFeedBack"
#define UMEventKeyConfigSubmitFeedBack          @"ConfigSubmitFeedBack"
#define UMEventKeyConfigAbout                   @"ConfigAbout"
#define UMEventKeyConfigLogout                  @"ConfigLogout"

//实物订单
#define UMEventKeyMyOrderProductDetail          @"MyOrderProductDetail"
#define UMEventKeyMyOrderDetail                 @"MyOrderDetail"
#define UMEventKeyMyOrderCommentProduct         @"MyOrderCommentProduct"
#define UMEventKeyMyOrderConfirmReceipt         @"MyOrderConfirmReceipt"
#define UMEventKeyMyOrderPayNow                 @"MyOrderPayNow"
#define UMEventKeyMyOrderCancellOrder           @"MyOrderCancellOrder"

//其它订单
#define UMEventKeyOtherOrderPayNow              @"OtherOrderPayNow"
#define UMEventKeyOtherOrderCancellOrder        @"OtherOrderCancellOrder"

//我的收藏
#define UMEventKeyMyCollectionSelectAll         @"MyCollectionSelectAll"
#define UMEventKeyMyCollectionShoppingCart      @"MyCollectionShoppingCart"
#define UMEventKeyMyCollectionDelete            @"MyCollectionDelete"

//浏览记录
#define UMEventKeyBrowseHistorySelectAll        @"BrowseHistorySelectAll"
#define UMEventKeyBrowseHistoryShoppingCart     @"BrowseHistoryShoppingCart"
#define UMEventKeyBrowseHistoryDelete           @"BrowseHistoryDelete"

#endif




