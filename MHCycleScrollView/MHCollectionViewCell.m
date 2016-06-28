//
//  MHCollectionViewCell.m
//  MHCycleScrollViewExample
//
//  Created by apple on 16/6/27.
//  Copyright © 2016年 Mike_He. All rights reserved.
//

#import "MHCollectionViewCell.h"
#import "UIView+MHFrame.h"
@interface MHCollectionViewCell ()



@end


@implementation MHCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // 初始化ImageView
        [self setupImageView];
        
        // 初始化主题label
        [self setupTitleLabel];
    }
    return self;
}

- (void)setupImageView
{
    UIImageView *imageView = [[UIImageView alloc] init];
    _imageView = imageView;
    [self.contentView addSubview:imageView];
}

- (void)setupTitleLabel
{
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font = [UIFont systemFontOfSize:14.0f];
    titleLabel.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    _titleLabel = titleLabel;
    _titleLabel.hidden = YES;
    [self.contentView addSubview:titleLabel];
    
    
    _titleLabelHeight = 30;
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (self.isOnlyDisplayText) {
        self.titleLabel.frame = self.bounds;
    }else{
        _imageView.frame = self.bounds;
        CGFloat titleLabelW = self.mh_width;
        CGFloat titleLabelH = _titleLabelHeight;
        CGFloat titleLabelX = 0;
        CGFloat titleLabelY = self.mh_height - titleLabelH;
        _titleLabel.frame = CGRectMake(titleLabelX, titleLabelY, titleLabelW, titleLabelH);
    }
}

@end
