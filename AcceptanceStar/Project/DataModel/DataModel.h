//
//  DataModel.h
//  YSCKit
//
//  Created by  YangShengchao on 14-4-29.
//  Copyright (c) 2014年 yangshengchao. All rights reserved.
//

#import "YSCBaseModel.h"

#pragma mark - 数组映射关系

@protocol NewVersionModel           @end

@protocol BondBuyModel              @end
@protocol BondSellModel             @end
@protocol QuotePriceModel           @end
@protocol BondReSellModel           @end
@protocol BondRePurchaseModel       @end
@protocol ShiBorModel               @end
@protocol BankModel                 @end

@protocol UserModel                 @end
@protocol CityIndexModel            @end
@protocol SlideIndexModel           @end
@protocol PageIndexModel            @end
@protocol MyCollectAddModel         @end
@protocol ReviewModel               @end
@protocol LikesUserModel            @end
@protocol MomentsIndexModel         @end
@protocol BankIndexModel            @end
@protocol UserFriendModel           @end

@protocol BannerModel               @end
@protocol CommonItemModel           @end
@protocol ImageModel                @end

@protocol ASCityModel               @end
@protocol ASProvinceModel           @end
@protocol ASProvince1Model          @end

@protocol CourtIndexModel           @end
@protocol CourtMyModel              @end
@protocol VerifyStatusModel         @end
@protocol UserGroupModel            @end
@protocol CreateOrderModel          @end
@protocol CaiShuiModel              @end


#pragma mark - 公共model需要用到的class声明

/**
 *  要使用的model在本类里
 */
@class ImageModel, TestModel, ReviewModel, ASCityModel, ASProvinceModel;




#pragma mark - 公共model定义

//新版本描述模型
@interface NewVersionModel : BaseDataModel

@property (nonatomic, strong) NSString *versionCode;        //1.4.17
@property (nonatomic, strong) NSString *versionDescription; //新版本描述
@property (nonatomic, assign) BOOL isForced;                //是否强制升级
@property (nonatomic, strong) NSString *downloadUrl;        //plist文件的url地址 or appstore's url

@end


//买票信息
@interface BondBuyModel : BaseDataModel
@property (nonatomic, strong) NSString *id;
@property (nonatomic, strong) NSString *kind;//银行汇票  票据种类
@property (nonatomic, strong) NSString *city;//北京
@property (nonatomic, strong) NSString *attr;//电子票    票据属性
@property (nonatomic, strong) NSString *jsonClass;//class 其它  承兑行类型
@property (nonatomic, strong) NSNumber *price;
@property (nonatomic, strong) NSString *rate;
@property (nonatomic, strong) NSString *date;//时间戳
@property (nonatomic, strong) NSString *comment;
@property (nonatomic, assign) NSInteger days;
@property (nonatomic, strong) NSString *phone;
@property (nonatomic, strong) NSString *uid;
@property (nonatomic, assign) NSInteger status;
@property (nonatomic, assign) NSInteger icity;
@property (nonatomic, assign) NSInteger iuid;
@property (nonatomic, assign) NSInteger iattr;
@property (nonatomic, assign) NSInteger iclass;
@property (nonatomic, assign) NSInteger istatus;
@property (nonatomic, assign) NSInteger contacts;
@property (nonatomic, strong) NSString *itype;
@property (nonatomic, assign) BOOL collect;//0-未收藏 1-已收藏
@end

//卖票信息
@interface BondSellModel : BaseDataModel
@property (nonatomic, strong) NSString *id;
@property (nonatomic, strong) NSString *kind;//商业汇票
@property (nonatomic, assign) NSInteger ikind;
@property (nonatomic, strong) NSString *city;//北京
@property (nonatomic, strong) NSString *attr;//电子票
@property (nonatomic, strong) NSString *jsonClass;//class 大商
@property (nonatomic, strong) NSNumber *price;
@property (nonatomic, strong) NSString *date;//时间戳
@property (nonatomic, strong) NSString *comment;
@property (nonatomic, assign) NSInteger days;
@property (nonatomic, strong) NSString *phone;
@property (nonatomic, strong) NSString *class_name;//承兑行名称
@property (nonatomic, assign) BOOL collect;//0-未收藏 1-已收藏
@property (nonatomic, strong) NSString *uid;
@property (nonatomic, assign) NSInteger status;
@property (nonatomic, strong) NSString *exp;
@property (nonatomic, strong) NSString *img;
@property (nonatomic, assign) NSInteger icity;
@property (nonatomic, assign) NSInteger iuid;
@property (nonatomic, assign) NSInteger iattr;
@property (nonatomic, assign) NSInteger iclass;
@property (nonatomic, assign) NSInteger istatus;
@property (nonatomic, assign) NSInteger contacts;
@property (nonatomic, strong) NSString *itype;
@property (nonatomic, assign) BOOL canview;//能否查看电话号码
@end

