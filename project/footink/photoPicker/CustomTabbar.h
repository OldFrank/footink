//
//  CustomTabbar.h
//  photoPicker
//
//  Created by yongsik on 11. 7. 3..
//  Copyright 2011 ag. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface CustomTabbar : UITabBarController {
	UIButton *btn1;
	UIButton *btn2;
	UIButton *btn3;
	UIButton *btn4;
}

@property (nonatomic, retain) UIButton *btn1;
@property (nonatomic, retain) UIButton *btn2;
@property (nonatomic, retain) UIButton *btn3;
@property (nonatomic, retain) UIButton *btn4;

-(void) hideTabBar;
-(void) addCustomElements;
-(void) selectTab:(int)tabID;

@end