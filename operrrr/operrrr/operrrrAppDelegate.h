//
//  operrrrAppDelegate.h
//  operrrr
//
//  Created by yongsik on 11. 7. 19..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class operrrrViewController;

@interface operrrrAppDelegate : NSObject <UIApplicationDelegate> {

}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet operrrrViewController *viewController;

@end
