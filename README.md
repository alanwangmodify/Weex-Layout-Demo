# Weex-iOS源码-CSS Layout 分析

### 前言
这篇文章主要是对Weex iOS端源码中的布局原理进行分析，并根据原理写了一个[Demo](https://github.com/alanwangmodify/Weex-Layout-Demo),欢迎大家进行交流沟通。
### Layout 介绍
Layout是FaceBook开源的一个跨端CSS布局引擎。
Weex 引入了Layout 在原来的基础上进行命名空间上的调整，
Layout在Weex中主要是作为一个CSS参数的容器，对CSS的参数的管理。

### Layout源码
Layout源码由C语言编写，主要包含可以存储CSS参数的结构体、枚举，以及一些相关的C函数。
1、结构体、枚举
Layout.h文件中声明了对应于CSS属性的一些结构体和枚举体
如：
```
css_style_t
css_layout_t
css_node_t
css_direction_t
css_flex_direction_t
css_justify_t
css_align_t
css_position_type_t
css_wrap_type_t
css_position_t
···
```


对CSS有了解的伙伴可以看出，这些结构体的命名上和CSS的属性是相对应的
其中比较核心的一个数据结构体是```css_node_t```，里面包含了CSS布局需要的大部分参数：
![](https://upload-images.jianshu.io/upload_images/1819750-1c71825b768d8850.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

2、C函数
layout中实现了一些管理```css_node_t```等结构体的生命周期的C函数：

```
css_node_t *new_css_node(void);
void init_css_node(css_node_t *node);
void free_css_node(css_node_t *node);
void layoutNode(css_node_t *node, float maxWidth, float maxHeight, css_direction_t parentDirection);
void resetNodeLayout(css_node_t *node);
```

这些函数包括了初始化、析构、重置等功能。



### Weex布局原理

#### 大概流程：
![](https://upload-images.jianshu.io/upload_images/1819750-7acd7598a88a8c4a.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


##### 一、通过JS载入数据

Weex通过JSContext让APP与JS进行交互，相关载入的数据通过JSValue进行载入。
JSValue数据结构大致如下:
```
    {
        attr = {
            data-v-e9c9dede = ;
        };
        style = {
            bottom = 48wx;
            position = absolute;
            width = 0;
            left = 0;
            top = 0;
            opacity = 0;
            backgroundColor = rgba(0,0,0,0.5);
        };
        type = div;
        event = (
                 click
                 );
        ref = 558;
    }
```

通过JS获取JSValue:
![](https://upload-images.jianshu.io/upload_images/1819750-93584c3a36a4c3d8.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


##### 二、转换成iOS原生可用的布局数据 存进```css_node_t```

在获取JSValue之后通过```toDictionary```方法转化成原生直接可用的NSDictionary格式的数据。
再将NSDictionary数据转换到css_node_t中
Weex中封装了一些宏用于转换，如：
```
WX_STYLE_FILL_CSS_NODE
WX_STYLE_FILL_CSS_NODE_PIXEL
WX_STYLE_FILL_CSS_NODE_ALL_DIRECTION
```
这些宏主要是获取NSDictionary中各个key的value(即CSS属性的数据)计算成原生布局可用的数据,存入```css_node_t``` 中对应的成员里。
Weex提供了一些方法将CSS属性的数据计算转换成布局可用的数据:
例如数值转换：
![](https://upload-images.jianshu.io/upload_images/1819750-fd21e9535c60498b.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
Weex中，CSS的width,height等属性单位有wx和px.```+ (CGFloat)CGFloat:(id)value```方法就是将其转换成原生布局可以用的数值。


##### 三、进行布局
需要布局时，从```css_node_t```取出数据，对View进行布局。
如：
![](https://upload-images.jianshu.io/upload_images/1819750-7dac08b1089f1ac0.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
从```css_node_t```中取出数据，计算出frame（即View的位置和大小），进行布局

### 其他细节
##### 布局数值的精确度
在layout中实现了一个比较函数```eq```:
```
static bool eq(float a, float b) {
  if (isUndefined(a)) {
    return isUndefined(b);
  }
  return fabs(a - b) < 0.0001;
}
```
从中可以看出，所以在weex中布局相关数值的精确度偏差最低为0.0001，如0.00011和0.00019在weex布局中视为一样。

###### <text>标签采用绘制成图片的形式展示
从源码可以看出，<text>(对应weex源码中的WXTextComponent)用了绘制成图片的形式展示：
![](https://upload-images.jianshu.io/upload_images/1819750-c8fb4267168702c2.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
这也是导致weex页面内存开销比原生大很多的主要原因之一。
我个人认为用图片来展示的原因是：
通过CSS布局面对不同尺寸屏幕时以及各种布局方案下，各个组件会有各种各样的拉伸场景，UILabe中文字的大小font需要随着拉伸进行变化，通过计算来让font适应各种拉伸场景需要考虑的场景太多太复杂。
因此weex采用了图片进行展示的方法解决这个问题。



