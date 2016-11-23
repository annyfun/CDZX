//
//  Login.m
//  YSCKit
//
//  Created by  YangShengchao on 14-2-25.
//  Copyright (c) 2014年  YangShengchao. All rights reserved.
//

#import "Login.h"
#import "AppDelegate.h"

@interface Login ()

@property (nonatomic, assign) BOOL isLogging;           //是否正在登录中

@end

@implementation Login

+ (Login *)sharedInstance {
    DEFINE_SHARED_INSTANCE_USING_BLOCK(^ {
        return [[self alloc] init];
    })
}

- (id)init {
    if (self = [super init]) {
        self.loginObservers = [NSMutableArray new];
        self.user = [UserModel new];
    }
    return self;
}

- (void)dealloc {
    NSLog(@"Login is deallocing...");
    self.loginObservers = nil;
    self.user = nil;
    removeAllObservers(self);
}

#pragma mark - methods called outside

// 供外部调用，重新下载用户资料
- (void)refreshUserInfo {
    NSLog(@"重新下载当前登录用户资料");
    WeakSelfType blockSelf = self;
    [AFNManager getDataWithAPI:kResPathAppUserDetail
                  andDictParam:@{kParamToken : TOKEN}
                     modelName:ClassOfObject(UserModel)
              requestSuccessed:^(id responseObject) {
                  if ( [NSObject isNotEmpty:responseObject] && [responseObject isKindOfClass:[UserModel class]]) {
                      [blockSelf resetUser:responseObject];
                  }
              }
                requestFailure:^(NSInteger errorCode, NSString *errorMessage) {
                    NSLog(@"errorMessage = %@", errorMessage);
                }];
}

- (void)resetSortParams:(NSDictionary *)params {
    if (nil == self.sortParams) {
        self.sortParams = [NSMutableDictionary dictionary];
    }
    else {
        [self.sortParams removeAllObjects];
    }
    [self.sortParams addEntriesFromDictionary:params];
}
#pragma mark - 用户登录/重新登录/退出登录
// 判断是否登录过了
- (BOOL)isLogged {
    return [NSString isNotEmpty:self.token];
}

// 判断登录过期
- (NSString *)token {
    if (nil == _token) {
        NSString *tempToken = [[StorageManager sharedInstance] configValueForKey:kCachedUserToken];
        if ([NSString isNotEmpty:tempToken]) {
            _token = tempToken;
        }
    }
    return _token;
}

/**
 *  清除登录信息
 */
- (void)clearLoginData {
    self.user = nil;
    self.token = nil;
    self.shoppingCartProductCount = 0;
    [[StorageManager sharedInstance] setConfigValue:[NSNull null] forKey:kCachedUserModel];
    [[StorageManager sharedInstance] setConfigValue:@"" forKey:kCachedUserToken];
    
    self.isUserChanged = YES;
}

- (void)loginWithParams:(NSDictionary *)params andObserver:(id<LoginObserverDelegate>)observer {
    [self doLogin:kResPathAppUserLogin
           params:params
      andObserver:observer];
}

/**
 *  第三方账号登录
 *
 *  @param type
 *  @param observer
 */
