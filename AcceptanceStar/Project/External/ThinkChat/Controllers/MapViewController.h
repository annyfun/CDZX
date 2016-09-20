//
//  MapViewController.h
//  DaLong
//
//  Created by keen on 13-10-29.
//  Copyright (c) 2013年 keen. All rights reserved.
//

#import "BaseViewController.h"
#import "BMapKit.h"

@class MapViewController;

@protocol MapViewDelegate <NSObject>

@optional

- (void)mapViewControllerSetLocation:(Location)loc;
- (void)mapViewControllerSetLocation:(Location)loc content:(NSString*)con;
- (void)mapViewControllerSetLocation:(Location)loc content:(NSString*)con city:(NSString*)city;
- (NSString*)getCurrentSetLocationString;

@end


@interface MapViewController : BaseViewController <BMKMapViewDelegate, BMKPoiSearchDelegate> {
    
}

@property (nonatomic, assign) BOOL  readOnly;
@property (nonatomic, assign) Location location;
- (id)initWithDelegate:(id <MapViewDelegate>)del;

@end
