//
//  UrlConstants.h
//  YSCKit
//
//  Created by  YangShengchao on 14-2-13.
//  Copyright (c) 2014年  YangShengchao. All rights reserved.
//  FORMATED!
//

#ifndef YSCKit_UrlConstants_h
#define YSCKit_UrlConstants_h

/**
 *  定义各种正式和测试的接口地址
 */
#pragma mark - Config Values
//UMeng参数值优先级 > 本地参数值
#define kResPathAppBaseUrl        @"http://www.yhcd.net"
#define kResPathAppResUrl         [[AppConfigManager sharedInstance] valueOfAppConfig:@"kResPathAppResUrl"]
#define kCheckNewVersionUrl       @"http://chat.54blues.com/app/update" //版本更新地址(独立于接口直接访问的url)
#define kCheckNewVersionType      @"0"//0-不更新 1-通过接口更新 2-通过UMeng在线配置更新
#define kAlipayNotifyUrl          @"http://www.yhcd.net/enpay/notify_url/type/alipay"//@"http://chat.54blues.com/pay/notify_url/type/alipay"
#define kLogManageType            @"0"      //0-不记录日志 1-要记录日志
//UMeng在线参数值
#define kNewVersionModel          @""  //UMeng在线配置的软件升级参数
#define kAppChannel               @""       //当前发布的渠道 //
#define kUMAppKey                 @"57dfe4e0e0f55af70d003b97"//1369844126@qq.com showme123
//本地配置文件参数值
#define kBaiduMapKey              [[AppConfigManager sharedInstance] valueOfLocalConfig:@"kBaiduMapKey"]      //百度地图的key

/**
 *  接口地址
 */
#pragma mark - 接口访问地址

//用户相关接口
#define kResPathAppExternalLogin                @""
#define kResPathAppGetServerTime                @""

#define kResPathAppUserRegister                 @"user/register"
#define kResPathAppUserResetPassword            @"user/modifypwd"//TODO:
#define kResPathAppUserLogin                    @"user/login"
#define kResPathAppUserDetail                   @"user/detail"
#define kResPathAppUserThirdLogin               @"user/third_login"
#define kResPathAppUserThirdRegister            @"user/third_register"
#define kResPathAppUserEditPassword             [@"user/editPassword/token" stringByAppendingPathComponent:TOKEN]
#define kResPathAppUserEditDetail               [@"user/edit_detail/token" stringByAppendingPathComponent:TOKEN]
#define kResPathAppUserChangePhone              [@"user/change_phone/token" stringByAppendingPathComponent:TOKEN]
#define kResPathAppUserAccreditation            [@"user/accreditation/token" stringByAppendingPathComponent:TOKEN]
#define kResPathAppUserFriendList               [@"user/friend_list/token" stringByAppendingPathComponent:TOKEN]
#define kResPathAppUserEditGroup                [@"user/editGroup/token" stringByAppendingPathComponent:TOKEN]

#define kResPathAppUserFriendListWithGroup      [@"user/friendListWithGroup/token" stringByAppendingPathComponent:TOKEN]
#define kResPathAppUserGroup                    [@"user/group/token" stringByAppendingPathComponent:TOKEN]
#define kResPathAppUserDelGroup                 [@"user/del_group/token" stringByAppendingPathComponent:TOKEN]
#define kResPathAppUserRenameGroup              [@"user/rename_group/token" stringByAppendingPathComponent:TOKEN]
#define kResPathAppUserDeleteFriend             [@"user/deleteFriend/token" stringByAppendingPathComponent:TOKEN]
#define kResPathAppUserJuBao                    [@"user/jubao/token" stringByAppendingPathComponent:TOKEN]
#define kResPathAppUserApplyAddFriend           [@"user/applyAddFriend/token" stringByAppendingPathComponent:TOKEN]
#define kResPathAppUserSearch                   [@"user/search/token" stringByAppendingPathComponent:TOKEN]
#define kResPathAppUserAddRemark                [@"user/addRemark/token" stringByAppendingPathComponent:TOKEN]

