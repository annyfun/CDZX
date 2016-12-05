//
//  DataModel.m
//  YSCKit
//
//  Created by  YangShengchao on 14-4-29.
//  Copyright (c) 2014年 yangshengchao. All rights reserved.
//

#import "DataModel.h"
#import <FMDB/FMDB.h>

@implementation NewVersionModel             @end

@implementation BondBuyModel
+ (NSDictionary *)jsonToModelMapping {
    return @{@"class" : @"jsonClass",
             @"_city" : @"icity",
             @"_uid" : @"iuid",
             @"_attr" : @"iattr",
             @"_class" : @"iclass",
             @"_type" : @"itype",
             @"_status" : @"istatus"};
}
@end
@implementation BondSellModel
+ (NSDictionary *)jsonToModelMapping {
    return @{@"class" : @"jsonClass",
             @"_kind" : @"ikind",
             @"_city" : @"icity",
             @"_uid" : @"iuid",
             @"_attr" : @"iattr",
             @"_class" : @"iclass",
             @"_type" : @"itype",
             @"_status" : @"istatus"};
}
@end
@implementation BondReSaleModel
+ (NSDictionary *)jsonToModelMapping {
    return @{@"_city" : @"icity",
             @"_uid" : @"iuid",
             @"_kind" : @"ikind",
             @"_action" : @"iaction",
             @"_type" : @"itype",
             @"_status" : @"istatus"};
}
@end
@implementation QuotePriceModel
+ (NSDictionary *)jsonToModelMapping {
    return @{@"_city" : @"icity",
             @"_attr" : @"iattr",
             @"_uid" : @"iuid",
             @"_type" : @"itype",
             @"n_status" : @"istatus"};
}
@end
@implementation BondRePurchaseModel
+ (NSDictionary *)jsonToModelMapping {
    return @{@"_city" : @"icity",
             @"_uid" : @"iuid",
             @"_kind" : @"ikind",
             @"_action" : @"iaction",
             @"_type" : @"itype",
             @"_status" : @"istatus"};
}
@end
@implementation ShiBorModel         @end
@implementation BankModel
+ (NSDictionary *)jsonToModelMapping {
    return @{@"id" : @"bankId", @"name" : @"bankName"};
}
@end


@implementation UserModel
+ (NSDictionary *)jsonToModelMapping {
    return @{@"id" : @"userId",
             @"_city" : @"icity",
             @"_type" : @"itype",
             @"_sex" : @"isex",
             @"_active" : @"iactive"};
}
- (User *)createUser {
    User *user = [User new];
    user.ID = self.userId;
    user.phone = self.phone;
    user.passWord = self.pw;
    user.sort = self.sort;
    user.nickName = self.nickname;
    user.headImgUrlS = self.headsmall;
    user.headImgUrlL = self.headlarge;
    user.email = @"";
    user.sign = self.sign;
    if ([@"女" isEqualToString:self.sex]) {
        user.gender = 1;
    }
    else if ([@"男" isEqualToString:self.sex]) {
        user.gender = 0;
    }
    else {
        user.gender = 2;
    }
    user.isFriend = self.isfriend;
    NSDate *date = [NSDate dateFromString:self.createtime withFormat:DateFormat1];
    user.timeCreate = [date timeIntervalSince1970];
    return user;
}
+ (instancetype)CreateByUser:(User *)user {
    UserModel *userModel = [UserModel new];
    userModel.userId = user.ID;
    userModel.phone = user.phone;
    userModel.pw = user.passWord;
    userModel.sort = user.sort;
    userModel.nickname = user.nickName;
    userModel.headsmall = user.headImgUrlS;
    userModel.headlarge = user.headImgUrlL;
    userModel.sign = user.sign;
    userModel.sex = user.genderString;
    userModel.isfriend = user.isFriend;
    return userModel;
}
@end
@implementation CityIndexModel              @end
@implementation SlideIndexModel             @end
@implementation PageIndexModel              @end
@implementation MyCollectAddModel           @end
@implementation ReviewModel
+ (NSDictionary *)jsonToModelMapping {
    return @{@"uid" : @"nickName"};
}
@end
@implementation LikesUserModel
+ (NSDictionary *)jsonToModelMapping {
    return @{@"id" : @"likeId", @"uid" : @"nickName", @"_uid" : @"userId"};
}
@end
@implementation MomentsIndexModel           @end
@implementation BankIndexModel              @end
@implementation UserFriendModel             @end

@implementation BannerModel

- (NSString *)thumb{
    
    if (_thumb && ![_thumb hasPrefix:@"http"]) {
        return [NSString stringWithFormat:@"http://www.yhcd.net/upload/%@",_thumb];
    }
    return _thumb;
}
@end

