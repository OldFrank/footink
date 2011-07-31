//
//  friendsViewcontroller.h
//  photoPicker
//
//  Created by yongsik on 11. 5. 20..
//  Copyright 2011 ag. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "EGOImageView.h"
#import "HttpWrapper.h"

@class EGOImageView;

@interface withGroupController : UIViewController <UIScrollViewDelegate,UIApplicationDelegate,CLLocationManagerDelegate,HttpWrapperDelegate>{

    UIScrollView *scrollView;
    UIScrollView *fscrollView;
    UIScrollView *bodyScrollView;

    NSMutableArray *jsonArray;


    EGOImageView *profileView;
    int selectedSegment;
    HttpWrapper *progressbar;
    NSMutableArray *viewControllers;

    UIPageControl *pageControl;
    BOOL pageControlUsed;
    int pageCnt;
    int curPage;
    int oldPage;
    int uidx;
    
}
@property (nonatomic, retain) NSMutableArray *jsonArray;
@property (nonatomic, retain) NSMutableArray *viewControllers;
@property (nonatomic, retain) UIScrollView *scrollView;
@property (nonatomic, retain) UIScrollView *fscrollView;
@property (nonatomic, retain) UIScrollView *bodyScrollView;
@property (nonatomic, retain) UIPageControl *pageControl;

@property (nonatomic, assign) int uidx;

-(void)jsonLoad;
-(void)initImageView;
-(void)loadScrollViewWithPage:(int)page;
-(void)changePage:(id)sender;
-(void)hidePrevTabBar;
-(void)withGroupTabBar;
-(void)hideTabBar;
-(void)backPopAct;
-(void)onCamera;
@end

