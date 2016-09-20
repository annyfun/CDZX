//
//  RegionModel.h
//  YSCKit
//
//  Created by yangshengchao on 14/11/11.
//  Copyright (c) 2014年 yangshengchao. All rights reserved.
//

#import "YSCBaseModel.h"

/**
 *  选择的行政区域模型
 */
@interface RegionModel : BaseDataModel

@property (nonatomic, assign) NSInteger pid;
@property (nonatomic, strong) NSString *province;
@property (nonatomic, assign) NSInteger cid;
@property (nonatomic, strong) NSString *city;
@property (nonatomic, assign) NSInteger sid;
@property (nonatomic, strong) NSString *section;

+ (RegionModel *)createRegionBy:(NSString *)province city:(NSString *)city section:(NSString *)section;

@end


/**
 *  省
 */
@interface ProvinceModel : BaseDataModel

@property (nonatomic, assign) NSInteger pid;
@property (nonatomic, strong) NSString *province;
@property (nonatomic, strong) NSMutableArray *cityArray;

/**
 *  初始化省份列表
 *
 *  @return
 */
+ (NSArray *)initProvinces;

/**
 *  初始化每个省份的city列表
 */
- (void)initCityArray;

@end


/**
 *  市
 */
@interface CityModel : BaseDataModel

@property (nonatomic, assign) NSInteger cid;
@property (nonatomic, strong) NSString *city;
@property (nonatomic, assign) NSInteger pid;
@property (nonatomic, strong) NSMutableArray *sectionArray;

/**
 *  初始化每个city的section列表
 */
- (void)initSectionArray;

@end

/**
 *  区
 */
@interface SectionModel : BaseDataModel

@property (nonatomic, assign) NSInteger sid;
@property (nonatomic, strong) NSString *section;
@property (nonatomic, assign) NSInteger cid;

@end