//
//  PhotoRootCell.m
//  photoPicker
//
//  Created by yongsik on 11. 6. 29..
//  Copyright 2011 ag. All rights reserved.
//

#import "PhotoCalCell.h"
#import "EGOImageView.h"
#import "GlobalStn.h"

@implementation PhotoCalCell

@synthesize titleLabel,itemID,dcellContentView,scrollView;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self == [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        NSLog(@"initWithStyle");
		
        scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, 320, 80)];
        [scrollView setBackgroundColor:[UIColor grayColor]];
        [scrollView setCanCancelContentTouches:NO];
        scrollView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
        scrollView.clipsToBounds = YES;
        scrollView.scrollEnabled = YES;
        [scrollView setShowsVerticalScrollIndicator:NO];      //스크롤 막대 숨기기 여부 
        [scrollView setShowsHorizontalScrollIndicator:NO];
        scrollView.pagingEnabled = NO;
        
        [self.contentView addSubview:scrollView];
        
        NSUInteger i;
        NSLog(@"%d",[[GlobalStn sharedSingleton] celltot]);
        for (i = 1; i <= (int)[[GlobalStn sharedSingleton] celltot]; i++)
        {
            imageView = [[EGOImageView alloc] initWithPlaceholderImage:[UIImage imageNamed:@"nonpic_80.png"]];
            imageView.frame = CGRectMake(10.0f, 0.0f, 80.0f, 80.0f);
            [scrollView addSubview:imageView];
    
        }
       
        
        
	}
	
    return self;
}

- (void)setPhoto:(NSString*)Photo {
	imageView.imageURL = [NSURL URLWithString:Photo];
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
	[super willMoveToSuperview:newSuperview];
	NSLog(@"willMoveToSuperview");
	if(!newSuperview) {
		[imageView cancelImageLoad];
	}
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	[super setSelected:selected animated:animated];
}

-(void)setData:(NSDictionary *)dict {
	self.titleLabel.text = [dict objectForKey:@"date"];
    
	//self.itemID = (NSInteger)[dict objectForKey:@"idx"];
	

}


- (void)dealloc {
	[self.titleLabel release];
   [imageView release];
	[super dealloc];
}
@end