#define kResPathAppCityIndex                    @"city/index"
#define kResPathAppSlideIndex                   @"slide/index"
#define kResPathAppSlideGet                     @"slide/get"
#define kResPathAppPageIndex                    @"page/index"
#define kResPathAppPageHtml                     @"page/html"
#define kResPathAppToolPhoneVerify              @"tool/phone_verify"
#define kResPathAppCollectIndex                 [@"collect/index/token" stringByAppendingPathComponent:TOKEN]
#define kResPathAppCollectMyCollect             [@"collect/mycollect/token" stringByAppendingPathComponent:TOKEN]
#define kResPathAppCollectMyAdd                 [@"collect/myadd/token" stringByAppendingPathComponent:TOKEN]
#define kResPathAppMomentsIndex                 [@"moments/index/token" stringByAppendingPathComponent:TOKEN]
#define kResPathAppMomentsDel                   [@"moments/del/token" stringByAppendingPathComponent:TOKEN]
#define kResPathAppMomentsAdd                   [@"moments/add/token" stringByAppendingPathComponent:TOKEN]
#define kResPathAppMomentsFacePic               [@"moments/facepic/token" stringByAppendingPathComponent:TOKEN]
#define kResPathAppMomentsLike                  [@"moments/like/token" stringByAppendingPathComponent:TOKEN]
#define kResPathAppMomentsReview                [@"moments/review/token" stringByAppendingPathComponent:TOKEN]
#define kResPathAppMomentsDelRevie              [@"moments/del_review/token" stringByAppendingPathComponent:TOKEN]
#define kResPathAppMessageCount                 [@"moments/getMsgCount/token" stringByAppendingPathComponent:TOKEN]

#define kResPathAppShiborIndex                  @"shibor/index"
#define kResPathAppBankIndex                    @"bank/index"
#define kResPathAppBankList                     @"bank/bank_list"
#define kResPathAppCourtIndex                   [@"Court/index/token" stringByAppendingPathComponent:TOKEN]
#define kResPathAppCourtFollow                  [@"Court/follow/token" stringByAppendingPathComponent:TOKEN]
#define kResPathAppCourtMy                      [@"Court/my/token" stringByAppendingPathComponent:TOKEN]
#define kResPathAppCourtDel                     [@"Court/del/token" stringByAppendingPathComponent:TOKEN]
#define kResPathAppCourtSearchMy                [@"Court/searchMy/token" stringByAppendingPathComponent:TOKEN]


#define kResPathAppCreateRechargeOrder          [@"ticket/CreateRechargeOrder/token" stringByAppendingPathComponent:TOKEN]

#define kResPathAppPayIndex                     [@"pay/index/token" stringByAppendingPathComponent:TOKEN]

#define kResPathAppBondBuy                      @"bond/buy"
#define kResPathAppBondBuyDetail                @"bond/buy_detail"
#define kResPathAppBondBuyAdd                   [@"bond/buy_add/token" stringByAppendingPathComponent:TOKEN]
#define kResPathAppBondSell                     [@"bond/sell2/token" stringByAppendingPathComponent:TOKEN]
#define kResPathAppBondSellDetail               @"bond/sell_detail"
#define kResPathAppBondSellAdd                  [@"bond/sell_add/token" stringByAppendingPathComponent:TOKEN]
#define kResPathAppBondResale                   @"bond/resale"
#define kResPathAppBondResaleDetail             @"bond/resale_detail"
#define kResPathAppBondResaleAdd                [@"bond/resale_add/token" stringByAppendingPathComponent:TOKEN]
#define kResPathAppBondRepurchase               @"bond/repurchase"
#define kResPathAppBondRepurchaseDetail         @"bond/repurchase_detail"
#define kResPathAppBondRepurchaseAdd            [@"bond/repurchase_add/token" stringByAppendingPathComponent:TOKEN]
#define kResPathAppBondCompany                  @"bond/company"
#define kResPathAppBondCompanyDetail            @"bond/company_detail"
#define kResPathAppBondCompanyAdd               [@"bond/company_add/token" stringByAppendingPathComponent:TOKEN]
#define kResPathAppBondComplete                 [@"bond/complete/token" stringByAppendingPathComponent:TOKEN]
#define kResPathAppBondViewSellInfo             [@"bond/view_sell_info/token" stringByAppendingPathComponent:TOKEN]
#define kResPathAppBondElectricAdd              [@"bond/electric_add/token" stringByAppendingPathComponent:TOKEN]
#define kResPathAppBondElectricBuy              [@"bond/eletric_buy/token" stringByAppendingPathComponent:TOKEN]
#define kResPathAppBondElectricOrder              [@"bond/bondorder/token" stringByAppendingPathComponent:TOKEN]
#define kResPathAppCaiShuiIndex                 @"caishui/index"
#define kResPathAppBankSXMyList                 [@"banksx/my_list/token" stringByAppendingPathComponent:TOKEN]
#define kResPathAppBankSXBankList               [@"banksx/bank_list/token" stringByAppendingPathComponent:TOKEN]
#define kResPathAppBankSXMyAdd                  [@"banksx/my_add/token" stringByAppendingPathComponent:TOKEN]
#define kResPathAppBankSXMyDel                  [@"banksx/my_del/token" stringByAppendingPathComponent:TOKEN]
#define kResPathAppBankSXMyUpdate               [@"banksx/my_update/token" stringByAppendingPathComponent:TOKEN]


