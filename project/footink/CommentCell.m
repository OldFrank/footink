//
//  CommentCell.m
//  footink
//
//  Created by yongsik on 11. 7. 27..
//  Copyright 2011년 __MyCompanyName__. All rights reserved.
//

#import "CommentCell.h"

@implementation CommentCell
@synthesize titleLabel,writer,dcellContentView,rdate; 

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	if (self == [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        // NSLog(@"initWithStyle");
        self.dcellContentView = self.contentView;
        
        self.titleLabel = [[UILabel alloc] init];
        [self.dcellContentView addSubview:self.titleLabel]; 
        
        self.writer = [[UILabel alloc] init];
        [self.dcellContentView addSubview:self.writer]; 
        
        self.rdate = [[UILabel alloc] init];
        [self.dcellContentView addSubview:self.rdate]; 
        
        DimageView = [[EGOImageView alloc] initWithPlaceholderImage:[UIImage imageNamed:@"nonpic_80.png"]];
        DimageView.frame = CGRectMake(10.0f, 5.0f, 30.0f, 30.0f);
        [self.dcellContentView addSubview:DimageView];
        
	}
	return self;
}
- (void)setPhoto:(NSString*)Photo {
	
}
-(void)layoutSubviews {
    
    [super layoutSubviews];
    
    CGRect contentRect = self.contentView.bounds;
    
    if (!self.editing) {
        
        CGFloat boundsX = contentRect.origin.x;
        CGRect frame;
        
        frame = CGRectMake(boundsX + 50, 5, 200, 20);
        self.titleLabel.frame = frame;
        //self.titleLabel.text= @"t";
        [self.titleLabel setFont:[UIFont fontWithName:@"appleGothic" size:14.f]];
        
        self.writer.frame = CGRectMake(boundsX + 50, 20, 200, 17);
        [self.writer setFont:[UIFont fontWithName:@"verdana" size:11.f]];
        self.writer.textColor=[UIColor lightGrayColor];
        self.writer.adjustsFontSizeToFitWidth=NO;
        
        self.rdate.frame = CGRectMake(boundsX + 210, 20, 110, 20);
        [self.rdate setFont:[UIFont fontWithName:@"verdana" size:9.f]];
        self.rdate.textColor=[UIColor lightGrayColor];
        self.rdate.adjustsFontSizeToFitWidth=NO;
        
        DimageView.frame = CGRectMake(10, 5, 30, 30);
    }
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	[super setSelected:selected animated:animated];
}
-(void)setData:(NSDictionary *)dict {
	self.titleLabel.text = [dict objectForKey:@"cont"];
    self.writer.text = [dict objectForKey:@"writer"];
    self.rdate.text = [dict objectForKey:@"date"];

	DimageView.imageURL = [NSURL URLWithString:[dict objectForKey:@"icon"]];
}


- (UILabel *)newLabelWithPrimaryColor:(UIColor *)primaryColor selectedColor:(UIColor *)selectedColor fontSize:(CGFloat)fontSize bold:(BOOL)bold
{
    UIFont *font;
    if (bold) {
        font = [UIFont boldSystemFontOfSize:fontSize];
    } else {
        font = [UIFont systemFontOfSize:fontSize];
    }
    
	UILabel *newLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	newLabel.backgroundColor = [UIColor whiteColor];
	newLabel.opaque = YES;
	newLabel.textColor = primaryColor;
	newLabel.highlightedTextColor = selectedColor;
	newLabel.font = font;
	
	return newLabel;
}
- (void)dealloc {
	[titleLabel release];
    [writer release];
    [DimageView release];
    [rdate release];
	[super dealloc];
}
@end
