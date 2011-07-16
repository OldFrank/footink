//
//  PopAlertView.h
//  photoPicker
//
//  Created by yongsik on 11. 6. 23..
//  Copyright 2011 ag. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface PopAlertView : UIAlertView {
    UILabel *alertTextLabel;
	UIImage *backgroundImage;
    
}
@property(readwrite, retain) UIImage *backgroundImage;
@property(readwrite, retain) NSString *alertText;

- (id) initWithImage:(UIImage *)backgroundImage text:(NSString *)text;

@end
