//
//  ProfileViewController.h
//  photoPicker
//
//  Created by yongsik on 11. 7. 10..
//  Copyright 2011 ag. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HttpWrapper.h"
@class EGOImageView;

@interface ProfileViewController : UIViewController <HttpWrapperDelegate,UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate>{
    UITableView *profileTable;
    NSMutableArray *jsonArray;
    NSInteger uidx;
    NSTimer *timer;
    
    NSURLConnection *connection;
    NSData *imageData;
    NSHTTPURLResponse *response;
    NSMutableData *responseData;
    
    int retryCounter;
    
    IBOutlet UIProgressView *uploadProgress;
    IBOutlet UILabel *uploadProgressMessage;
    
    UITextField *uname;
    EGOImageView *profileView;
    EGOImageView *imageView;
    UITextField *follow;
    UITextField *follower;
    UIView *header;
    UIButton *followBtn;
    UIActivityIndicatorView *indicator;
    HttpWrapper *progressbar;
    UIView *progressBack;
    
    UIScrollView *scrollView;
	NSMutableArray *viewControllers;
}
@property(nonatomic,retain) UIScrollView *scrollView;
@property(nonatomic,retain) NSMutableArray *viewControllers;

@property(nonatomic,retain) UITableView *profileTable;
@property(nonatomic,retain) NSMutableArray *jsonArray;
@property(nonatomic,assign) NSInteger uidx;

@property (nonatomic,retain) NSURLConnection *connection;
@property (nonatomic,retain) NSData *imageData;
@property (nonatomic,retain) NSHTTPURLResponse *response;
@property (nonatomic,retain) NSMutableData *responseData;
@property (nonatomic,retain) UITextField *uname;
@property (nonatomic,retain) UITextField *follow;
@property (nonatomic,retain) UITextField *follower;
@property (nonatomic,retain) UIView *header;
@property (nonatomic,retain) UIView *progressBack;
@property (nonatomic,retain) UIButton *followBtn;
@property (nonatomic,retain) UIActivityIndicatorView *indicator;

- (void)loadPage:(int)page;
-(BOOL)HttpAuth:(NSMutableArray *)regValue;
-(void)profilerewrite;
//-(void)followSend:(id)sender;
-(void)getPersonalList:(NSMutableArray *)personalValue;
@end
