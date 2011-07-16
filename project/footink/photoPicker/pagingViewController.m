//
//  pagingViewController.m
//  photoPicker
//
//  Created by yongsik on 11. 7. 13..
//  Copyright 2011 ag. All rights reserved.
//

#import "pagingViewController.h"
#import "EGOImageView.h"

@implementation pagingViewController

@synthesize pageNumberLabel, numberTitle;

// load the view nib and initialize the pageNumber ivar
- (id)initWithPageNumber:(int)page
{
    if (self !=nil )
    {
        pageNumber = page;
    }
    return self;
}

- (void)dealloc
{
    [pageNumberLabel release];
    [numberTitle release];
    [numberImage release];
    
    [super dealloc];
}

// set the label and background color when the view has finished loading
- (void)viewDidLoad
{
    numberImage=[[EGOImageView alloc] initWithPlaceholderImage:[UIImage imageNamed:@"mask.png"]];
    numberImage.frame = CGRectMake(0.0, 0.0, 300.0, 300.0);
    [self.view addSubview:numberImage];
    //numberImage.imageURL = [NSURL URLWithString:imgUrl];
    pageNumberLabel.text = [NSString stringWithFormat:@"Page %d", pageNumber + 1];
}
-(void)setImage:(NSString *)url{
    NSLog(@"%@",url);
    numberImage.imageURL = [NSURL URLWithString:url];
}
@end
