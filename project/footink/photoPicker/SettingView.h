//
//  SettingView.h
//  photoPicker
//
//  Created by Yongsik Cho on 11. 4. 28..
//  Copyright 2011 ag. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <sqlite3.h>
#import "footinkAppDelegate.h"
#import "AddViewController.h"
#import "FBConnect.h"
#import "FBSession.h"


#define kCachedXAuthAccessTokenStringKey	@"cachedXAuthAccessTokenKey"



@interface SettingView : UIViewController <UISearchBarDelegate,UITableViewDelegate,UITableViewDataSource,AddViewControllerDelegate,FBSessionDelegate,FBRequestDelegate>{
    UITableView *fTable;
    UISearchBar *fSearch;
    NSMutableArray *fList;
    FBSession *usersession;
	NSString *username;
	BOOL post;
    

}
@property(nonatomic,retain)  FBSession *usersession;
@property(nonatomic,retain) NSString *username;
@property(nonatomic,assign) BOOL post;



- (BOOL)textFieldShouldReturn:(UITextField *)textField;
-(void)getFacebookName;
-(void)postToWall;

//create db
- (void)initDB;
- (void)AddRecordWithMemo:(NSString *)Memo Priority:(int)Priority;
- (void)ModifyRecordWithNo:(int)No Memo:(NSString *)Memo Priority:(int)Priority;
- (void)RemoveRecordWithNo:(int)No;
- (NSArray *)GetRecords;
- (void)cmdAdd;
-(void)fbLoginFrm;

- (NSArray *)SearchRecordWithMemo:(NSString *)text;
- (void)cmdOpenDetail:(NSDictionary *)data;

@end
