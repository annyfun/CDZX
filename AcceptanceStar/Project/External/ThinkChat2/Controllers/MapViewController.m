//
//  MapViewController.m
//  DaLong
//
//  Created by keen on 13-10-29.
//  Copyright (c) 2013年 keen. All rights reserved.
////
//  MapViewController.m
//  LfMall
//
//  Created by keen on 13-8-26.
//  Copyright (c) 2013年 keen. All rights reserved.
//

#import "MapViewController.h"
//#import "Shop.h"
//#import "NearbyInfo.h"

@interface MapViewController () <BMKGeoCodeSearchDelegate, BMKLocationServiceDelegate> {
    BMKMapView              * _mapView;
    BMKLocationService      * _locService;
    BMKGeoCodeSearch        * _geoCodesearch;
    
    BOOL located;
    
    CLLocationCoordinate2D myLocation;
    
    double lat;
    double lng;
}

@property (nonatomic, strong) BMKPointAnnotation    * crtAnnotation;
@property (nonatomic, strong) BMKPoiInfo            * currectPoiInfo;
@property (nonatomic, assign) id <MapViewDelegate>  delegate;

@end

@implementation MapViewController

@synthesize location;
@synthesize crtAnnotation;
@synthesize readOnly;
@synthesize delegate;
@synthesize currectPoiInfo;

- (id)initWithDelegate:(id <MapViewDelegate>)del
{
    self = [super initWithNibName:@"MapViewController" bundle:nil];
    if (self) {
        // Custom initialization
        
        self.delegate = del;
        self.readOnly = NO;
        
    }
    return self;
}

- (void)dealloc {
    _mapView = nil;
    _locService = nil;
    _geoCodesearch = nil;
    
    self.crtAnnotation = nil;
    self.currectPoiInfo = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    located = YES;
    
    [self addBarButtonItemBack];
    
    lat = location.lat;
    lng = location.lng;
    _mapView = [[BMKMapView alloc] initWithFrame:self.view.bounds];
    _mapView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    _mapView.mapType = BMKMapTypeStandard;
    [self.view insertSubview:_mapView atIndex:0];
    _geoCodesearch = [[BMKGeoCodeSearch alloc] init];
    _geoCodesearch.delegate = self;
    
    _locService = [[BMKLocationService alloc] init];
}

- (void)save {
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [_mapView viewWillAppear];
    _mapView.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
    _geoCodesearch.delegate = self;
    _locService.delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_mapView viewWillDisappear];
    _mapView.delegate = nil; // 不用时，置nil
    _geoCodesearch.delegate = nil;
    _locService.delegate = nil;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    myLocation.latitude = lat;
    myLocation.longitude = lng;
    if (lat > 0 || lng > 0 || lat < 0 || lng < 0) {
        
        self.navigationItem.title = @"位置";
        located = YES;
        BMKCoordinateRegion region;
        region.center = myLocation;
        region.span = BMKCoordinateSpanMake(0.007, 0.007);
        [_mapView setRegion:region animated:YES];
        
        
        BMKPointAnnotation * annotation = [[BMKPointAnnotation alloc] init];
        if ([delegate respondsToSelector:@selector(getCurrentSetLocationString)]) {
            annotation.title = [delegate getCurrentSetLocationString];
        } else {
            annotation.title = @"在这里";
        }
        annotation.coordinate = myLocation;
        [_mapView addAnnotation:annotation];
        self.crtAnnotation = annotation;
    } else {
        self.navigationItem.title = @"选择位置";
        located = NO;
        [_locService startUserLocationService];
        _mapView.showsUserLocation = NO;
        _mapView.userTrackingMode = BMKUserTrackingModeFollow;
        _mapView.showsUserLocation = YES;
    }
}

- (void)barButtonItemRightPressed:(id)sender {
    if ([delegate respondsToSelector:@selector(mapViewControllerSetLocation:content:city:)]) {
        [delegate mapViewControllerSetLocation:LocationMake(myLocation.latitude, myLocation.longitude) content:currectPoiInfo.address city:currectPoiInfo.city];
    } else if ([delegate respondsToSelector:@selector(mapViewControllerSetLocation:content:)]) {
        [delegate mapViewControllerSetLocation:LocationMake(myLocation.latitude, myLocation.longitude) content:currectPoiInfo.address];
    } else if ([delegate respondsToSelector:@selector(mapViewControllerSetLocation:)]) {
        [delegate mapViewControllerSetLocation:LocationMake(myLocation.latitude, myLocation.longitude)];
    }
    [self popViewController];
}

/**
 *点中底图标注后会回调此接口
 *@param mapview 地图View
 *@param mapPoi 标注点信息
 */
- (void)mapView:(BMKMapView *)mapView onClickedMapPoi:(BMKMapPoi*)mapPoi
{
    TCDemoLog(@"%@",mapPoi.text);
}

/**
 *在将要启动定位时，会调用此函数
 */
