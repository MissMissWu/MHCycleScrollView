//
//  MHCollectionViewCell.h
//  MHCycleScrollViewExample
//
//  Created by apple on 16/6/27.
//  Copyright © 2016年 Mike_He. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MHCollectionViewCell : UICollectionViewCell
/** 显示的图片 */
@property (weak, nonatomic) UIImageView *imageView;

/**
 *  要显示的文字
 */
@property (weak, nonatomic) UILabel *titleLabel;

/**
 *  文字高度
 */
@property (nonatomic, assign) CGFloat titleLabelHeight;

/**
 *  是否已经初始化了
 */
@property (nonatomic, assign , getter=isHasConfigured) BOOL hasConfigured;

/** 只展示文字轮播 */
@property (nonatomic, assign , getter=isOnlyDisplayText) BOOL onlyDisplayText;
@end
