//
//  AddViewController.h
//  photoPicker
//
//  Created by yongsik on 11. 4. 30..
//  Copyright 2011 ag. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AddViewControllerDelegate;

@interface AddViewController : UIViewController {
	UITextField *txtMemo;
	UISlider *slider;
	UILabel *lblSlider;
	id<AddViewControllerDelegate> delegate;
}
@property (nonatomic, assign) id<AddViewControllerDelegate> delegate;

@end

@protocol AddViewControllerDelegate<NSObject>
@optional
- (void)AddviewSubmitWithMemo:(NSString *)Memo Priority:(int)Priority;

@end
