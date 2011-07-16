//
//  SpotCategoryView.h
//  photoPicker
//
//  Created by yongsik on 11. 7. 2..
//  Copyright 2011 ag. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SpotCategoryView : UIViewController <UITableViewDelegate,UITableViewDataSource>{
    UITableView *CategoryView;
    NSMutableArray *catList;
}
@property (nonatomic,retain) UITableView *CategoryView;
@property (nonatomic,retain) NSMutableArray *catList;

@end
