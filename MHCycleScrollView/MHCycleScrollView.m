//
//  MHCycleScrollView.m
//  MHCycleScrollViewExample
//
//  Created by apple on 16/6/27.
//  Copyright © 2016年 Mike_He. All rights reserved.
//

#import "MHCycleScrollView.h"
#import "UIView+MHFrame.h"
#import "UIImageView+WebCache.h"
#import "SDImageCache.h"
#import "MHCollectionViewCell.h"

#define kCycleScrollViewInitialPageControlDotSize CGSizeMake(10, 10)


@interface MHCycleScrollView () <UICollectionViewDelegate , UICollectionViewDataSource >

/** 布局 */
@property (nonatomic , weak)UICollectionViewFlowLayout *flowLayout;

/** 显示图片的collectionView */
@property (nonatomic , weak) UICollectionView *mainView;

/** 定时器(用weak比较安全 定时器会强引用对象 导致释放掉) **/
@property (weak, nonatomic) NSTimer *timer;

/** 数据源总数量 */
@property (nonatomic, assign) NSInteger totalItemsCount;

/** 图片数组 URL 或者 UIImage*/
@property (nonatomic, strong) NSArray *imagePathsGroup;

/** f分页控件 */
@property (nonatomic , weak) UIPageControl *pageControl;

/** 当imageURLs为空时的背景图 */
@property (nonatomic, strong) UIImageView *backgroundImageView;

@end

/** 复用标识 */
static NSString * const reuseIdentifier = @"cycleCell";


@implementation MHCycleScrollView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // 1.基础配置
        [self setup];
        
        // 2.设置子控件
        [self setupSubViews];
    }
    return self;
}

- (void)awakeFromNib
{
    // 1.基础配置
    [self setup];
    
    // 2.设置子控件
    [self setupSubViews];
}

//解决当父View释放时，当前视图因为被Timer强引用而不能释放的问题
- (void)willMoveToSuperview:(UIView *)newSuperview
{
    if (!newSuperview) {
        [self stopTimer];
    }
}

//解决当timer释放后 回调scrollViewDidScroll时访问野指针导致崩溃
- (void)dealloc
{
    
     NSLog(@"-- [MHCycleScrollView dealloc] --");
    _mainView.delegate = nil;
    _mainView.dataSource = nil;
}





#pragma mark - 基础配置
- (void)setup
{
    // 分页控件显示在中间
    _pageControlAliment = MHCycleScrollViewPageContolAlimentCenter;
    // 默认自动滚动
    _autoScroll = YES;
    // 默认循环滚动
    _infiniteLoop = YES;
    // 默认显示分页控件
    _showPageControl = YES;
    // 默认当图片为一张的时候 隐藏分页控件
    _hidesForSinglePage = YES;
    // 自动滚动的时间间隔
    _autoScrollTimeInterval = 2.0f;
    // 默认白色
    _currentPageDotColor = [UIColor whiteColor];
    // 默认灰色
    _pageDotColor = [UIColor lightGrayColor];
    // 分页小圆标的大小
    _pageControlDotSize = kCycleScrollViewInitialPageControlDotSize;
    // 分页控件的距离底部偏移量
    _pageControlBottomOffset = 0;
    // 分页控件的距离右边的偏移量
    _pageControlRightOffset = 0;
    // 文字颜色
    _titleLabelTextColor = [UIColor whiteColor];
    // 字体大小
    _titleLabelTextFont= [UIFont systemFontOfSize:14];
    // 背景颜色
    _titleLabelBackgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    // 文字高度
    _titleLabelHeight = 30;
    // 显示图片的内容模式
    _bannerImageViewContentMode = UIViewContentModeScaleToFill;
    
    
    self.backgroundColor = [UIColor lightGrayColor];
}


