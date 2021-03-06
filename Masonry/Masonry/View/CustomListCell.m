//
//  CustomListCell.m
//  Masonry
//
//  Created by shavekevin on 16/1/26.
//  Copyright © 2016年 shavekevin. All rights reserved.
//

#import "CustomListCell.h"
#import "Masonry.h"

// 资源类型
typedef NS_ENUM(NSInteger,ImageType) {
    
    eImageType = 0,              //.
    eStableImageType = 1,// 有图
    eUnStableImageType = 2, //有图
    
    
};
//这里的枚举暂时没怎么卵用。 后面写复杂的时候可能会用到
static CGFloat const kLeftMargin = 5.0f;
static CGFloat const kLeftPadding = 10.0f;
static CGFloat const kBottomMargin = -10.0f;
static CGFloat const kTopMargin = 5.0f;
static CGFloat const kDefaultPadding = 0.0f;
static CGFloat const kSeperateLineHeight = 0.5f;
static CGFloat const kDefaultWidth = 20.0f;
static CGFloat const kDefaultSeperate = 10.0f;
static CGFloat const kTempImageviewHeight = 200.0f;
static CGFloat const kWithOutmageviewHeight = 0.0f;
static NSInteger const kDefaultFactor = 6;

#define PhoneBounds [UIScreen mainScreen].bounds

@interface CustomListCell ()

@property (nonatomic, strong) UILabel *nameLabel; // 名字
@property (nonatomic, strong) UILabel *contentLabel; // n内容
@property (nonatomic, strong) UIView *line; //分割线
@property (nonatomic, strong) UIImageView *iconImageView; //图片
@property (nonatomic, strong) UIView *bottomView;//底部的eview
@property (nonatomic, assign) BOOL isFirstVisit; //是否第一次
@property (nonatomic, assign) id  dataSourceElement;// 数据单元
@property (nonatomic, strong) UILabel *expandLabel; // 展开的label

@property (nonatomic, assign) BOOL isExpand; // 是否展开

@end

@implementation CustomListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        _isFirstVisit = NO;
    }
    return self;
}
- (UILabel *)contentLabel {
    
    if (!_contentLabel) {
        _contentLabel = [UILabel new];
        _contentLabel.numberOfLines = 0;
        _contentLabel.font = [UIFont systemFontOfSize:15];
        if ([_contentLabel isDescendantOfView:self.contentView] == NO) {
            [self.contentView addSubview:_contentLabel];
        }
    }
    return _contentLabel;
}

- (UILabel *)nameLabel {
    
    if (!_nameLabel) {
        _nameLabel = [UILabel new];
        _nameLabel.numberOfLines = 0;
        _nameLabel.font = [UIFont systemFontOfSize:13];
        if ([_nameLabel isDescendantOfView:self.contentView] == NO) {
            [self.contentView addSubview:_nameLabel];
        }
    }
    return _nameLabel;
}
- (UIView *)line {
    if (!_line) {
        _line = [UIView new];
        _line.backgroundColor = [UIColor redColor];
        if ([_line isDescendantOfView:self.contentView] == NO) {
            [self.contentView addSubview:_line];
        }
    }
    return _line;
}
- (UIImageView *)iconImageView {
    if (!_iconImageView ) {
        _iconImageView = [[UIImageView alloc]init];
        if ([_iconImageView isDescendantOfView:self.contentView] == NO) {
            [self.contentView addSubview:self.iconImageView];
        }
        
    }
    return _iconImageView;
}

-(UILabel *)expandLabel {
    if (!_expandLabel) {
        _expandLabel = [UILabel new];
        [_expandLabel setBackgroundColor:[UIColor orangeColor]];
        _expandLabel.userInteractionEnabled = YES;
        _expandLabel.preferredMaxLayoutWidth = CGRectGetWidth(PhoneBounds) - kDefaultSeperate;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap:)];
        [_expandLabel addGestureRecognizer:tap];
        [self.contentView addSubview:_expandLabel];
    }
    return _expandLabel;
}

-(UIView *)bottomView {
    
    if (!_bottomView) {
        _bottomView = [[UIView alloc]init];
        _bottomView.backgroundColor = [UIColor blackColor];
        [self.contentView addSubview:_bottomView];
        
    }
    return _bottomView;
}
- (void)layoutSubviews {
    
    //这个得写上 不写高度 出不来啊 因为自适应的高度的话宽度是要固定的。所以这里要给上最大的宽度
    _nameLabel.preferredMaxLayoutWidth = CGRectGetWidth(PhoneBounds) - kDefaultSeperate;
    _contentLabel.preferredMaxLayoutWidth = CGRectGetWidth(PhoneBounds) - kDefaultSeperate;

    [super layoutSubviews];
    
}

/**
 *  绑定数据源
 *
 *  @param dataSource 绑定数据源
 */
