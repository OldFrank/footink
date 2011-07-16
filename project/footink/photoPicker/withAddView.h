//
//  withAddView.h
//  photoPicker
//
//  Created by yongsik on 11. 7. 13..
//  Copyright 2011 ag. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol withAddViewDelegate;

@interface withAddView : UIViewController {
	UITextField *txtMemo;
	UISlider *slider;
	UILabel *lblSlider;
	id<withAddViewDelegate> delegate;
}
@property (nonatomic, assign) id<withAddViewDelegate> delegate;

@end

@protocol withAddViewDelegate<NSObject>
@optional
- (void)AddviewSubmitWithMemo:(NSString *)Memo Priority:(int)Priority;

@end
