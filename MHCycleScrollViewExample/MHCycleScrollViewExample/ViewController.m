//
//  ViewController.m
//  MHCycleScrollViewExample
//
//  Created by apple on 16/6/27.
//  Copyright © 2016年 Mike_He. All rights reserved.
//

#import "ViewController.h"
#import "MHXibViewController.h"
#import "MHCycleScrollView.h"

@interface ViewController () <MHCycleScrollViewDelegate>
/** cycle1 */
@property (nonatomic , weak) MHCycleScrollView *cycleScrollView ;

/** cycle2*/
@property (nonatomic , weak) MHCycleScrollView *cycleScrollView2 ;
@end

@implementation ViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // 如果你发现你的CycleScrollview会在viewWillAppear时图片卡在中间位置，你可以调用此方法调整图片位置
    [self.cycleScrollView adjustWhenControllerViewWillAppear];
    [self.cycleScrollView2 adjustWhenControllerViewWillAppear];
    
    [self.cycleScrollView startAutoScroll];
    [self.cycleScrollView2 startAutoScroll];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.cycleScrollView stopAutoScroll];
    [self.cycleScrollView2 stopAutoScroll];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithRed:0.98 green:0.98 blue:0.98 alpha:0.99];
    
    
    // 情景一：采用本地图片实现
    NSArray *imageNamesGroup = @[@"img_00",
                            @"img_01",
                            @"img_02",
                            @"img_03",
                            @"img_04" // 本地图片请填写全名
                            ];
    
    // 情景二：采用网络图片实现
    NSArray *imagesURLStrings = @[
                                  @"https://ss2.baidu.com/-vo3dSag_xI4khGko9WTAnF6hhy/super/whfpf%3D425%2C260%2C50/sign=a4b3d7085dee3d6d2293d48b252b5910/0e2442a7d933c89524cd5cd4d51373f0830200ea.jpg",
                                  @"https://ss0.baidu.com/-Po3dSag_xI4khGko9WTAnF6hhy/super/whfpf%3D425%2C260%2C50/sign=a41eb338dd33c895a62bcb3bb72e47c2/5fdf8db1cb134954a2192ccb524e9258d1094a1e.jpg",
                                  @"http://c.hiphotos.baidu.com/image/w%3D400/sign=c2318ff84334970a4773112fa5c8d1c0/b7fd5266d0160924c1fae5ccd60735fae7cd340d.jpg"
                                  ];
    
    // 情景三：图片配文字
    NSArray *titles = @[@"爱生活、爱代码、爱篮球、爱我所爱",
                        @"我是程序猿，我为自己代言",
                        @"感谢您的支持，喜欢就star一下，(*^__^*)",
                        @"https://github.com/CoderMikeHe"
                        ];
    
    CGFloat w = self.view.bounds.size.width;
    
    
// >>>>>>>>>>>>>>>>>>>>>>>>> demo轮播图1 >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    // 本地加载 --- 创建不带标题的图片轮播器
    MHCycleScrollView *cycleScrollView = [MHCycleScrollView cycleScrollViewWithFrame:CGRectMake(0, 64, w, 130) delegate:self imageNamesGroup:imageNamesGroup];
    //设置滚动方向
    cycleScrollView.scrollDirection = UICollectionViewScrollDirectionVertical;
    //--- 轮播时间间隔，默认2.0秒，可自定义时间间隔
    cycleScrollView.autoScrollTimeInterval = 4.0;
    self.cycleScrollView = cycleScrollView;
    [self.view addSubview:cycleScrollView];

    
// >>>>>>>>>>>>>>>>>>>>>>>>> demo轮播图2 >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    
    // 网络加载 --- 创建带标题的图片轮播器
    MHCycleScrollView *cycleScrollView2 = [MHCycleScrollView cycleScrollViewWithFrame:CGRectMake(0, 280, w, 180) delegate:self placeholderImage:[UIImage imageNamed:@"placeholder"]];
    
    cycleScrollView2.pageControlAliment = MHCycleScrollViewPageContolAlimentRight;
    cycleScrollView2.titlesGroup = titles;
    cycleScrollView2.currentPageDotColor = [UIColor redColor]; // 自定义分页控件小圆标颜色
    self.cycleScrollView2 = cycleScrollView2;
    [self.view addSubview:cycleScrollView2];
    
    //         --- 模拟加载延迟
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        cycleScrollView2.imageURLStringsGroup = imagesURLStrings;
    });
    
    /*
     block监听点击方式
     
     cycleScrollView2.clickItemOperationBlock = ^(NSInteger index) {
     NSLog(@">>>>>  %ld", (long)index);
     };
     
     */
    
    
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


#pragma mark - MHCycleScrollViewDelegate
/*
- (void)cycleScrollView:(MHCycleScrollView *)cycleScrollView didScrollToIndex:(NSInteger)index
{
    NSLog(@"didScrollToIndex-----[%zd]",index);
}
*/

- (void) cycleScrollView:(MHCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index
{
    NSLog(@"didSelectItemAtIndex-----[%zd]",index);
    
    
    MHXibViewController *xib = [[MHXibViewController alloc] init];
    [self.navigationController pushViewController:xib animated:YES];
}

@end