- (void)loginWithSNSType:(ShareType)type andObserver:(id<LoginObserverDelegate>)observer {
    NSAssert(observer, @"the login observer is nil");
    [self registerLoginObserver:observer];
    
    WeakSelfType blockSelf = self;
    NSString *platformName = [SNSShareManager PlatformTypeOfUMeng:type];
    UMSocialSnsPlatform *snsPlatform = [SNSShareManager SocialSnsPlatform:type];
    if (nil == snsPlatform) {
        if (UMShareToWechatSession == platformName ||
            UMShareToWechatTimeline == platformName ||
            UMShareToWechatFavorite == platformName) {
            [self loginFailedWithError:@"请先安装微信客户端"];
        }
        else {
            [self loginFailedWithError:@"登陆失败"];
        }
        return;
    }
    snsPlatform.loginClickHandler(observer,[UMSocialControllerService defaultControllerService], YES, ^(UMSocialResponseEntity *response) {
        NSLog(@"login response is %@",response);
        if (UMSResponseCodeSuccess == response.responseCode) {
            UMSocialAccountEntity *snsAccount = [[UMSocialAccountManager socialAccountDictionary] valueForKey:platformName];
            NSLog(@"username is %@, uid is %@, token is %@",snsAccount.userName,snsAccount.usid,snsAccount.accessToken);
            
            NSString *openId = snsAccount.usid;
            NSString *openUserName = snsAccount.userName;
            NSString *openAvatarUrl = snsAccount.iconURL;
            GenderType gender = GenderTypeNotSet;
            
            if ([NSString isEmpty:openId]) {
                NSLog(@"登录失败！openid为空");
                [blockSelf loginFailedWithError:@"登录失败！openid为空"];
            }
            else {
                NSMutableDictionary *paramsDict = [NSMutableDictionary dictionary];
                [paramsDict setValue:openId forKey:kParamOpenId];
                [paramsDict setValue:@(type) forKey:kParamOpenType];
                [paramsDict setValue:@(gender) forKey:kParamGender];
                [paramsDict setValue:Trim(openUserName) forKey:kParamNickName];
                [paramsDict setValue:openAvatarUrl forKey:kParamAvatarUrl];
                [blockSelf doLogin:kResPathAppExternalLogin
                            params:paramsDict
                       andObserver:observer];
                [MobClick event:UMEventKeyLoginSNSSuccess];
            }
        }
        else if (UMSResponseCodeCancel == response.responseCode) {
            [blockSelf loginFailedWithError:@"第三方登录取消！"];
        }
        else {
            NSString *errorMessage = [NSString stringWithFormat:@"第三方授权失败!(%d)", response.responseCode];
            [blockSelf loginFailedWithError:errorMessage];
        }
        
        //这里可以获取到腾讯微博openid,Qzone的token等
        /*
         if ([platformName isEqualToString:UMShareToTencent]) {
         [[UMSocialDataService defaultDataService] requestSnsInformation:UMShareToTencent completion:^(UMSocialResponseEntity *respose){
         NSLog(@"get openid  response is %@",respose);
         }];
         }
         */
    });
    
}

/// 第三方登录(new)
- (void)loginWithThirdParty:(NSString *)thirdParty andObserver:(id<LoginObserverDelegate>)observer {
    NSAssert(observer, @"the login observer is nil");
    [self registerLoginObserver:observer];
    UMSocialSnsPlatform *snsPlatform = [UMSocialSnsPlatformManager getSocialPlatformWithName:thirdParty];
    snsPlatform.loginClickHandler(observer,[UMSocialControllerService defaultControllerService],YES,^(UMSocialResponseEntity *response){
        if (response.responseCode == UMSResponseCodeSuccess) {
            UMSocialAccountEntity *snsAccount = [[UMSocialAccountManager socialAccountDictionary]valueForKey:thirdParty];
            // 尝试登录(不知道是否注册过)
            NSDictionary *params = @{@"third_id": snsAccount.usid,@"third_type": snsAccount.platformName};
            WeakSelfType blockSelf = self;
            [AFNManager postDataWithAPI:kResPathAppUserThirdLogin andDictParam:params modelName:ClassOfObject(UserModel) requestSuccessed:^(id responseObject) {
                // 登录成功
                UserModel *userModel = (UserModel *)responseObject;
                if ([userModel isKindOfClass:[UserModel class]] && [NSString isNotEmptyConsiderWhitespace:userModel.userId]) {
                    [[StorageManager sharedInstance] setConfigValue:Trim(userModel.token) forKey:kCachedUserToken];//NOTE:只有登录才返回token
                    [blockSelf resetUser:userModel];
                    [blockSelf loginSucceeded];
                }
                else {
                    [blockSelf loginFailedWithError:@"登录失败！"];
                }
            } requestFailure:^(NSInteger errorCode, NSString *errorMessage) {
                if (errorCode == 1103) { // 第三方账号未注册
                    [blockSelf jumpToRegisterViewControllerWithParams:params];
                } else {
                    [blockSelf loginFailedWithError:errorMessage];
                }
            }];
        } else {
            [UIView showResultThenHideOnWindow:response.message afterDelay:1.5];
        }
    });
    
}

/**
 *  发送登录请求
 *  兼容第三方登录
 *
 *  @param apiName  接口名
 *  @param param    请求参数
 *  @param observer 登录成功/失败后触发相应的对象
 */
