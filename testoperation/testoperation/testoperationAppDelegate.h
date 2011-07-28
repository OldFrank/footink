//
//  testoperationAppDelegate.h
//  testoperation
//
//  Created by yongsik on 11. 7. 19..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class testoperationViewController;

@interface testoperationAppDelegate : NSObject <UIApplicationDelegate> {

}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet testoperationViewController *viewController;

@end