/**
 *  定义网络POST提交、GET提交、页面间传递的参数
 */
#pragma mark - Param Name of POST & GET

#define kParamSecretKey                     @"ajsiwe2^%436486&%$#?><D.S,JKDFH><{})09"  //定义参数‘signature’加密的秘钥
#define kParamVersionValue                  @"1.0"            //设置默认接口版本号
#define kParamFromValue                     @"ios"            //设置接口访问来源:ios、android、wap

//常用参数命名
#define kParamTitle                         @"title"
#define kParamUrl                           @"url"
#define kParamEmail                         @"email"
#define kParamTrue                          @"true"
#define kParamFalse                         @"false"
#define kParamOpenId                        @"openId"
#define kParamOpenType                      @"openType"
#define kParamUserName                      @"userName"
#define kParamAvatarUrl                     @"avatarUrl"
#define kParamComment                       @"comment"
#define kParamDays                          @"days"
#define kParamToken                         @"token"
#define kParamRate                          @"rate"
#define kParamGender                        @"gender"                       //性别
#define kParamAddress                       @"address"                      //用户地址
#define kParamUserFrom                      @"userFrom"                     //第三方用户来源
#define kParamPassword                      @"password"                     //密码
#define kParamCaptcha                       @"captcha"                      //验证码
#define kParamValue                         @"value"
#define kParamName                          @"name"
#define kParamUserId                        @"userId"                       //平台内部用户唯一编号
#define kParamNickName                      @"nickname"                     //昵称
#define kParamRealName                      @"realName"                     //真实姓名
#define kParamBirthday                      @"birthday"                     //生日的时间戳
#define kParamQQ                            @"QQ"
#define kParamMSN                           @"MSN"
#define kParamNewPassword                   @"newPassword"                  //新密码
#define kParamOldPassword                   @"oldPassword"                  //旧密码
#define kParamPageSize                      @"pagesize"
#define kParamKeywords                      @"keywords"
#define kParamPageIndex                     @"page"
#define kParamIndex                         @"index"
#define kParamLastId                        @"lastId"
#define kParamCollectionId                  @"collectionId"
#define kParamBackType                      @"backType"
#define kParamFilterType                    @"filterType"
#define kParamSignature                     @"signature"
#define kParamVersion                       @"version"
#define kParamUdid                          @"udid"
#define kParamFrom                          @"from"
#define kParamAppId                         @"appId"
#define kParamSendType                      @"sendType"
#define kParamType                          @"type"
#define kParamNumber                        @"number"
#define kParamShopName                      @"shopName"
#define kParamSearchKey                     @"searchKey"
#define kParamSortType                      @"sortType"
#define kParamIsAsc                         @"isAsc"
#define kParamIsGroupBuy                    @"isGroupBuy"
#define kParamMethod                        @"method"
#define kParamParams                        @"params"
#define kParamTableViewCell                 @"tableViewCell"
#define kParamAdd                           @"add"
#define kParamEdit                          @"edit"
#define kParamEnableDownloadImage           @"EnableDownloadImage"
#define kParamSelectedIndex                 @"selectedIndex"
#define kParamNotificationName              @"notificationName"
#define kParamKind                          @"kind"
#define kParamPrice                         @"price"
#define kParamPriceType                     @"priceType"
#define kParamDate                          @"date"
#define kParamPage                          @"page"
#define kParamClass                         @"class"
#define kParamVerify                        @"verify"
#define kParamModel                         @"model"
#define kParamSex                           @"sex"
#define kParamAge                           @"age"
#define kParamCompany                       @"company"
#define kParamPosition                      @"position"
#define kParamBlock                         @"block"
#define kParamShowEdit                      @"showEdit"


//本项目相关的参数
#define kParamAttr                          @"attr"
#define kParamIsDetail                      @"isDetail"


#pragma mark - 收货地址相关参数
#define kParamAddressId                     @"addressId"                    //地址Id
#define kParamProvince                      @"province"
#define kParamCity                          @"city"
#define kParamCounty                        @"county"
#define kParamAddressModel                  @"addressModel"
#define kParamShipName                      @"shipName"
#define kParamProvinceId                    @"provinceId"
#define kParamCityId                        @"cityId"
#define kParamAreaId                        @"areaId"
#define kParamDetailAddress                 @"detailAddress"
#define kParamPostCode                      @"postCode"
#define kParamPhoneNumber                   @"phoneNumber"
#define kParamPhone                         @"phone"
#define kParamIsDefault                     @"isDefault"
#define kParamLongitude                     @"longitude"
#define kParamLatitude                      @"latitude"

#endif
