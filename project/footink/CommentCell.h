//
//  CommentCell.h
//  footink
//
//  Created by yongsik on 11. 7. 27..
//  Copyright 2011년 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGOImageView.h"

@class EGOImageView;

@interface CommentCell : UITableViewCell{
    UILabel *titleLabel;
    UILabel *writer;
    NSInteger *itemID;
    EGOImageView *DimageView;

    UIView *dcellContentView;
    UILabel *rdate;
}

-(void)setData:(NSDictionary *)dict;
-(UILabel *)newLabelWithPrimaryColor:(UIColor *)primaryColor selectedColor:(UIColor *)selectedColor fontSize:(CGFloat)fontSize bold:(BOOL)bold;

@property (nonatomic, retain) UILabel *titleLabel;
@property (nonatomic, retain) UILabel *writer;
@property (nonatomic, retain) UILabel *rdate;
@property (nonatomic, assign) UIView *dcellContentView;

@end

