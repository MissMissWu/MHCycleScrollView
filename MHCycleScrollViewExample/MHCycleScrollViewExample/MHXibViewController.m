//
//  MHXibViewController.m
//  MHCycleScrollViewExample
//
//  Created by apple on 16/6/28.
//  Copyright © 2016年 Mike_He. All rights reserved.
//

#import "MHXibViewController.h"
#import "MHCycleScrollView.h"
@interface MHXibViewController ()
@property (weak, nonatomic) IBOutlet MHCycleScrollView *cycleScrollView;

@property (weak, nonatomic) IBOutlet MHCycleScrollView *cycleScrollView2;
@end

@implementation MHXibViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    self.view.backgroundColor = [UIColor colorWithRed:0.98 green:0.98 blue:0.98 alpha:0.99];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
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

    
    self.cycleScrollView.localizationImageNamesGroup = [NSMutableArray arrayWithArray:imageNamesGroup];
    self.cycleScrollView.currentPageDotColor = [UIColor redColor];
    self.cycleScrollView.pageDotColor = [UIColor yellowColor];
    
    
    
    self.cycleScrollView2.placeholderImage = [UIImage imageNamed:@"placeholder"];
    self.cycleScrollView2.pageControlAliment = MHCycleScrollViewPageContolAlimentRight;
    self.cycleScrollView2.titlesGroup = titles;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.cycleScrollView2.imageURLStringsGroup = [NSMutableArray arrayWithArray:imagesURLStrings];
    });
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
