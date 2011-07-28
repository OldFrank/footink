//
//  friendsViewcontroller.h
//  photoPicker
//
//  Created by yongsik on 11. 5. 20..
//  Copyright 2011 ag. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@class EGOImageView;

@interface withViewcontroller : UIViewController <UIScrollViewDelegate,UIApplicationDelegate,CLLocationManagerDelegate>{

    UIScrollView *scrollView;
    UIScrollView *fscrollView;
    UIScrollView *bodyScrollView;

    NSMutableArray *jsonArray;


    EGOImageView *profileView;
    int selectedSegment;
    
    NSMutableArray *viewControllers;
    
    EGOImageView *bigImageView;
    UIPageControl *pageControl;
    BOOL pageControlUsed;
    int pageCnt;
    int curPage;
    int oldPage;
}


@property (nonatomic, retain) NSMutableArray *jsonArray;
@property (nonatomic, retain) NSMutableArray *viewControllers;
@property (nonatomic, retain) UIScrollView *scrollView;
@property (nonatomic, retain) UIScrollView *fscrollView;
@property (nonatomic, retain) UIScrollView *bodyScrollView;
@property (nonatomic, retain) UIPageControl *pageControl;


-(void)jsonLoad:(NSString *)types;
-(void)jsonDummy;

-(void)initImageView;
-(void)loadScrollViewWithPage:(int)page;
-(IBAction)changePage:(id)sender;

@end