- (void)customListBlindCell:(id)dataSource {
    
    _dataSourceElement = dataSource;
    self.nameLabel.backgroundColor = [UIColor orangeColor];
    self.contentLabel.backgroundColor = [UIColor redColor];
    self.iconImageView.backgroundColor = [UIColor blackColor];
    self.bottomView.backgroundColor = [UIColor blackColor];
    //如果是1 或者2的话 高度固定 否则无图
    if ([dataSource  isEqualToString:[NSString stringWithFormat:@"%ld",(long)eUnStableImageType]]) {
         self.iconImageView.image =  [UIImage imageNamed:@"common.jpg"];
    } else if ([dataSource isEqualToString:[NSString stringWithFormat:@"%ld",(long)eStableImageType]]) {
        self.iconImageView.image =  [UIImage imageNamed:@"without.jpg"];
    }
    self.nameLabel.text = dataSource;
    self.contentLabel.text = dataSource;
    self.expandLabel.text = dataSource;
   
}
#pragma mark  - 约束的添加和更新
- (void)updateConstraints {
    
    [super updateConstraints];
    
    //第一次进来的话走的是make  再次进来走的是update 或者 remake
    /**
     *  这里为什么不写在init方法里的原因
     *
     *  @param !_isFirstVisit 为什么不把创建约束写在init方法的原因是因为我们的约束有可能会根据数据源进行添加。  我们在创建的时候已经默认把所有的约束添加了。(如果界面相差太大的话 不太建议采用masonry 来进行布局 因为需要不停的更新约束)
     *
     *  @return view
     */
    //这里我们在第一次的时候会把我们所有的控件约束加载一遍 这里只加载一次，然后我们需要在下面做的就是对约束进行更新
    if (!_isFirstVisit) {
        
        [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(kLeftMargin);
            make.top.mas_equalTo(kTopMargin * kDefaultFactor);
            make.right.mas_equalTo(kBottomMargin);
        }];
        [self.line mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.nameLabel.mas_bottom).offset(kLeftPadding);
            make.left.mas_equalTo(kLeftPadding);
            make.width.mas_equalTo(kDefaultWidth);
            make.height.mas_equalTo(kSeperateLineHeight);
        }];
        [self.contentLabel  mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(kLeftMargin);
            make.top.equalTo(self.line.mas_bottom).offset(kLeftPadding);
            make.right.mas_equalTo(kBottomMargin);
        }];
        [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentLabel.mas_bottom).offset(kLeftPadding);
            make.left.mas_equalTo(kDefaultPadding);
            make.right.mas_equalTo(kBottomMargin);
            make.height.mas_equalTo(100);
        }];
        
        [self.expandLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.top.equalTo(self.iconImageView.mas_bottom).offset(10);
            make.left.mas_equalTo(10);
            make.right.mas_equalTo(-10);
            
        }];
        [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.expandLabel.mas_bottom).offset(10);
            make.left.mas_equalTo(10);
            make.right.mas_equalTo(-10);
            make.height.mas_equalTo(20);
            make.bottom.equalTo(self.contentView.mas_bottom).offset(kBottomMargin);

        }];
        _isFirstVisit = YES;
    }
    //更新约束的适用范围：我们把动态的东西在这里进行更新 比如说图像的有无，label 文字的显隐等等。这里只需要做的是更新约束就好。
    
    //处理无图的情况
    if ([self.dataSourceElement isEqualToString:[NSString stringWithFormat:@"%ld",(long)eUnStableImageType]]||[self.dataSourceElement isEqualToString:[NSString stringWithFormat:@"%ld",(long)eStableImageType]]) {
        
        //处理有图的情况这里往往要把改动的约束加上。因为第一次的高不一定是我们想要的。
        [self.iconImageView  mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentLabel.mas_bottom).offset(kLeftPadding);
            make.height.mas_equalTo(kTempImageviewHeight);
        }];
        [self.expandLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.iconImageView.mas_bottom).offset(10);
        }];
        
    } else {
        
        // 这里只需要处理特殊情况 无图 的情况  有图的 可以考虑更新图的高度之类的
        [self.iconImageView  mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentLabel.mas_bottom).offset(10);
            make.height.mas_equalTo(kWithOutmageviewHeight);
        }];
        
        [self.expandLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.iconImageView.mas_bottom).offset(0);
            
        }];
    }
    
}

- (void)tap:(UITapGestureRecognizer *)sender {
    
    if (self.isExpand) {
        self.expandLabel.numberOfLines = 0;
        self.isExpand = NO;
    } else  {
        self.isExpand = YES;
        self.expandLabel.numberOfLines = 1;

    }
    if (self.reloadTableviewBlock) {
    self.reloadTableviewBlock();
    }
}

- (CGFloat)calculateHeightWithModel:(id)model {
    
    [self customListBlindCell:model];
    return  [self calculateHeight];
}
@end
