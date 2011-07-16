//
//  SearchListCellView.h
//  photoPicker
//
//  Created by yongsik on 11. 6. 21..
//  Copyright 2011 ag. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EGOImageView;
@interface SearchListCellView : UITableViewCell {
        UILabel *titleLabel;
        UILabel *distanceLabel;
        NSInteger *itemID;
        EGOImageView *DimageView;
        
        IBOutlet UIView *dcellContentView;
    }

    -(NSInteger)getID; 
-(void)setData:(NSDictionary *)dict;
    -(UILabel *)newLabelWithPrimaryColor:(UIColor *)primaryColor selectedColor:(UIColor *)selectedColor fontSize:(CGFloat)fontSize bold:(BOOL)bold;
    
    @property (nonatomic, retain) UILabel *titleLabel;
    @property (nonatomic, retain) UILabel *distanceLabel;
    @property (nonatomic, assign) NSInteger *itemID;
    

    @property (nonatomic, assign) UIView *dcellContentView;
    @end
