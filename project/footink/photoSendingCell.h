//
//  photoSendingCell.h
//  footink
//
//  Created by yongsik on 11. 7. 21..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface photoSendingCell : UITableViewCell {
    UILabel *textLabel;
}
@property (nonatomic, retain) UILabel *textLabel;

- (UILabel *)newLabelWithPrimaryColor:(UIColor *)primaryColor selectedColor:(UIColor *)selectedColor fontSize:(CGFloat)fontSize bold:(BOOL)bold;

@end