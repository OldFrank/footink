//
//  PhotoRootCellBtn.h
//  photoPicker
//
//  Created by yongsik on 11. 6. 29..
//  Copyright 2011 ag. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface PhotoRootCellBtn : UITableViewCell {
    
    UILabel *titleLabel;
    
    NSInteger *itemID;
    UIImageView *DimageView;
    
    IBOutlet UIView *dcellContentView;
}
-(void)setData:(NSDictionary *)dict;
-(NSInteger)getID; 
-(UILabel *)newLabelWithPrimaryColor:(UIColor *)primaryColor selectedColor:(UIColor *)selectedColor fontSize:(CGFloat)fontSize bold:(BOOL)bold;

@property (nonatomic, retain) UILabel *titleLabel;
@property (nonatomic, assign) NSInteger *itemID;

@property (nonatomic, retain) UIImageView *DimageView;
@property (nonatomic, assign) UIView *dcellContentView;
@end