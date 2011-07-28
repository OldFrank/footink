//
//  PhotoLargeCell.h
//  photoPicker
//
//  Created by yongsik on 11. 7. 2..
//  Copyright 2011 ag. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EGOImageView;
@interface PhotoLargeCell : UITableViewCell {
@private
	EGOImageView* imageView;
    UIView *rightView;
    UIView *infDisplay;
    EGOImageView*profileView;
    UILabel *lovedlabel;
    UILabel *comlabel;
}
@property (nonatomic,retain) UIView *rightView;
@property (nonatomic,retain) UIView *infDisplay;
@property (nonatomic,retain) UILabel *lovedlabel;
@property (nonatomic,retain) UILabel *comlabel;

- (void)setPhoto:(NSString*)Photo profile:(NSString*)icon;
@end