//公司报价
@interface QuotePriceModel : BaseDataModel
@property (nonatomic, strong) NSString *id;
@property (nonatomic, strong) NSString *rate;
@property (nonatomic, strong) NSString *attr;
@property (nonatomic, strong) NSString *gg_r;
@property (nonatomic, strong) NSString *ds_r;
@property (nonatomic, strong) NSString *xs_r;
@property (nonatomic, strong) NSString *qt_r;
@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSString *date;
@property (nonatomic, strong) NSString *uid;
@property (nonatomic, strong) NSString *companyName;
@property (nonatomic, strong) NSString *comment;
@property (nonatomic, assign) NSInteger days;
@property (nonatomic, strong) NSString *price;//TODO:金额
@property (nonatomic, strong) NSString *phone;
@property (nonatomic, assign) NSInteger icity;
@property (nonatomic, assign) NSInteger iattr;
@property (nonatomic, assign) NSInteger iuid;
@property (nonatomic, assign) NSInteger istatus;
@property (nonatomic, strong) NSString *itype;
@property (nonatomic, assign) BOOL collect;//0-未收藏 1-已收藏
@end

//转贴信息
@interface BondReSaleModel : BaseDataModel
@property (nonatomic, strong) NSString *id;
@property (nonatomic, strong) NSString *action;//卖出
@property (nonatomic, strong) NSString *kind;//纸银国股
@property (nonatomic, strong) NSString *rate;
@property (nonatomic, strong) NSNumber *price;
@property (nonatomic, assign) NSInteger days;
@property (nonatomic, strong) NSString *uid;
@property (nonatomic, strong) NSString *companyName;
@property (nonatomic, strong) NSString *phone;
@property (nonatomic, strong) NSString *comment;
@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSString *date;//时间戳
@property (nonatomic, assign) NSInteger icity;
@property (nonatomic, assign) NSInteger iuid;
@property (nonatomic, assign) NSInteger ikind;
@property (nonatomic, assign) NSInteger istatus;
@property (nonatomic, assign) NSInteger iaction;
@property (nonatomic, strong) NSString *itype;
@property (nonatomic, assign) BOOL collect;//0-未收藏 1-已收藏
@end

//回购信息
@interface BondRePurchaseModel : BaseDataModel
@property (nonatomic, strong) NSString *id;
@property (nonatomic, strong) NSString *kind;
@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSString *rate;
@property (nonatomic, strong) NSNumber *price;
@property (nonatomic, strong) NSString *date;//时间戳
@property (nonatomic, strong) NSString *comment;
@property (nonatomic, assign) NSInteger days;
@property (nonatomic, strong) NSString *phone;
@property (nonatomic, strong) NSString *uid;
@property (nonatomic, strong) NSString *companyName;
@property (nonatomic, strong) NSString *action;//正回购
@property (nonatomic, assign) NSInteger icity;
@property (nonatomic, assign) NSInteger iuid;
@property (nonatomic, assign) NSInteger ikind;
@property (nonatomic, assign) NSInteger iaction;
@property (nonatomic, assign) NSInteger istatus;
@property (nonatomic, strong) NSString *itype;
@property (nonatomic, assign) BOOL collect;//0-未收藏 1-已收藏
@end

@interface ShiBorModel : BaseDataModel
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *data;
@property (nonatomic, strong) NSString *bp;
@property (nonatomic, strong) NSString *type;
@end

@interface BankModel : BaseDataModel
@property (nonatomic, strong) NSString *bankId;
@property (nonatomic, strong) NSString *bankName;
@end

//-------------------------------------------------------------------------------------------
//
//  用户相关
//
//-------------------------------------------------------------------------------------------

//基本用户信息
@interface UserModel : BaseDataModel
@property (nonatomic, strong) NSString *userId;//fuid
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *phone;
@property (nonatomic, strong) NSString *nickname;//昵称
@property (nonatomic, strong) NSString *pw;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *sex;//男 女
@property (nonatomic, assign) NSInteger age;
@property (nonatomic, strong) NSString *company;
@property (nonatomic, strong) NSString *position;
@property (nonatomic, strong) NSString *city;//城市名称
@property (nonatomic, strong) NSString *province;
@property (nonatomic, strong) NSNumber *money;//余额
@property (nonatomic, strong) NSString *active;//未认证
@property (nonatomic, strong) NSString *facepic;
@property (nonatomic, strong) NSString *pic;
@property (nonatomic, strong) NSString *sign;
@property (nonatomic, strong) NSString *sort;
@property (nonatomic, strong) NSString *createtime;//yyyy-MM-dd HH:mm:ss
@property (nonatomic, strong) NSString *headsmall;
@property (nonatomic, strong) NSString *headlarge;
@property (nonatomic, assign) NSInteger authstatus;//0-未认证 1-认证中 2-认证成功 3-认证失败
@property (nonatomic, strong) NSString *authresult;//认证失败原因结果

