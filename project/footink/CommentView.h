//
//  CommentView.h
//  footink
//
//  Created by yongsik on 11. 7. 25..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HttpWrapper.h"
#import <QuartzCore/QuartzCore.h>

@interface CommentView : UIViewController <HttpWrapperDelegate,UITextFieldDelegate,CLLocationManagerDelegate,UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate>{
    UITableView *commentView;
    
    NSMutableArray *catList;
    NSMutableArray *jsonArray;
    HttpWrapper *progressbar;
    UIView *progressBack;
    NSString *pidx;
    BOOL keyboardVisible;
    UITextField *commentInput;
    UIView *commentback;
}
@property (nonatomic, retain) UIView *progressBack;
@property (nonatomic,retain) UITableView *commentView;
@property (nonatomic,retain) NSMutableArray *catList;
@property (nonatomic, retain) NSMutableArray *jsonArray;
@property (nonatomic, assign) NSString *pidx;
@property (nonatomic, retain) UITextField *commentInput;
@property (nonatomic, retain) UIView *commentback;
-(void)getCommentList;
- (void)registerForKeyboardNotifications;
-(BOOL)sendComment;
@end
