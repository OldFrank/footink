//
//  CustomTabbarViewController.h
//  footink
//
//  Created by yongsik on 11. 7. 26..
//  Copyright 2011년 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomTabbar.h"
@interface CustomTabbarViewController : UIViewController <CustomTabbarDelegate>
{
    CustomTabbar* tabBar;
}

@property (nonatomic, retain) CustomTabbar* tabBar;
@end
