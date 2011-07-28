//
//  filterTestAppDelegate.h
//  filterTest
//
//  Created by yongsik on 11. 7. 20..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class filterTestViewController;

@interface filterTestAppDelegate : NSObject <UIApplicationDelegate> {

}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet filterTestViewController *viewController;

@end
