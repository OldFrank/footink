//
//  SettingCell.m
//  photoPicker
//
//  Created by yongsik on 11. 6. 13..
//  Copyright 2011 ag. All rights reserved.
//

#import "SettingCell.h"


@implementation SettingCell
@synthesize textLabel;

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if(self == [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        
        textLabel = [self newLabelWithPrimaryColor:[UIColor blackColor] selectedColor:[UIColor lightGrayColor] fontSize:12.0 bold:NO];
        textLabel.textAlignment = UITextAlignmentLeft;
        
        [self addSubview:textLabel];
    }
    return self;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	[super setSelected:selected animated:NO];
}

- (UILabel *)newLabelWithPrimaryColor:(UIColor *)primaryColor selectedColor:(UIColor *)selectedColor fontSize:(CGFloat)fontSize bold:(BOOL)bold
{
    /*
	 Views are drawn most efficiently when they are opaque and do not have a clear background, so set these defaults.  To show selection properly, however, the views need to be transparent (so that the selection color shows through).  This is handled in setSelected:animated:.
	 */
	UILabel *newLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0,10.0,120.0,20.0)];
	newLabel.backgroundColor = [UIColor whiteColor];
	newLabel.opaque = YES;
	newLabel.textColor = primaryColor;
	newLabel.highlightedTextColor = selectedColor;
	//newLabel.font = font;
    [newLabel setFont:[UIFont fontWithName:@"AppleGothic" size:fontSize]];
    
	return newLabel;
}
-(void)dealloc {
    [textLabel release];
    [super dealloc];
}
@end