@property (nonatomic, assign) NSInteger icity;//code
@property (nonatomic, assign) NSInteger itype;//0-银行同行 1-票据经理 2-机构
@property (nonatomic, assign) NSInteger isex;//0-女 1-男
@property (nonatomic, assign) NSInteger iactive;//-1未激活
@property (nonatomic, strong) NSString *remark;//备注名

@property (nonatomic, strong) NSString *token;
@property (nonatomic, strong) NSString *uid;
@property (nonatomic, assign) BOOL isfriend;
@property (nonatomic, assign) BOOL forbidden;
@property (nonatomic, strong) NSString *gid;
@property (nonatomic, strong) NSString *sgid;

//UI布局参数
@property (nonatomic, assign) BOOL isOpen;
@property (nonatomic, assign) BOOL isSelected;

- (User *)createUser;
+ (instancetype)CreateByUser:(User *)user;
@end

//城市信息
@interface CityIndexModel : BaseDataModel
@property (nonatomic, strong) NSString *id;
@property (nonatomic, strong) NSString *province;
@property (nonatomic, strong) NSString *city;
@end

//广告信息
@interface SlideIndexModel : BaseDataModel
@property (nonatomic, strong) NSString *id;
@property (nonatomic, strong) NSString *thumb;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *content;
@end

//票友日记
@interface PageIndexModel : BaseDataModel
@property (nonatomic, strong) NSString *id;
@property (nonatomic, strong) NSString *date;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *content;
@end

//我的收藏+我的发布
@interface MyCollectAddModel : BaseDataModel
@property (nonatomic, strong) NSString *id;
@property (nonatomic, strong) NSString *kind;
@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSString *attr;
@property (nonatomic, strong) NSString *collectClass;//class
@property (nonatomic, strong) NSNumber *price;
@property (nonatomic, strong) NSString *rate;
@property (nonatomic, strong) NSString *date;
@property (nonatomic, strong) NSString *comment;
@property (nonatomic, assign) NSInteger days;
@property (nonatomic, strong) NSString *uid;
@end

@interface ReviewModel : BaseDataModel
@property (nonatomic, strong) NSString *id;
@property (nonatomic, strong) NSString *pid;
@property (nonatomic, strong) NSString *nickName;
@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) NSString *adate;
@property (nonatomic, strong) NSString *parent_id;
@end

@interface LikesUserModel : BaseDataModel
@property (nonatomic, strong) NSString *likeId;
@property (nonatomic, strong) NSString *nickName;
@property (nonatomic, strong) NSString *userId;
@end

//朋友圈
@interface MomentsIndexModel : BaseDataModel
@property (nonatomic, strong) NSString *id;
@property (nonatomic, strong) NSString *userAvatar;
@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSString *uid;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSObject *pic;//array
@property (nonatomic, strong) NSObject *big_pic; //array
@property (nonatomic, assign) NSInteger count;
@property (nonatomic, strong) NSString *date;
@property (nonatomic, assign) NSInteger like;
@property (nonatomic, strong) NSArray<LikesUserModel> *like_user;//array
@property (nonatomic, assign) BOOL islike;
@property (nonatomic, strong) NSArray<ReviewModel> *review;//array
@end

//银行联号
@interface BankIndexModel : BaseDataModel
@property (nonatomic, strong) NSString *id;
@property (nonatomic, strong) NSString *CNAPS;
@property (nonatomic, strong) NSString *bank;
@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSString *phone;
@end

//用户分组
@interface UserFriendModel : BaseDataModel
@property (nonatomic, strong) NSString *uid;
@property (nonatomic, strong) NSString *phone;
@property (nonatomic, strong) NSString *sort;
@property (nonatomic, strong) NSString *nickname;
@property (nonatomic, strong) NSString *headsmall;
@property (nonatomic, strong) NSString *headlarge;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, assign) NSInteger gender;
@property (nonatomic, strong) NSString *sign;
@property (nonatomic, assign) BOOL isfriend;
@property (nonatomic, strong) NSString *createtime;
@property (nonatomic, strong) NSString *gid;
@end

#pragma mark - 公共小功能
@interface BannerModel :BaseDataModel
@property (nonatomic, strong) NSString *id;
@property (nonatomic, strong) NSString *thumb;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) NSString *url;
@end

@interface CommonItemModel : BaseDataModel

@property (nonatomic, strong) NSString *rightTitle;
@property (nonatomic, strong) NSString *rightRate;

