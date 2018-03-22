//
//  TestComponent.h
//  WeexLayoutDemo
//
//  Created by fenqile on 2018/3/20.
//  Copyright © 2018年 com.cn.fql. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface TestComponent : NSObject

@property (nonatomic, strong) UIView *view;
- (void)addViewWithDict:(NSDictionary *)dict;
@end
