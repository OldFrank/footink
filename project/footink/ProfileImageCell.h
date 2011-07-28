//
//  ProfileImageCell.h
//  footink
//
//  Created by yongsik on 11. 7. 28..
//  Copyright 2011년 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProfileImageCell : UITableViewCell{
UILabel *titleLabel;
UILabel *urlLabel;
NSInteger *itemID; 
UIImageView *imageView; // added this
}

// these are the functions we will create in the .m file

-(void)setData:(NSDictionary *)dict;
-(NSInteger)getID;

-(UILabel *)newLabelWithPrimaryColor:(UIColor *)primaryColor selectedColor:(UIColor *)selectedColor fontSize:(CGFloat)fontSize bold:(BOOL)bold;

@property (nonatomic, retain) UILabel *titleLabel;
@property (nonatomic, retain) UILabel *urlLabel;
@property (nonatomic, assign) NSInteger *itemID;
@property (nonatomic, retain) UIImageView *imageView;  // added this

@end
