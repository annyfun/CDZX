//
//  RegionModel.m
//  YSCKit
//
//  Created by yangshengchao on 14/11/11.
//  Copyright (c) 2014年 yangshengchao. All rights reserved.
//

#import "RegionModel.h"
#import <FMDB/FMDB.h>

@implementation RegionModel
+ (RegionModel *)createRegionBy:(NSString *)province city:(NSString *)city section:(NSString *)section {
    province = [province lowercaseString];
    city = [city lowercaseString];
    section = [section lowercaseString];
    
    RegionModel *region = [RegionModel new];
    FMDatabase *db = [FMDatabase databaseWithPath:RegionDbPath];
    if ([db open]) {
        //查询province
        NSString *selectProvince = [NSString stringWithFormat:@"SELECT pid, province FROM province WHERE province like '%%%@%%' OR ppinyin like '%%%@%%'", province, province];
        FMResultSet *resultSet = [db executeQuery:selectProvince];
        if ([resultSet next]) {
            region.pid = [resultSet intForColumn:@"pid"];
            region.province = [resultSet stringForColumn:@"province"];
        }
        //查询city
        NSString *selectCity = [NSString stringWithFormat:@"SELECT cid, city FROM city WHERE (city like '%%%@%%' OR cpinyin like '%%%@%%') AND pid=%ld", city, city, (long)region.pid];
        resultSet = [db executeQuery:selectCity];
        if ([resultSet next]) {
            region.cid = [resultSet intForColumn:@"cid"];
            region.city = [resultSet stringForColumn:@"city"];
        }
        //查询section
        NSString *selectSection = [NSString stringWithFormat:@"SELECT sid, section FROM section WHERE (section like '%%%@%%' OR spinyin like '%%%@%%') AND cid=%ld", section, section, (long)region.cid];
        resultSet = [db executeQuery:selectSection];
        if ([resultSet next]) {
            region.sid = [resultSet intForColumn:@"sid"];
            region.section = [resultSet stringForColumn:@"section"];
        }
    }
    [db close];
    return region;
}
@end

@implementation ProvinceModel

+ (NSArray *)initProvinces {
    NSMutableArray *provinceArray = [NSMutableArray array];
    FMDatabase *db = [FMDatabase databaseWithPath:RegionDbPath];
    if ([db open]) {
        FMResultSet *resultSet = [db executeQuery:@"SELECT pid, province FROM province ORDER BY pid ASC"];
        while ([resultSet next]) {
            ProvinceModel *provinceModel = [ProvinceModel new];
            provinceModel.pid = [resultSet intForColumn:@"pid"];
            provinceModel.province = [resultSet stringForColumn:@"province"];
            [provinceArray addObject:provinceModel];
        }
    }
    [db close];
    return provinceArray;
}

- (void)initCityArray {
    if ([NSArray isNotEmpty:self.cityArray]) {
        return;
    }
    self.cityArray = [NSMutableArray array];
    FMDatabase *db = [FMDatabase databaseWithPath:RegionDbPath];
    if ([db open]) {
        FMResultSet *resultSet = [db executeQueryWithFormat:@"SELECT cid, city FROM city WHERE pid = %ld", (long)self.pid];
        while ([resultSet next]) {
            CityModel *cityModel = [CityModel new];
            cityModel.cid = [resultSet intForColumn:@"cid"];
            cityModel.city = [resultSet stringForColumn:@"city"];
            cityModel.pid = self.pid;
            [self.cityArray addObject:cityModel];
        }
    }
    [db close];
}

@end
@implementation CityModel

- (void)initSectionArray {
    if ([NSArray isNotEmpty:self.sectionArray]) {
        return;
    }
    self.sectionArray = [NSMutableArray array];
    FMDatabase *db = [FMDatabase databaseWithPath:RegionDbPath];
    if ([db open]) {
        FMResultSet *resultSet = [db executeQueryWithFormat:@"SELECT sid, section FROM section WHERE cid = %ld", (long)self.cid];
        while ([resultSet next]) {
            SectionModel *sectionModel = [SectionModel new];
            sectionModel.sid = [resultSet intForColumn:@"sid"];
            sectionModel.section = [resultSet stringForColumn:@"section"];
            sectionModel.cid = self.cid;
            [self.sectionArray addObject:sectionModel];
        }
    }
    [db close];
}

@end
@implementation SectionModel    @end