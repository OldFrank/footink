//
//  photoEditController.m
//  footink
//
//  Created by yongsik on 11. 7. 18..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "photoEditController.h"
#import "GlobalStn.h"
#import "photoSendingController.h"
#import "photoPickerViewController.h"

@implementation photoEditController

const CGFloat fScrollObjHeight	= 60.0;
const CGFloat fScrollObjWidth	= 60.0;
const NSUInteger fNumImages		= 5;

@synthesize filterScrollView;
@synthesize originalImageview;
@synthesize arrImage;
@synthesize blendedImageview,selectedTag;

- (id) init{
    self=[super init];
    if(self!=nil){
        self.title=@"Friends";
       
    }
    return self;
}
- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.tabBarController.tabBar.hidden = YES;
    UIBarButtonItem *backButton=[[UIBarButtonItem alloc] initWithTitle:@"back" style:UIBarButtonItemStylePlain target:self action:@selector(cmdPrev)];
    self.navigationItem.leftBarButtonItem = backButton;
    
    UIBarButtonItem *sendButton = [[UIBarButtonItem alloc] initWithTitle:@"다음" style:UIBarButtonItemStylePlain
                                                                     target:self action:@selector(nextFrm)];      
    self.navigationItem.rightBarButtonItem = sendButton;
}
-(void)viewWillAppear:(BOOL)animated {
     
    self.originalImageview=[[UIImageView alloc] initWithFrame:CGRectMake(10.0, 10.0, 300.0, 300.0)];
    self.originalImageview.contentMode = UIViewContentModeScaleAspectFill;
    self.originalImageview.image=[UIImage imageNamed:@"mask.png"];
    [self.originalImageview setBackgroundColor:[UIColor blueColor]];
    [self.view addSubview:self.originalImageview];
    
    self.blendedImageview=[[UIImageView alloc] initWithFrame:CGRectMake(10.0, 10.0, 300.0, 300.0)];
    self.blendedImageview.contentMode = UIViewContentModeScaleAspectFill;
    self.blendedImageview.image=[UIImage imageNamed:@"mask.png"];
    [self.blendedImageview setBackgroundColor:[UIColor blueColor]];
    [self.view addSubview:self.blendedImageview];
    [self performSelector:@selector(initLayout) withObject:nil afterDelay:0.2f];
}
-(void)initLayout{
    arrImage = [NSArray arrayWithObjects:@"fx-film-filmgrain-thumb.jpg", @"fx-film-filmgrain-thumb.jpg",@"fx-film-filmgrain-thumb.jpg",@"fx-film-filmgrain-thumb.jpg",@"fx-film-filmgrain-thumb.jpg",@"fx-film-filmgrain-thumb.jpg",@"fx-film-filmgrain-thumb.jpg",@"fx-film-filmgrain-thumb.jpg",@"fx-film-filmgrain-thumb.jpg",@"fx-film-filmgrain-thumb.jpg",nil];
    
    
    filterScrollView=[[UIScrollView alloc] initWithFrame:CGRectMake(15.0, 326.0, 290.0, 50.0)];
    [filterScrollView setBackgroundColor:[UIColor clearColor]];
    
    filterScrollView.contentInset=UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
    filterScrollView.showsVerticalScrollIndicator=NO;
    filterScrollView.showsHorizontalScrollIndicator=YES;
    filterScrollView.alwaysBounceVertical=NO;             
    filterScrollView.alwaysBounceHorizontal=YES;   
    filterScrollView.pagingEnabled=NO;
    filterScrollView.bounces=YES;
    
    int i=1;
    for (NSString *imgName in arrImage)
    {
        UIImage *img = [UIImage imageNamed:imgName];
        
        UIImageView *fImageView = [[UIImageView alloc] initWithImage:img];
        
        fImageView.frame=CGRectMake(0.0, 0.0, 50.0, 50.0);
        fImageView.tag=i * 100;
        fImageView.opaque=YES;
        [fImageView setUserInteractionEnabled:YES];
        
        
        UIButton *fxButton = [[UIButton alloc]init];
        fxButton.frame = fImageView.frame;
        fxButton.tag = i;
        [fxButton setImage:[UIImage imageNamed:@"fx-film-filmgrain-thumb.jpg"] forState:UIControlStateNormal];
        [fxButton addTarget:self action:@selector(filmFxEffect:) forControlEvents:UIControlEventTouchUpInside];
        
        [fImageView addSubview:fxButton];
        [filterScrollView addSubview:fImageView];
        
        [img release];
        [fImageView release];
        
        i++;
    }
    
    UIView *filterback=[[UIView alloc] initWithFrame:CGRectMake(10.0, 321.0, 300.0, 60.0)];
    
    filterback.layer.backgroundColor = [UIColor whiteColor].CGColor;
    filterback.layer.shadowOffset = CGSizeMake(-2, -2);
    filterback.layer.shadowRadius = 5.0;
    filterback.layer.shadowColor = [UIColor blackColor].CGColor;
    filterback.layer.shadowOpacity = 0.3;
    filterback.layer.cornerRadius = 5.0;
    filterback.layer.frame = CGRectInset(filterback.layer.frame, 0, 0);
    [self.view addSubview:filterback];
    [self.view addSubview:filterScrollView];
    
    [self layoutScrollImages];
    [filterback release];
    
    [self performSelector:@selector(setImageData) withObject:nil afterDelay:0.3f];
    //[self setImageData];
}
-(void)cmdPrev{
    photoPickerViewController *cont=[[photoPickerViewController alloc] init];
    
    CATransition *transition = [CATransition animation];
    transition.duration = 0.3f;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    transition.type = kCATransitionPush;
    transition.subtype = kCATransitionFromLeft;
    //transitioning = YES;
    transition.delegate = self;
    
    self.navigationController.navigationBarHidden = NO;
    [self.navigationController pushViewController:cont animated:NO];
    [self.navigationController.view.layer addAnimation:transition forKey:nil];
}
- (void)layoutScrollImages
{    
	UIImageView *view = nil;
	NSArray *subviews = [filterScrollView subviews];
    
	CGFloat curXLoc = 0;
    CGFloat imgcnt = [arrImage count];
    
	for (view in subviews)
	{
		if ([view isKindOfClass:[UIImageView class]] && view.tag > 0)
		{
			CGRect frame = view.frame;
			frame.origin = CGPointMake(curXLoc, 0);
			view.frame = frame;
			
			curXLoc += fScrollObjWidth;
		}
	}
    NSUInteger timg;
	if(imgcnt < fNumImages){
        timg = fNumImages;
    }else{
        timg = imgcnt;
    }
    
	[filterScrollView setContentSize:CGSizeMake(( timg * fScrollObjWidth), [filterScrollView bounds].size.height)];
}
-(void)popfilmFxEffect:(int)selTag{
    CGRect cframe=originalImageview.frame;
    int fxInt=selTag / 100; 
    Filters *filterUIView=[[Filters alloc] initWithImage:originalImageview.image drawFrame:cframe fxfilm:fxInt delegate:self];
    //self.imageview.image = img;
    //self.imageview.image=nil;
    
    UIGraphicsBeginImageContext(filterUIView.bounds.size);
    [filterUIView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *newImage =UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    blendedImageview.image=newImage;

    
    [self selectedFilter:selTag];
}
-(void)filmFxEffect:(id)sender{
    CGRect cframe=originalImageview.frame;
    int fxInt=[sender tag]; 
    Filters *filterUIView=[[Filters alloc] initWithImage:originalImageview.image drawFrame:cframe fxfilm:fxInt delegate:self];
    //self.imageview.image = img;
    //self.imageview.image=nil;
    
    UIGraphicsBeginImageContext(filterUIView.bounds.size);
    [filterUIView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *newImage =UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    blendedImageview.image=newImage;
    [[GlobalStn sharedSingleton] setSelectedFilterInt:fxInt];
    
    int fimgTag=fxInt * 100;
    
    [self selectedFilter:fimgTag];

}
-(void)selectedFilter:(int)fint{
 
    if(fint > 0){
        UIImageView *fimage = (UIImageView *)[self.view viewWithTag:fint];
        CALayer *clayer = fimage.layer;
        
        if(selectedTag != fint){
            [clayer setBorderColor: [[UIColor orangeColor] CGColor]];
            [clayer setBorderWidth:2.0f];
            [clayer setShadowColor: [[UIColor blackColor] CGColor]];
            [clayer setShadowOpacity:0.9f];
            [clayer setShadowOffset: CGSizeMake(1, 3)];
            [clayer setShadowRadius:4.0];
            [fimage setClipsToBounds:NO];
            
            UIImageView *cimage = (UIImageView *)[self.view viewWithTag:selectedTag];
            CALayer *chklayer = cimage.layer;
            [chklayer setBorderColor: [[UIColor orangeColor] CGColor]];
            [chklayer setBorderWidth:0.0f];
            [chklayer setShadowColor: [[UIColor blackColor] CGColor]];
            [chklayer setShadowOpacity:0.0f];
            [chklayer setShadowOffset: CGSizeMake(0, 0)];
            [chklayer setShadowRadius:0.0];
            [cimage setClipsToBounds:NO];
            selectedTag=fint;
        }else{
            [clayer setBorderColor: [[UIColor orangeColor] CGColor]];
            [clayer setBorderWidth:2.0f];
            [clayer setShadowColor: [[UIColor blackColor] CGColor]];
            [clayer setShadowOpacity:0.9f];
            [clayer setShadowOffset: CGSizeMake(1, 3)];
            [clayer setShadowRadius:4.0];
            [fimage setClipsToBounds:NO];
            selectedTag=fint;
        }
    }
}
- (void)removeImage:(NSString*)fileName {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *dirPath = [documentsDirectory stringByAppendingPathComponent:@"ImageCache"];
    NSString *fullPath = [dirPath stringByAppendingPathComponent:
                          [NSString stringWithFormat:@"%@.png",fileName]];
    
    [fileManager removeItemAtPath:fullPath error:NULL];
    NSLog(@"image removed");
    
}
- (UIImage*)loadImage:(NSString*)imageName {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *dirPath = [documentsDirectory stringByAppendingPathComponent:@"ImageCache"];
    NSString *fullPath = [dirPath stringByAppendingPathComponent:
                          [NSString stringWithFormat:@"%@.png", imageName]];
    
    return [UIImage imageWithContentsOfFile:fullPath];
    
}
-(void)nextFrm{
    
    photoSendingController *cont=[[photoSendingController alloc] init];

    CATransition *transition = [CATransition animation];
    transition.duration = 0.3f;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    transition.type = kCATransitionPush;
    transition.subtype = kCATransitionFromRight;
    //transitioning = YES;
    transition.delegate = self;
    
    self.navigationController.navigationBarHidden = NO;
    cont.hidesBottomBarWhenPushed=YES;
    [self.navigationController pushViewController:cont animated:NO];
    [self.navigationController.view.layer addAnimation:transition forKey:nil];
    
    [cont release];
    [originalImageview release];
    originalImageview=nil;
    [blendedImageview release];
    blendedImageview=nil;
    
    //UIViewController *vctrlr = [[UIViewController alloc] init];
    //vctrlr.hideBottomBarWhenPushed = YES;
    //[self.navigationController pushViewController:vctrlr animated:YES];
  
    //vctrlr.hideBottomBarWhenPUshed = NO; 
    
    /*[UIView  beginAnimations: @"Showinfo"context: nil];
     [UIView setAnimationCurve: UIViewAnimationCurveEaseInOut];
     [UIView setAnimationDuration:0.75];
     [self.navigationController pushViewController:cont animated:NO];
     [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.navigationController.view cache:NO];
     [UIView commitAnimations];
     */
    /*
     //QuarzCore
     //애니매이션 객체 생성
     CATransition * transit = [CATransition animation];
     [transit setDelegate:self];
     //애니매이션 시간 설정
     [transit setDuration:2.0f];
     //애니메이션 알고르짐 선택
     [transit setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
     //[transit setTimingFunction:UIViewAnimationCurveEaseInOut];
     //애니메이션 타입설정
     //[transit setType:kCATransitionFade];
     //[transit setType:kCATransitionPush];
     //[transit setType:kCATransitionMoveIn];
     //[transit setType:kCATransitionReveal];
     
     //[transit setSubtype:kCATransitionFromTop];
     //[transit setSubtype:kCATransitionFromBottom];
     //[transit setSubtype:kCATransitionFromLeft];
     [transit setSubtype:kCATransitionFromRight];
     
     //문서에 나오지 않는 애니매이션
     //[transit setType:@"pageCurl"];
     //[transit setType:@"pageUnCurl"];
     //[transit setType:@"suckEffect"];
     //[transit setType:@"cameraIris"];
     //[transit setType:@"cameraIrisHollowOpen"];
     //[transit setType:@"cameraIrisHollowClose"];
     [transit setType:@"rippleEffect"];
     //[transit setType:@"oglFlip"];
     //애니매이션 가동
     [[parent layer]addAnimation:transit forKey:@"animation_key"];
     // [self.navigationController pushViewController:cont animated:NO];
    
    */
  
    
}
-(void)setImageData{
    NSLog(@"----setImageData");
    
    UIImage *localImg = [self loadImage: @"temp"];
    
    self.originalImageview.image=localImg;//[self generatePhotoThumbnail:localImg withRatio:300.0];
    self.blendedImageview.image=self.originalImageview.image;
    
    if(selectedTag>0){
        [self popfilmFxEffect:selectedTag];
    }
}
-(UIImage *)maskingImage:(UIImage *)image maskImage:(NSString *)_maskImage{
    CGImageRef imageRef = [image CGImage];
    CGImageRef maskRef = [[UIImage imageNamed:_maskImage] CGImage];
    CGImageRef mask = CGImageMaskCreate(CGImageGetWidth(maskRef),
                                        CGImageGetHeight(maskRef),
                                        CGImageGetBitsPerComponent(maskRef),
                                        CGImageGetBitsPerPixel(maskRef),
                                        CGImageGetBytesPerRow(maskRef),
                                        CGImageGetDataProvider(maskRef),
                                        NULL, false);
    CGImageRef masked = CGImageCreateWithMask(imageRef, mask);
    CGImageRelease(mask);
    UIImage *maskedImage = [UIImage imageWithCGImage:masked];
    CGImageRelease(masked);
    return maskedImage;
}
- (void)dealloc
{
    [originalImageview release];
    originalImageview=nil;
    [blendedImageview release];
    blendedImageview=nil;
    
    [super dealloc];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle
- (void)viewDidUnload
{
    [super viewDidUnload];
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
