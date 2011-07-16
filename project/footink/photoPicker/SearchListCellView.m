//
//  SearchListCellView.m
//  photoPicker
//
//  Created by yongsik on 11. 6. 21..
//  Copyright 2011 ag. All rights reserved.
//


#import "SearchListCellView.h"
#import "EGOImageView.h"

@implementation SearchListCellView

@synthesize titleLabel,distanceLabel,itemID,dcellContentView;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	if (self == [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
       // NSLog(@"initWithStyle");
        self.dcellContentView = self.contentView;
        
        self.titleLabel = [[UILabel alloc] init];
        [self.dcellContentView addSubview:self.titleLabel]; 
        
        self.distanceLabel = [[UILabel alloc] init];
        [self.dcellContentView addSubview:self.distanceLabel]; 
        
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
        
            frame = CGRectMake(boundsX + 50, 8, 200, 20);
            self.titleLabel.frame = frame;
            //self.titleLabel.text= @"t";
            [self.titleLabel setFont:[UIFont fontWithName:@"appleGothic" size:14.f]];
            
            self.distanceLabel.frame = CGRectMake(boundsX + 50, 25, 200, 17);
            [self.distanceLabel setFont:[UIFont fontWithName:@"verdana" size:11.f]];
            //self.distanceLabel.text=@"tt";
            self.distanceLabel.textColor=[UIColor lightGrayColor];
            self.distanceLabel.adjustsFontSizeToFitWidth=NO;
            
            DimageView.frame = CGRectMake(10, 5, 30, 30);
            
      
    }
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	[super setSelected:selected animated:animated];
}
-(void)setData:(NSDictionary *)dict {
	self.titleLabel.text = [dict objectForKey:@"name"];
    
	//self.itemID = (NSInteger)[dict objectForKey:@"idx"];
	DimageView.imageURL = [NSURL URLWithString:[dict objectForKey:@"icon"]];
}

-(NSInteger)getID {
    NSLog(@"---getID %@",self.itemID);
	return (NSInteger)self.itemID;
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
    [distanceLabel release];
    [DimageView release];
	[super dealloc];
}
@end
