//
//  ScrollPhoto.h
//  photoPicker
//
//  Created by yongsik on 11. 5. 15..
//  Copyright 2011 ag. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"

@interface photoDetailView : UITableViewController <EGORefreshTableHeaderDelegate>{

    NSInteger *itemID;
	NSMutableArray *jsonItem;
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _reloading;

}
-(void)setID:(NSInteger)val;

@property (nonatomic, retain) NSMutableArray *jsonItem;
@property (nonatomic, assign) NSInteger *itemID;


@end
