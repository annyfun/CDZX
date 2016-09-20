//
//  TextInput.h
//  FamiliarMen
//
//  Created by kiwi on 14-1-17.
//  Copyright (c) 2014年 xizue. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KTextField : UITextField

@end



@interface KTextView : UITextView

@property(nonatomic, strong) NSString *placeholder;     //占位符

-(void)addObserver;//添加通知
-(void)removeobserver;//移除通知

@end
