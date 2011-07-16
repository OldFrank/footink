//
//  SettingCell.h
//  photoPicker
//
//  Created by yongsik on 11. 6. 13..
//  Copyright 2011 ag. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SettingCell : UITableViewCell {
    UILabel *textLabel;
}
@property (nonatomic, retain) UILabel *textLabel;

- (UILabel *)newLabelWithPrimaryColor:(UIColor *)primaryColor selectedColor:(UIColor *)selectedColor fontSize:(CGFloat)fontSize bold:(BOOL)bold;

@end
