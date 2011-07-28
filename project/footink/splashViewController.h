//
//  splashViewController.h
//  footink
//
//  Created by yongsik on 11. 7. 23..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface splashViewController : UIViewController {
    UIView *modalView;
    UIViewController *modalViewController;
}
@property (nonatomic,assign) UIViewController *modalViewController;
@property (nonatomic,retain) UIView *modalView;
-(void)showSplash;
-(void)hideSplash;
@end
