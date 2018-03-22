//
//  TestComponent.m
//  WeexLayoutDemo
//
//  Created by fenqile on 2018/3/20.
//  Copyright © 2018年 com.cn.fql. All rights reserved.
//

#import "TestComponent.h"
#import "Layout.h"



@interface TestComponent ()
{
    css_node_t *_viewCSSNode;
}



@end

@implementation TestComponent

- (void)addViewWithDict:(NSDictionary *)dict {
    _viewCSSNode = new_css_node();
    
    NSDictionary *style = dict[@"style"];
    [self fillCSSNode:style];
    
    NSDictionary *type = dict[@"type"];
    if ([type isEqual:@"div"]) {
        self.view = [[UIView alloc] init];
    }else if ([type isEqual:@"scroller"]) {
        self.view = [[UIScrollView alloc] init];
    }else{
        self.view = [[UIView alloc] init];
    }
    
    
    [self layoutViewWithCSS];
}

- (void)fillCSSNode:(NSDictionary *)styles {
    
    _viewCSSNode->style.position[CSS_LEFT] = [self WXPixelType:styles[@"left"]];
    _viewCSSNode->style.position[CSS_TOP] = [self WXPixelType:styles[@"top"]];
    _viewCSSNode->style.dimensions[CSS_WIDTH] = [self WXPixelType:styles[@"width"]] ?: CSS_UNDEFINED;
    _viewCSSNode->style.dimensions[CSS_HEIGHT] =  [self WXPixelType:styles[@"height"]] ?: CSS_UNDEFINED;
    
}


- (void)layoutViewWithCSS {
    CGRect frame = CGRectMake(roundeValue(_viewCSSNode->style.position[CSS_LEFT]),
                              roundeValue(_viewCSSNode->style.position[CSS_TOP]),
                              roundeValue(_viewCSSNode->style.dimensions[CSS_WIDTH]),
                              roundeValue(_viewCSSNode->style.dimensions[CSS_HEIGHT]));
    self.view.frame = frame;

}

- (void)dealloc {
    free_css_node(_viewCSSNode);
}



CGFloat roundeValue(CGFloat value) {
    CGFloat scale = [UIScreen mainScreen].scale;
    return round (value * scale) / scale;
}

- (CGFloat)WXPixelType:(id)value
{
    //对 px 和 wx 进行计算，转换成可以用于frame的值
    CGFloat pixel = [self CGFloat:value];
    if ([value isKindOfClass:[NSString class]] && [value hasSuffix:@"wx"]) {
        return pixel;
    }else {
        //如果后缀不是wx时，需要根据进行屏幕比例换算，换算成可以用于frame的值，这里不进行实现
        return pixel;
    }
}


- (CGFloat)CGFloat:(id)value
{
    if ([value isKindOfClass:[NSString class]]) {
        NSString *valueString = (NSString *)value;
        if ([valueString hasSuffix:@"px"] || [valueString hasSuffix:@"wx"]) {
            valueString = [valueString substringToIndex:(valueString.length - 2)];
        }
        return [valueString doubleValue];
    }
    NSNumber *valueNum = value;
    return valueNum.floatValue;
}


@end
