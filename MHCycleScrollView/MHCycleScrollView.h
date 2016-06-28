//
//  MHCycleScrollView.h
//  MHCycleScrollViewExample
//
//  Created by apple on 16/6/27.
//  Copyright © 2016年 Mike_He. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  PageControl显示的位置
 */
typedef enum {
    MHCycleScrollViewPageContolAlimentRight =10000, //右边
    MHCycleScrollViewPageContolAlimentCenter   // default is 中间
} MHCycleScrollViewPageContolAliment;

@class MHCycleScrollView;

@protocol MHCycleScrollViewDelegate <NSObject>

@optional

/** 点击图片回调 */
- (void)cycleScrollView:(MHCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index;

/** 图片滚动回调 */
- (void)cycleScrollView:(MHCycleScrollView *)cycleScrollView didScrollToIndex:(NSInteger)index;

@end


@interface MHCycleScrollView : UIView

//----------------------- 初始化 ----------------------------//
/** 网络初始轮播图（推荐使用） */
+ (instancetype)cycleScrollViewWithFrame:(CGRect)frame delegate:(id<MHCycleScrollViewDelegate>)delegate placeholderImage:(UIImage *)placeholderImage;



/** 本地图片轮播初始化方式 */
+ (instancetype)cycleScrollViewWithFrame:(CGRect)frame delegate:(id<MHCycleScrollViewDelegate>)delegate imageNamesGroup:(NSArray *)imageNamesGroup;

//----------------------- 初始化 ----------------------------//




/** 清楚缓存 由于内部图片下载使用的是 SDWebImage进行缓存的  所以调用了SDWebImage的方法 */
+ (void)clearImagesCache;

/** 解决viewWillAppear时出现时轮播图卡在一半的问题，在控制器viewWillAppear时调用此方法 */
- (void)adjustWhenControllerViewWillAppear;


/**
 *  开始自动滚动 建议在控制器 viewWillAppear 中调用
 */
- (void)startAutoScroll;

/**
 *  停止自动滚动 建议在控制器 viewWillDisAppear 中调用
 */
- (void) stopAutoScroll;




//----------------------- 数据源 ----------------------------//
/** 网络图片 url string 数组 */
@property (nonatomic , strong) NSArray *imageURLStringsGroup;

/** 每张图片对应要显示的文字数组 */
@property (nonatomic , strong) NSArray *titlesGroup;

/** 本地图片数组  传本地图片的名称 */
@property (nonatomic , strong) NSArray *localizationImageNamesGroup;
//----------------------- 数据源 ----------------------------//





/** 自动滚动间隔时间,默认2s */
@property (nonatomic , assign) CGFloat autoScrollTimeInterval;

/** 是否无限循环,默认Yes */
@property (nonatomic , assign ) BOOL infiniteLoop;

/** 是否自动滚动,默认Yes */
@property (nonatomic , assign ) BOOL autoScroll;

/** 图片滚动方向，默认为水平滚动 */
@property (nonatomic , assign) UICollectionViewScrollDirection scrollDirection;




//----------------------- 监听图片点击 ----------------------------//
/** 代理监听 */
@property (nonatomic, weak) id<MHCycleScrollViewDelegate> delegate;

/** block方式监听点击 */
@property (nonatomic, copy) void (^clickItemOperationBlock)(NSInteger currentIndex);

/** block方式监听滚动 */
@property (nonatomic, copy) void (^itemDidScrollOperationBlock)(NSInteger currentIndex);

//----------------------- 监听图片点击 ----------------------------//


/** 轮播图片的ContentMode，默认为 UIViewContentModeScaleToFill */
@property (nonatomic, assign) UIViewContentMode bannerImageViewContentMode;

/** 轮播文字label字体颜色 */
@property (nonatomic, strong) UIColor *titleLabelTextColor;

/** 轮播文字label字体大小 */
@property (nonatomic, strong) UIFont  *titleLabelTextFont;

/** 轮播文字label背景颜色 */
@property (nonatomic, strong) UIColor *titleLabelBackgroundColor;

/** 轮播文字label高度 */
@property (nonatomic, assign) CGFloat titleLabelHeight;


/** 占位图，用于网络未加载到图片时 */
@property (nonatomic, strong) UIImage *placeholderImage;

/** 是否显示分页控件 */
@property (nonatomic, assign) BOOL showPageControl;

/** 是否在只有一张图时隐藏pagecontrol，默认为YES */
@property(nonatomic , assign) BOOL hidesForSinglePage;

/** 只展示文字轮播 */
@property (nonatomic, assign , getter=isOnlyDisplayText) BOOL onlyDisplayText;

/** 当前分页控件小圆标颜色 默认白色 */
@property (nonatomic, strong) UIColor *currentPageDotColor;

/** 其他分页控件小圆标颜色 默认灰色 */
@property (nonatomic, strong) UIColor *pageDotColor;

/** 分页控件位置 默认显示在中间*/
@property (nonatomic, assign) MHCycleScrollViewPageContolAliment pageControlAliment;

/** 分页控件距离轮播图的底部间距（在默认间距基础上）的偏移量 */
@property (nonatomic, assign) CGFloat pageControlBottomOffset;

/** 分页控件距离轮播图的右边间距（在默认间距基础上）的偏移量 */
@property (nonatomic, assign) CGFloat pageControlRightOffset;

/** 分页控件小圆标大小 */
@property (nonatomic, assign) CGSize pageControlDotSize;


@end