#pragma mark - 设置子控件
- (void) setupSubViews
{
    // 1.初始化布局
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    // 设置cell之间的垂直间距
    flowLayout.minimumLineSpacing = 0;
    // 水平滚动
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    _flowLayout = flowLayout;
    
    
    // 2.初始化主View
    UICollectionView *mainView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:flowLayout];
    mainView.backgroundColor = [UIColor clearColor];
    mainView.pagingEnabled = YES;
    mainView.showsHorizontalScrollIndicator = NO;
    mainView.showsVerticalScrollIndicator = NO;
    [mainView registerClass:[MHCollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    mainView.dataSource = self;
    mainView.delegate = self;
    // 设置不需要点击状态栏 滚动顶部
    mainView.scrollsToTop = NO;
    [self addSubview:mainView];
    _mainView = mainView;
}
#pragma mark - 创建分页控制器
- (void) setupPageControl
{
    if (_pageControl) [_pageControl removeFromSuperview]; // 重新加载数据时调整
    
    if (self.imagePathsGroup.count == 0 ||  self.onlyDisplayText)    return;
    
    if ((self.imagePathsGroup.count == 1) && self.hidesForSinglePage) return;
    
    
    // 当前展示的item
    NSUInteger itemIndex = [self currentItemIndex];
    // 当前cell对应的实际 图片索引
    NSUInteger pageControlIndex = [self pageControlIndexWithCurrentCellIndex:itemIndex];
    
    UIPageControl *pageControl = [[UIPageControl alloc] init];
    pageControl.numberOfPages = self.imagePathsGroup.count;
    pageControl.currentPageIndicatorTintColor = self.currentPageDotColor;
    pageControl.pageIndicatorTintColor = self.pageDotColor;
    pageControl.userInteractionEnabled = NO;
    pageControl.currentPage = pageControlIndex;
    [self addSubview:pageControl];
    _pageControl = pageControl;
    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    //设置每个显示的item的尺寸
    _flowLayout.itemSize = self.frame.size;
    //collectionView的尺寸
    _mainView.frame = self.bounds;
    
    
    
    if (_mainView.contentOffset.x == 0 &&  _totalItemsCount)
    {
        NSInteger targetIndex = 0;
        if (self.infiniteLoop)
        {
            //循环滚动的时候 滚动中间
            targetIndex = _totalItemsCount * 0.5;
        }else{
            targetIndex = 0;
        }
        [_mainView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:targetIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
    }
    
 
    
   CGSize size = CGSizeMake(self.imagePathsGroup.count * self.pageControlDotSize.width * 1.5, self.pageControlDotSize.height);
    //默认中间
    CGFloat x = (self.mh_width - size.width) * 0.5;
    if (self.pageControlAliment == MHCycleScrollViewPageContolAlimentRight)
    {
        // 右边
        x = self.mainView.mh_width - size.width - 10;
    }
    CGFloat y = self.mainView.mh_height - size.height - 10;
    // 设置尺寸
    CGRect pageControlFrame = CGRectMake(x, y, size.width, size.height);
    pageControlFrame.origin.y -= self.pageControlBottomOffset;
    pageControlFrame.origin.x -= self.pageControlRightOffset;
   
    self.pageControl.frame = pageControlFrame;
    self.pageControl.hidden = !_showPageControl;
    
    if (self.backgroundImageView)
    {
        self.backgroundImageView.frame = self.bounds;
    }
}



#pragma mark - 公有方法
+ (instancetype)cycleScrollViewWithFrame:(CGRect)frame delegate:(id<MHCycleScrollViewDelegate>)delegate placeholderImage:(UIImage *)placeholderImage
{
    MHCycleScrollView *cycleScrollView = [[self alloc] initWithFrame:frame];
    cycleScrollView.delegate = delegate;
    cycleScrollView.placeholderImage = placeholderImage;
    return cycleScrollView;
}

+ (instancetype)cycleScrollViewWithFrame:(CGRect)frame delegate:(id<MHCycleScrollViewDelegate>)delegate imageNamesGroup:(NSArray *)imageNamesGroup
{
    MHCycleScrollView *cycleScrollView = [[self alloc] initWithFrame:frame];
    cycleScrollView.delegate = delegate;
    cycleScrollView.localizationImageNamesGroup = [NSMutableArray arrayWithArray:imageNamesGroup];
    return cycleScrollView;
}

// 清楚缓存 由于内部图片下载使用的是 SDWebImage进行缓存的  所以调用了SDWebImage的方法
+ (void)clearImagesCache
{
    [[[SDWebImageManager sharedManager] imageCache] clearDisk];
}

// 适配当图片 卡在中间的情况下的适配
- (void)adjustWhenControllerViewWillAppear
{
    // 当前展示的item
    NSInteger itemIndex = [self currentItemIndex];
    
    if (itemIndex < _totalItemsCount) {
        [_mainView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:itemIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
    }
}


/**
 *  开始自动滚动 建议在控制器 viewWillAppear 中调用
 */
- (void)startAutoScroll
{
    [self stopTimer];
    if (_autoScroll)  [self startTimer];
}

/**
 *  停止自动滚动 建议在控制器 viewWillDisAppear 中调用
 */
- (void) stopAutoScroll
{
    if (_autoScroll) [self stopTimer];
}
#pragma mark - setterPublic
- (void)setPlaceholderImage:(UIImage *)placeholderImage
{
    _placeholderImage = placeholderImage;
    
    if (!self.backgroundImageView)
    {
        UIImageView *bgImageView = [UIImageView new];
        bgImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self insertSubview:bgImageView belowSubview:self.mainView];
        self.backgroundImageView = bgImageView;
    }
    
    self.backgroundImageView.image = placeholderImage;
}


- (void)setShowPageControl:(BOOL)showPageControl
{
    _showPageControl = showPageControl;
    
    _pageControl.hidden = !showPageControl;
}

- (void)setCurrentPageDotColor:(UIColor *)currentPageDotColor
{
    _currentPageDotColor = currentPageDotColor;
    
    self.pageControl.currentPageIndicatorTintColor = currentPageDotColor;
}

- (void)setPageDotColor:(UIColor *)pageDotColor
{
    _pageDotColor = pageDotColor;
    
    self.pageControl.pageIndicatorTintColor = pageDotColor;

}

- (void)setPageControlDotSize:(CGSize)pageControlDotSize
{
    _pageControlDotSize = pageControlDotSize;
    
    //是否需要重新布局
//    [self setNeedsLayout];
}


- (void)setInfiniteLoop:(BOOL)infiniteLoop
{
    _infiniteLoop = infiniteLoop;
    
    if (self.imagePathsGroup.count)
    {
        // 重新赋值 去刷新数据源方法
        self.imagePathsGroup = self.imagePathsGroup;
    }
}

-(void)setAutoScroll:(BOOL)autoScroll
{
    _autoScroll = autoScroll;
    
    // 清掉定时器
    [self stopTimer];
    
    if (_autoScroll) {
        // 开启定时器
        [self startTimer];
    }
}

- (void)setScrollDirection:(UICollectionViewScrollDirection)scrollDirection
{
    _scrollDirection = scrollDirection;
    
    _flowLayout.scrollDirection = scrollDirection;
}

- (void)setAutoScrollTimeInterval:(CGFloat)autoScrollTimeInterval
{
    _autoScrollTimeInterval = autoScrollTimeInterval;
    
    // 重新设置定时器
    [self setAutoScroll:self.autoScroll];
}

- (void)setImageURLStringsGroup:(NSArray *)imageURLStringsGroup
{
    _imageURLStringsGroup = imageURLStringsGroup;
    
    NSMutableArray *temp = [NSMutableArray new];
    [_imageURLStringsGroup enumerateObjectsUsingBlock:^(NSString * obj, NSUInteger idx, BOOL * stop) {
        NSString *urlString;
        if ([obj isKindOfClass:[NSString class]])
        {
            urlString = obj;
        } else if ([obj isKindOfClass:[NSURL class]]) {
            NSURL *url = (NSURL *)obj;
            urlString = [url absoluteString];
        }
        if (urlString) {
            [temp addObject:urlString];
        }
    }];
    self.imagePathsGroup = [temp copy];
}

- (void)setLocalizationImageNamesGroup:(NSArray *)localizationImageNamesGroup
{
    _localizationImageNamesGroup = localizationImageNamesGroup;
    
    // 浅拷贝
    self.imagePathsGroup = [localizationImageNamesGroup copy];
}

- (void)setTitlesGroup:(NSArray *)titlesGroup
{
    _titlesGroup = titlesGroup;
    
    if (self.isOnlyDisplayText)
    {
        NSMutableArray *temp = [NSMutableArray new];
        for (int i = 0; i < _titlesGroup.count; i++)
        {
            [temp addObject:@""];
        }
        self.backgroundColor = [UIColor clearColor];
        
        // 浅拷贝
        self.imageURLStringsGroup = [temp copy];
    }
}
#pragma mark - setterPrivate
- (void)setImagePathsGroup:(NSArray *)imagePathsGroup
{
    // 销毁定时器
    [self stopTimer];
    
    _imagePathsGroup = imagePathsGroup;
    
    _totalItemsCount = self.infiniteLoop ? self.imagePathsGroup.count * 100 : self.imagePathsGroup.count;
    
    if (imagePathsGroup.count != 1)
    { //多张图片
        self.mainView.scrollEnabled = YES;
        // 开启定时器
        [self setAutoScroll:self.autoScroll];
    } else { // 一张图片
        // 不准滚动
        self.mainView.scrollEnabled = NO;
    }
    
    // 创建分页控件
    [self setupPageControl];
    
    // 刷新
    [self.mainView reloadData];
}


#pragma mark - 私有方法
#pragma mark - 当前展示的 图片的索引
- (NSInteger)currentItemIndex
{
    // 宽高为0 排除掉
    if (_mainView.mh_width == 0 || _mainView.mh_height == 0) return 0;
    
    NSInteger index = 0;
    if (_flowLayout.scrollDirection == UICollectionViewScrollDirectionHorizontal) //水平方向
    {
        // 获取index 这种算法获取当前展示的 item 比较准确
        index = (_mainView.contentOffset.x + _flowLayout.itemSize.width * 0.5) / _flowLayout.itemSize.width;
    } else // 垂直方向
    {
        // 获取index 这种算法获取当前展示的 item 比较准确
        index = (_mainView.contentOffset.y + _flowLayout.itemSize.height * 0.5) / _flowLayout.itemSize.height;
    }
    
    return MAX(0, index);
}

#pragma mark - 获取当前对应的cell对应的 pageControl的索引
- (NSInteger)pageControlIndexWithCurrentCellIndex:(NSInteger)index
{
    return (NSUInteger)index % self.imagePathsGroup.count;
}


#pragma mark - 定时器处理 开始和停止
- (void)startTimer
{
    NSTimer *timer = [NSTimer timerWithTimeInterval:self.autoScrollTimeInterval target:self selector:@selector(automaticScroll) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    _timer = timer;
}

- (void)stopTimer
{
    [_timer invalidate];
    _timer = nil;
}

#pragma mark - 自动滚动
- (void)automaticScroll
{
    // 如果没有数据  就排除掉
    if (0 == _totalItemsCount)  return;
    
    // 当前展示的item
    NSInteger itemIndex = [self currentItemIndex];
    // 下一页
    NSInteger targetIndex = itemIndex + 1;
    
    // 滚动到下一页
    [self scrollToTargetIndex:targetIndex];
}

#pragma mark - 滚动到指定的页
- (void)scrollToTargetIndex:(NSInteger)targetIndex
{
    //滚动最后一页的时候
    if (targetIndex >= _totalItemsCount)
    {
        if (self.infiniteLoop) //如果是循环滚动
        {
            // 就让他滚动中间
            targetIndex = _totalItemsCount * 0.5;
            // 回滚的时候 不要设置为有动画 否则有点卡顿
            [_mainView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:targetIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
        }
        return;
    }
    // 顺序滚动 设置动画
    [_mainView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:targetIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
}



#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _totalItemsCount;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MHCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    long itemIndex = [self pageControlIndexWithCurrentCellIndex:indexPath.item];
    
    // 获取对应的item
    NSString *imagePath = self.imagePathsGroup[itemIndex];
    
    // 字符串
    if (!self.onlyDisplayText && [imagePath isKindOfClass:[NSString class]])
    {
        if ([imagePath hasPrefix:@"http"])  //如果是字符串链接
        {
            // 加载网络图片
            [cell.imageView sd_setImageWithURL:[NSURL URLWithString:imagePath] placeholderImage:self.placeholderImage];
        } else {
            
            // 本地图片
            UIImage *image = [UIImage imageNamed:imagePath];
            if (!image) {
                [UIImage imageWithContentsOfFile:imagePath];
            }
            // 赋值
            cell.imageView.image = image;
        }
    } else if (!self.onlyDisplayText && [imagePath isKindOfClass:[UIImage class]])
    {
        // 图片
        cell.imageView.image = (UIImage *)imagePath;
    }
    
    if (_titlesGroup.count && itemIndex < _titlesGroup.count)
    {
        cell.titleLabel.hidden = NO;
        cell.titleLabel.text =[NSString stringWithFormat:@"   %@",  _titlesGroup[itemIndex]];
    }

    if (!cell.hasConfigured)
    {
        // 这些属性初始化一次  就可以了
        cell.titleLabel.backgroundColor = self.titleLabelBackgroundColor;
        cell.titleLabelHeight = self.titleLabelHeight;
        cell.titleLabel.textColor = self.titleLabelTextColor;
        cell.titleLabel.font = self.titleLabelTextFont;
        cell.hasConfigured = YES;
        cell.imageView.contentMode = self.bannerImageViewContentMode;
        cell.clipsToBounds = YES;
        cell.onlyDisplayText = self.onlyDisplayText;
    }
    
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    // 代理回调
    if (self.delegate && [self.delegate respondsToSelector:@selector(cycleScrollView:didSelectItemAtIndex:)]) {
        [self.delegate cycleScrollView:self didSelectItemAtIndex:[self pageControlIndexWithCurrentCellIndex:indexPath.item]];
    }
    
    // block回调
    if (self.clickItemOperationBlock) {
        self.clickItemOperationBlock([self pageControlIndexWithCurrentCellIndex:indexPath.item]);
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (!self.imagePathsGroup.count) return; // 解决清除timer时偶尔会出现的问题
    // 当前展示的item
    NSUInteger itemIndex = [self currentItemIndex];
    // 当前cell对应的实际 图片索引
    NSUInteger pageControlIndex = [self pageControlIndexWithCurrentCellIndex:itemIndex];
    
    // 设置当前pageControl的索引
    UIPageControl *pageControl = (UIPageControl *)_pageControl;
    pageControl.currentPage = pageControlIndex;
    
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (self.autoScroll) [self stopTimer];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (self.autoScroll) [self startTimer];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self scrollViewDidEndScrollingAnimation:self.mainView];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    if (!self.imagePathsGroup.count) return; // 解决清除timer时偶尔会出现的问题
    // 当前展示的item
    NSInteger itemIndex = [self currentItemIndex];
    // 当前cell对应的实际 图片索引
    NSInteger pageControlIndex = [self pageControlIndexWithCurrentCellIndex:itemIndex];
    
    
    // 监听图片点击
    if ([self.delegate respondsToSelector:@selector(cycleScrollView:didScrollToIndex:)]) {
        [self.delegate cycleScrollView:self didScrollToIndex:pageControlIndex];
    } else if (self.itemDidScrollOperationBlock) {
        self.itemDidScrollOperationBlock(pageControlIndex);
    }
}


@end
