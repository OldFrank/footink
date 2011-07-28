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
@synthesize rightView,infDisplay;
@synthesize lovedlabel;
@synthesize comlabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    NSLog(@"initWithStyle");
    if (self == [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
		imageView = [[EGOImageView alloc] initWithPlaceholderImage:[UIImage imageNamed:@"nonpic_80.png"]];
		imageView.frame = CGRectMake(10.0f, 0.0f, 250.0f, 250.0f);
		[self.contentView addSubview:imageView];
        
        infDisplay=[[UIView alloc] initWithFrame:CGRectMake(10.0f, 252.0f, 250.0f, 46.0f)];
        infDisplay.backgroundColor=[UIColor colorWithHue:0 saturation:0 brightness:0.92 alpha:1.0];
        [self.contentView addSubview:infDisplay];
        
        rightView=[[UIView alloc] initWithFrame:CGRectMake(270.0, 0.0, 40.0, 250.0)];
        rightView.backgroundColor=[UIColor colorWithHue:0 saturation:0 brightness:0.92 alpha:1.0];
        [self.contentView addSubview:rightView];
        [imageView release];
       
        lovedlabel = [[[UILabel alloc] init] autorelease];
        lovedlabel.frame = CGRectMake(20, 4, 70, 25);
        lovedlabel.backgroundColor = [UIColor clearColor];
        lovedlabel.textColor=[UIColor colorWithWhite: 0.333 alpha: 0.5];
        lovedlabel.shadowColor = [UIColor whiteColor];
        lovedlabel.shadowOffset = CGSizeMake(0.0, 0.0);
        lovedlabel.text=@"test";
        [lovedlabel setFont:[UIFont fontWithName:@"verdana" size:9.f]];
        
        [infDisplay addSubview:lovedlabel];
        
        comlabel = [[[UILabel alloc] init] autorelease];
        comlabel.frame = CGRectMake(95.0, 4.0, 90.0, 25.0);

        comlabel.backgroundColor = [UIColor clearColor];
        comlabel.textColor=[UIColor colorWithWhite: 0.333 alpha: 0.5];
        comlabel.shadowColor = [UIColor whiteColor];
        comlabel.shadowOffset = CGSizeMake(0.0, 0.0);
        [comlabel setFont:[UIFont fontWithName:@"verdana" size:9.f]];
        
        [infDisplay addSubview:comlabel];

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
    [comlabel release];
    [lovedlabel release];
    [infDisplay release];
    [rightView release];
	[imageView release];
    [super dealloc];
}


@end