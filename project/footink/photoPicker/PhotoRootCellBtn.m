//
//  PhotoRootCellBtn.m
//  photoPicker
//
//  Created by yongsik on 11. 6. 29..
//  Copyright 2011 ag. All rights reserved.
//

#import "PhotoRootCellBtn.h"
#import "UIImageView+AsyncAndCache.h"

@implementation PhotoRootCellBtn

@synthesize titleLabel,itemID,dcellContentView;
@synthesize DimageView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    NSLog(@"initWithStyle ");
    
	if (self == [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        //self.itemID = 0;
        
        dcellContentView = self.contentView;
        
        self.titleLabel = [[UILabel alloc] init];
        self.titleLabel.text = @"test";
        self.titleLabel.frame = CGRectMake(10.0, 10.0, 100.0, 30.0);
        [dcellContentView addSubview:self.titleLabel]; 
        
        UIImage *noPicImageSmall = [[UIImage imageNamed:@"mask.png"] retain];
        
        DimageView = [[UIImageView alloc] initWithImage:noPicImageSmall];
        
        CGRect rect = DimageView.frame;
        rect.size.height = 300.0;
        rect.size.width = 300.0;
        DimageView.frame = rect;
        [DimageView setUserInteractionEnabled:YES];
        //self.imageView.tag = (int)self.itemID;
        
        [dcellContentView addSubview:DimageView];
        
        
        [noPicImageSmall release];
	}
	return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	[super setSelected:selected animated:animated];
}

-(void)setData:(NSDictionary *)dict {
	self.titleLabel.text = [dict objectForKey:@"date"];
    
	//self.itemID = (NSInteger)[dict objectForKey:@"idx"];
	[self.DimageView setImageURLString: [dict objectForKey:@"img"]];
}
-(NSInteger)getID {
    NSLog(@"---getID %@",self.itemID);
	return (NSInteger)self.itemID;
}

-(void)layoutSubviews {
    NSLog(@"layoutSubviews");
    [super layoutSubviews];
    
    CGRect contentRect = self.contentView.bounds;
    
    if (!self.editing) {
        
        CGFloat boundsX = contentRect.origin.x;
        CGRect frame;
        
        frame = CGRectMake(boundsX + 10, 4, 200, 20);
        self.titleLabel.frame = frame;
        
        self.DimageView.frame = CGRectMake(10.0, 50.0, 300.0, 300.0);
    }
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
	[self.titleLabel release];
    [DimageView release];
	[super dealloc];
}
@end