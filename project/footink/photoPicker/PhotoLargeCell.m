//
//  PhotoLargeCell.m
//  photoPicker
//
//  Created by yongsik on 11. 7. 2..
//  Copyright 2011 ag. All rights reserved.
//

#import "PhotoLargeCell.h"
#import "EGOImageView.h"
#import "GlobalStn.h"

@implementation PhotoLargeCell
@synthesize rightView;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self == [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
		imageView = [[EGOImageView alloc] initWithPlaceholderImage:[UIImage imageNamed:@"nonpic_80.png"]];
		imageView.frame = CGRectMake(10.0f, 0.0f, 250.0f, 250.0f);
		[self.contentView addSubview:imageView];
        
        rightView=[[UIView alloc] initWithFrame:CGRectMake(270.0, 0.0, 40.0, 250.0)];
        rightView.backgroundColor=[UIColor colorWithHue:0 saturation:0 brightness:0.92 alpha:1.0];
        [self.contentView addSubview:rightView];
        
        
	}
	
    return self;
}

- (void)setPhoto:(NSString*)Photo profile:(NSString*)icon{
	imageView.imageURL = [NSURL URLWithString:Photo];
    
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
	[super willMoveToSuperview:newSuperview];
	
	if(!newSuperview) {
		[imageView cancelImageLoad];
	}
}
- (void)dealloc {
    [rightView release];
	[imageView release];
    [super dealloc];
}


@end