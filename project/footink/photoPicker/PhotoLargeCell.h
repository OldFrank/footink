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
   EGOImageView*profileView;
}
@property (nonatomic,retain) UIView *rightView;

- (void)setPhoto:(NSString*)Photo profile:(NSString*)icon;
@end