- (void)doLogin:(NSString *)apiName params:(NSDictionary *)param andObserver:(id<LoginObserverDelegate>)observer {
    NSAssert(observer, @"the login observer is nil");
    
    [self registerLoginObserver:observer];
    if (self.isLogging) {
        return;
    }
    self.isLogging = YES;
    WeakSelfType blockSelf = self;
    [AFNManager postDataWithAPI:apiName
                   andDictParam:param
                      modelName:ClassOfObject(UserModel)
               requestSuccessed:^(id responseObject) {
                   UserModel *userModel = (UserModel *)responseObject;
                   
                   NSString* pw = [param objectForKey:@"pw"];
                   [userModel setPw:pw];
                   NSLog(@"userModel = %@", userModel);
                   if ([userModel isKindOfClass:[UserModel class]] && [NSString isNotEmptyConsiderWhitespace:userModel.userId]) {
                       [[StorageManager sharedInstance] setConfigValue:Trim(userModel.token) forKey:kCachedUserToken];//NOTE:只有登录才返回token
                       [blockSelf resetUser:userModel];
                       [blockSelf loginSucceeded];
                   }
                   else {
                       [blockSelf loginFailedWithError:@"登录失败！"];
                   }
               } requestFailure:^(NSInteger errorCode, NSString *errorMessage) {
                   NSLog(@"errorMessage = %@", errorMessage);
                   [blockSelf loginFailedWithError:errorMessage];
               }];
}

// 退出登录
- (void)logout {
    for (id<LoginObserverDelegate> observer in self.loginObservers) {
        if ([observer respondsToSelector:@selector(loggedOut)]) {
            [observer loggedOut];
        }
        if ([observer respondsToSelector:@selector(loggedOutWithUserId:)]) {
            [observer loggedOutWithUserId:self.user.userId];
        }
    }
    [[AppDelegate instance] signOut];
    [self clearLoginData];
}


#pragma mark - Login Observer CallBack

- (void)registerLoginObserver:(id<LoginObserverDelegate>)observer {
    if (observer) {
        if ( ! [self.loginObservers containsObject:observer]) {
            [self.loginObservers addObject:observer];
        }
    }
    else {
        NSLog(@"login observer to register is null");
    }
}

- (void)unregisterLoginObserver:(id)observer {
    if (observer && [self.loginObservers containsObject:observer]) {
        [self.loginObservers removeObject:observer];
    }
    else {
        NSLog(@"login observer to unregister is null or is not exists in array");
    }
}

#pragma mark - Login Private Methods

// 重置self.loginUser 对象
- (void)resetUser:(UserModel *)userModel {
    [[StorageManager sharedInstance] setConfigValue:userModel forKey:kCachedUserModel];
    [[StorageManager sharedInstance] setUserId:userModel.userId];
    self.user = [[StorageManager sharedInstance] configValueForKey:kCachedUserModel];
    if ([NSString isNotEmptyConsiderWhitespace:userModel.token]) {
        [[StorageManager sharedInstance] setConfigValue:userModel.token forKey:kCachedUserToken];
    }
    self.isUserChanged = YES;   //用于触发观察者的block回调
    
    [[AppDelegate instance] loginWithUser:[userModel createUser]  passWord:[userModel pw]];
}

- (void)loginSucceeded {
    self.isLogging = NO;
    
    for (id<LoginObserverDelegate> observer in self.loginObservers) {
        if ([observer respondsToSelector:@selector(loginSucceededWithUserId:session:)]) {
            [observer loginSucceededWithUserId:self.user.phone
                                       session:nil];
        }
    }
}

- (void)loginFailedWithError:(NSString *)theError {
    self.isLogging = NO;
    [self clearLoginData];
    
    for (id<LoginObserverDelegate> observer in self.loginObservers) {
        if ([observer respondsToSelector:@selector(loginFailedWithError:)]) {
            [observer loginFailedWithError:theError];
        }
    }
}

- (void)loginIsCancelled {
    self.isLogging = NO;
    
    for (id<LoginObserverDelegate> observer in self.loginObservers) {
        if ([observer respondsToSelector:@selector(loginCancelled)]) {
            [observer loginCancelled];
        }
    }
}

- (void)jumpToRegisterViewControllerWithParams:(NSDictionary *)params {
    self.isLogging = NO;

    for (id<LoginObserverDelegate> observer in self.loginObservers) {
        if ([observer respondsToSelector:@selector(jumpToRegisterViewControllerWithParams:)]) {
            [observer jumpToRegisterViewControllerWithParams:params];
        }
    }
}

@end
