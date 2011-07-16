//
//  PhotoRootCell.h
//  photoPicker
//
//  Created by yongsik on 11. 6. 29..
//  Copyright 2011 ag. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EGOImageView;
@interface PhotoCalCell : UITableViewCell {
@private
	EGOImageView* imageView;
    
    UILabel *titleLabel;
    
    NSInteger *itemID;

    UIScrollView *scrollView;
    IBOutlet UIView *dcellContentView;
}
-(void)setPhoto:(NSString*)Photo;
-(NSInteger)getID; 
-(UILabel *)newLabelWithPrimaryColor:(UIColor *)primaryColor selectedColor:(UIColor *)selectedColor fontSize:(CGFloat)fontSize bold:(BOOL)bold;

@property (nonatomic, retain) UILabel *titleLabel;
@property (nonatomic, assign) NSInteger *itemID;
@property (nonatomic, retain) UIScrollView *scrollView;

@property (nonatomic, assign) UIView *dcellContentView;
@end