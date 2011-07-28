//
//  WithRootViewController.h
//  footink
//
//  Created by yongsik on 11. 7. 26..
//  Copyright 2011년 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WithRootViewController : UIViewController<UINavigationControllerDelegate>{
    UIView *newTabBar;
    UIButton *cameraButton;
}
@property (nonatomic, retain) UIView *newTabBar;
@property (nonatomic, retain) UIButton *cameraButton;
@end
