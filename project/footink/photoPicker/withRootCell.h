//
//  withRootCell.h
//  photoPicker
//
//  Created by yongsik on 11. 7. 13..
//  Copyright 2011 ag. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface withRootCell : UITableViewCell {
    UILabel *textLabel;
}
@property (nonatomic, retain) UILabel *textLabel;

- (UILabel *)newLabelWithPrimaryColor:(UIColor *)primaryColor selectedColor:(UIColor *)selectedColor fontSize:(CGFloat)fontSize bold:(BOOL)bold;

@end