@implementation CommonItemModel
+ (CommonItemModel *)buildNewItem:(NSString *)icon title:(NSString *)title viewController:(NSString *)viewController {
    CommonItemModel *item = [CommonItemModel new];
    item.icon = icon;
    item.title = title;
    item.viewController = viewController;
    return item;
}
+ (instancetype)CreateByTitle:(NSString *)title rightTitle1:(NSString *)title1 rightTitle2:(NSString *)title2 arrow:(BOOL)showsArrow textField:(BOOL)showsTextField {
    CommonItemModel *item = [CommonItemModel new];
    item.title = title;
    item.rightTitle1 = title1;
    item.rightTitle2 = title2;
    item.showsArrow = showsArrow;
    item.showsTextField = showsTextField;
    return item;
}
+ (instancetype)CreateByTitle:(NSString *)title rightTitle2:(NSString *)title2 arrow:(BOOL)showsArrow {
    return [self CreateByTitle:title rightTitle1:@"" rightTitle2:title2 arrow:showsArrow textField:NO];
}
+ (instancetype)CreateByTitle:(NSString *)title rightTitle2:(NSString *)title2 {
    return [self CreateByTitle:title rightTitle1:@"" rightTitle2:title2 arrow:NO textField:NO];
}


+ (instancetype)CreateByIcon:(NSString *)icon title:(NSString *)title rightTitle1:(NSString *)title1 rightTitle2:(NSString *)title2 {
    CommonItemModel *item = [CommonItemModel new];
    item.icon = icon;
    item.title = title;
    item.rightTitle1 = title1;
    item.rightTitle2 = title2;
    return item;
}
+ (instancetype)CreateByIcon:(NSString *)icon title:(NSString *)title rightTitle1:(NSString *)title1 {
    return [self CreateByIcon:icon title:title rightTitle1:title1 rightTitle2:nil];
}

@end
@implementation ImageModel                  @end
@implementation ASCityModel                 @end
@implementation ASProvinceModel             @end
@implementation ASProvince1Model            @end
@implementation CourtIndexModel             @end
@implementation CourtMyModel                @end
@implementation VerifyStatusModel
+ (NSDictionary *)jsonToModelMapping {
    return @{@"_active" : @"iactive"};
}
@end
@implementation UserGroupModel
+ (NSDictionary *)jsonToModelMapping {
    return @{@"value" : @"users"};
}
@end
@implementation CreateOrderModel          @end
@implementation CaiShuiModel
+ (NSDictionary *)jsonToModelMapping {
    return @{@"_url" : @"iurl"};
}
@end
@implementation CreditBankModel
+ (NSDictionary *)jsonToModelMapping {
    return @{
             @"_bank" : @"ibank",
             @"_uid" : @"iuid",
             @"_rt" : @"irt",
             @"_url" : @"iurl"
    };
}
@end

@implementation ElectricModel
+ (NSDictionary *)jsonToModelMapping {
    return @{
             @"_status" : @"sstatus",
             @"_uid" : @"iuid",
             @"_type" : @"itype",
             @"_url" : @"iurl"
             };
}

- (ASElectricStauts)istatus{
    
    return [self.sstatus integerValue];
}

- (NSString *)pic{
    
    if (_pic && ![_pic hasPrefix:@"http"]) {
        return [NSString stringWithFormat:@"http://www.yhcd.net/upload/%@",_pic];
    }
    return _pic;
}
@end

@implementation PaperModel
+ (NSDictionary *)jsonToModelMapping {
    return @{
             @"ticket_no" : @"ticketNo",
             @"bank_name" : @"bankName",
             @"price" : @"price",
             @"exp" : @"exp",
             @"_status":@"rstatus",
             @"company":@"company",
             @"status":@"status",
             };
}

-(NSString *)getExpDateString
{
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:DateFormat3];
    if (self.exp == 0) {
        return [formatter stringFromDate:[NSDate dateNow]];
    }else{
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:self.exp];
        return [formatter stringFromDate:date];
    }
}
@end
@implementation TieXianModel
+ (NSDictionary *)jsonToModelMapping {
    return @{
             @"_status" : @"status",
             @"bank_name" : @"bankName",
             @"company_phone": @"companyPhone",
             @"accept_price":@"acceptPrice",
             @"order_no":@"orderNo"
             };
}

-(bool)reject
{
    return [self.status isEqualToString:@"3"];
}

- (ASElectricStauts)rstatus{
    
    return [self.status integerValue];
}
@end



//@implementation TieXianShenQingItem
//
//+ (NSDictionary *)jsonToModelMapping {
//    return @{
//             @"_buid" : @"i_buid",
//             @"_uid" : @"i_uid",
//             @"_status": @"i_status",
//             @"_url":@"i_url",
//             @"id":@"model_id",
//             };
//}
//
///*
// @property (nonatomic, strong) NSString *_buid;
// @property (nonatomic, strong) NSString *_uid;
// @property (nonatomic, strong) NSString *_status;
// @property (nonatomic, strong) NSString *_url;
//
// */
//
//@end