@property (nonatomic, strong) NSString *icon;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *rightTitle1;
@property (nonatomic, strong) NSString *rightTitle2;
@property (nonatomic, assign) BOOL showsArrow;
@property (nonatomic, assign) BOOL showsTextField;

@property (nonatomic, strong) NSString *viewController;
@property (nonatomic, strong) UIImage *image;

+ (CommonItemModel *)buildNewItem:(NSString *)icon title:(NSString *)title viewController:(NSString *)viewController;
+ (instancetype)CreateByTitle:(NSString *)title rightTitle1:(NSString *)title1 rightTitle2:(NSString *)title2 arrow:(BOOL)showsArrow textField:(BOOL)showsTextField;
+ (instancetype)CreateByTitle:(NSString *)title rightTitle2:(NSString *)title2 arrow:(BOOL)showsArrow;
+ (instancetype)CreateByTitle:(NSString *)title rightTitle2:(NSString *)title2;

+ (instancetype)CreateByIcon:(NSString *)icon title:(NSString *)title rightTitle1:(NSString *)title1 rightTitle2:(NSString *)title2;
+ (instancetype)CreateByIcon:(NSString *)icon title:(NSString *)title rightTitle1:(NSString *)title1;

@end

//图片通用模型
@interface ImageModel : BaseDataModel
@property (nonatomic, strong) NSString *imageUrl;
@end

@interface ASCityModel : BaseDataModel
@property (nonatomic, assign) NSInteger id;
@property (nonatomic, strong) NSString *city;
@end
@interface ASProvinceModel : BaseDataModel
@property (nonatomic, strong) NSString *State;
@property (nonatomic, strong) NSArray<ASCityModel> *Cities;
@end
@interface ASProvince1Model : BaseDataModel
@property (nonatomic, assign) NSInteger id;
@property (nonatomic, strong) NSString *province;
@property (nonatomic, strong) NSString *city;
@end

@interface CourtIndexModel : BaseDataModel
@property (nonatomic, strong) NSString *id;
@property (nonatomic, strong) NSString *pid;
@property (nonatomic, strong) NSString *sname;
@property (nonatomic, strong) NSString *no;
@property (nonatomic, strong) NSString *amount;
@property (nonatomic, strong) NSString *cname;
@property (nonatomic, strong) NSString *gname;
@property (nonatomic, strong) NSString *sdate;
@property (nonatomic, strong) NSString *edate;
@property (nonatomic, strong) NSString *bank;
@property (nonatomic, strong) NSString *qdate;
@property (nonatomic, strong) NSString *gdate;
@property (nonatomic, strong) NSString *gday;
@property (nonatomic, strong) NSString *gedate;
@property (nonatomic, strong) NSString *posttime;
@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) NSString *url;
@end
@interface CourtMyModel : BaseDataModel
@property (nonatomic, strong) NSString *id;
@property (nonatomic, strong) NSString *tno;
@property (nonatomic, assign) BOOL iStatus;
@property (nonatomic, strong) NSString *mobile;
@property (nonatomic, strong) NSString *scantime;
@property (nonatomic, strong) NSString *posttime;
@property (nonatomic, strong) NSString *uid;
@end

@interface VerifyStatusModel : BaseDataModel
@property (nonatomic, strong) NSString *active;
@property (nonatomic, assign) NSInteger iactive;
@property (nonatomic, strong) NSString *reason;
@end


//分组里的好友
@interface UserGroupModel : BaseDataModel
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSArray<UserModel> *users;
@property (nonatomic, assign) BOOL system;
@end

@interface CreateOrderModel : BaseDataModel
@property (nonatomic, strong) NSString *key;
@property (nonatomic, strong) NSString *seller_id;
@property (nonatomic, strong) NSString *partner;
@property (nonatomic, strong) NSString *body;
@property (nonatomic, strong) NSString *notify_url;

@property (nonatomic, strong) NSString *url;//最终已经组装好的参数
@end


//财税列表+律师在线列表
@interface CaiShuiModel : BaseDataModel
@property (nonatomic, strong) NSString *id;
@property (nonatomic, strong) NSString *cityid;
@property (nonatomic, strong) NSString *cityname;
@property (nonatomic, strong) NSString *cityzimu;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *img;
@property (nonatomic, strong) NSString *linkid;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *phone;
@property (nonatomic, strong) NSString *addtime;
@property (nonatomic, strong) NSString *iurl;
//"id": "3",
//"cityid": "1",
//"cityname": "u5317u4eac",
//"cityzimu": "b",
//"name": "u5317u4eacu5c0fu9a6cu5f8bu5e08u4e8bu52a1u6240",
//"img": "img/2015-09-25/56055e359f511.png",
//"linkid": "100001",
//"type": "0",
//"url": "http://www.baidu.com",
//"phone": "18084839203",
//"addtime": "1234567733",
//"_url": "/chengdui/caishui/index/id/3.html"

@end