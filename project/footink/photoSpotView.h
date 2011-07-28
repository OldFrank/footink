//
//  photoSpotView.h
//  footink
//
//  Created by yongsik on 11. 7. 22..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HttpWrapper.h"
#import <QuartzCore/CoreAnimation.h>

@interface photoSpotView : UIViewController <HttpWrapperDelegate,UITableViewDelegate,UITableViewDataSource,CLLocationManagerDelegate>{

    NSMutableArray *catList;
    NSMutableArray *jsonArray;
    HttpWrapper *progressbar;
    UIView *progressBack;
    UITableView *CategoryView;
    NSString *prevCaption;
}
@property (nonatomic, retain) UIView *progressBack;
@property (nonatomic,retain) UITableView *CategoryView;
@property (nonatomic,retain) NSMutableArray *catList;
@property (nonatomic, retain) NSMutableArray *jsonArray;
@property (nonatomic, retain) NSString *prevCaption;

-(void)getSpotList;
@end
