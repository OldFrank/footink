//
//  footinkAppDelegate.h
//  footink
//
//  Created by yongsik on 11. 7. 17..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "photoPickerViewController.h"
#import "PhotoRoot.h"
#import "withRootView.h"
#import "SettingView.h"
#import "LoginView.h"
#import "tripMapViewController.h"
#import "AudioToolBox/AudioServices.h"
#import "FBConnect.h"
#import "FBSession.h"
#import "SpotListViewController.h"
//#import "CustomTabbar.h"

@class FacebookAPIViewController;

@interface footinkAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate> {
    UITabBarController *tabController;
    UIWindow *window;
    UITextView *textView;
    //UINavigationController *navigationController;
    FBSession *_fsession;
    FacebookAPIViewController *FBviewController;
    UIImageView* tabBarArrow;
}

@property (nonatomic, retain) IBOutlet FacebookAPIViewController *FBviewController;
@property (nonatomic,retain) FBSession *_fsession;
@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *tabController;
@property (nonatomic, retain) IBOutlet UITextView *textView;
@property (nonatomic, retain) UIImageView* tabBarArrow;
//@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;

- (NSArray *)ChkAuth;
- (void)initAuth;
-(void)carrierTelCountryCode;
@end