- (void)willStartLocatingUser {
	TCDemoLog(@"start locate");
}

/**
 *用户位置更新后，会调用此函数
 *@param mapView 地图View
 *@param userLocation 新的用户位置
 */

- (void)didUpdateUserLocation:(BMKUserLocation *)userLocation
{
	if (userLocation != nil) {
        lat = userLocation.location.coordinate.latitude;
        lng = userLocation.location.coordinate.longitude;
        if (lat > 0 || lng > 0 || lat < 0 || lng < 0) {
            if (!located) {
                located = YES;
                myLocation = userLocation.location.coordinate;
                TCDemoLog(@"%f %f", userLocation.location.coordinate.latitude, userLocation.location.coordinate.longitude);
                BMKCoordinateRegion region;
                region.center = userLocation.location.coordinate;
                region.span = BMKCoordinateSpanMake(0.007, 0.007);
                [_mapView setRegion:region animated:YES];
                
                BMKPointAnnotation * annotation = [[BMKPointAnnotation alloc] init];
                annotation.title = @"当前位置";
                annotation.coordinate = userLocation.location.coordinate;
                [_mapView addAnnotation:annotation];
                self.crtAnnotation = annotation;
                
                [self getLocationString];
            }
            _mapView.showsUserLocation = NO;
        }
	}
	
}
/**
 *在地图View停止定位后，会调用此函数
 *@param mapView 地图View
 */
- (void)mapViewDidStopLocatingUser:(BMKMapView *)mapView{
    TCDemoLog(@"stop locate");
}

/**
 *定位失败后，会调用此函数
 *@param mapView 地图View
 *@param error 错误号，参考CLError.h中定义的错误号
 */
- (void)mapView:(BMKMapView *)mapView didFailToLocateUserWithError:(NSError *)error {
    TCDemoLog(@"location error");
}

// Override
- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id <BMKAnnotation>)annotation
{
	if (!readOnly && [annotation isKindOfClass:[BMKPointAnnotation class]]) {
		BMKPinAnnotationView * newAnnotation = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"myAnnotation"];
		newAnnotation.pinColor = BMKPinAnnotationColorGreen;
		newAnnotation.animatesDrop = YES;
		newAnnotation.draggable = YES;
		return newAnnotation;
	}
	return nil;
}

- (void)mapView:(BMKMapView *)mapView annotationView:(BMKAnnotationView *)view didChangeDragState:(BMKAnnotationViewDragState)newState
   fromOldState:(BMKAnnotationViewDragState)oldState {
    
    TCDemoLog(@"viewForAnnotation");
    myLocation = view.annotation.coordinate;
    [self getLocationString];
}

/**
 地理编码
 */
- (void)getLocationString {
    self.view.userInteractionEnabled = NO;
    self.navigationItem.rightBarButtonItem.enabled = NO;
    self.loading = YES;
    //发起地理编码
    BMKReverseGeoCodeOption *co = [[BMKReverseGeoCodeOption alloc] init];
    co.reverseGeoPoint = myLocation;
    [_geoCodesearch reverseGeoCode: co];
}

#pragma mark - BMKGeoCodeSearchDelegate
/**
 *返回反地理编码搜索结果
 *@param searcher 搜索对象
 *@param result 搜索结果
 *@param error 错误号，@see BMKSearchErrorCode
 */
- (void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error {
    self.view.userInteractionEnabled = YES;
    self.loading = NO;
    
    if (error != 0) {
        self.crtAnnotation.title = @"未知位置";
        return;
    }
    
    // 在此处添加您对地理编码结果的处理
    if (!self.currectPoiInfo) {
        self.currectPoiInfo = [[BMKPoiInfo alloc] init];
        [self addBarButtonItemRightNormalImageName:@"nav_ok_n" hightLited:@"nav_ok_d"];
    }
    
    // add annotation
    BMKCoordinateRegion region;
    region.center = myLocation;
    region.span = BMKCoordinateSpanMake(0.007, 0.007);
    [_mapView setRegion:region animated:YES];

    self.currectPoiInfo.pt = result.location;
    self.crtAnnotation.title =
    self.currectPoiInfo.address = result.address;
    self.currectPoiInfo.city = result.addressDetail.city;
    
    self.navigationItem.rightBarButtonItem.enabled = YES;
}

/**
 *返回地址信息搜索结果
 *@param searcher 搜索对象
 *@param result 搜索结BMKGeoCodeSearch果
 *@param error 错误号，@see BMKSearchErrorCode
 */
- (void)onGetGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error {
    myLocation = result.location;
    // add annotation
    BMKCoordinateRegion region;
    region.center = myLocation;
    region.span = BMKCoordinateSpanMake(0.007, 0.007);
    [_mapView setRegion:region animated:YES];

    self.currectPoiInfo.pt = result.location;
    self.currectPoiInfo.address = result.address;
    self.loading = NO;
}

@end
