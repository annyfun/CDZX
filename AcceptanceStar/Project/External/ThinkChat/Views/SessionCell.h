//
//  SessionCell.h
//  HomeBridge
//
//  Created by keen on 14-6-24.
//  Copyright (c) 2014年 keen. All rights reserved.
//

#import "BaseTableViewCell.h"

@class TCSession;

@interface SessionCell : BaseTableViewCell {
}

@property (nonatomic, strong) TCSession*    session;
@property (nonatomic, assign) NSString*     badgeValue;

- (void)setImageHead:(UIImage*)imgHead tag:(NSInteger)tag;

@end
