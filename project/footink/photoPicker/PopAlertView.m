//
//  PopAlertView.m
//  photoPicker
//
//  Created by yongsik on 11. 6. 23..
//  Copyright 2011 ag. All rights reserved.
//

#import "PopAlertView.h"


@implementation PopAlertView

@synthesize backgroundImage, alertText;

- (id)initWithImage:(UIImage *)image text:(NSString *)text {
    if (self == [super init]) {
		/*alertTextLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		alertTextLabel.textColor = [UIColor whiteColor];
		alertTextLabel.backgroundColor = [UIColor clearColor];
		alertTextLabel.font = [UIFont boldSystemFontOfSize:28.0];
		[self addSubview:alertTextLabel];
		
        self.backgroundImage = image;
		self.alertText = text;
        */
        NSLog(@"initwith");
        
        self.backgroundImage = image;
        UIImageView *bg = [[UIImageView alloc] initWithImage:backgroundImage];
        [self addSubview:bg];
        alertTextLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        alertTextLabel.textColor = [UIColor whiteColor];
        alertTextLabel.text = text;
        alertTextLabel.backgroundColor = [UIColor clearColor];
        alertTextLabel.font = [UIFont systemFontOfSize:13];
        alertTextLabel.textAlignment = UITextAlignmentCenter;
        [bg release];
        [self addSubview:alertTextLabel];
    }
    return self;
}

- (void) setAlertText:(NSString *)text {
	alertTextLabel.text = text;
}

- (NSString *) alertText {
	return alertTextLabel.text;
}


- (void)drawRect:(CGRect)rect {
    //CGContextRef ctx = UIGraphicsGetCurrentContext();
	 NSLog(@"drawrect");
	CGSize imageSize = self.backgroundImage.size;
	//CGContextDrawImage(ctx, CGRectMake(0, 0, imageSize.width, imageSize.height), self.backgroundImage.CGImage);
	[self.backgroundImage drawInRect:CGRectMake(0, 0, imageSize.width, imageSize.height)];
    
    
}

- (void) layoutSubviews {
    NSLog(@"layoutSubviews");
    for (UIView *sub in [self subviews])
	{
		if([sub class] == [UIImageView class] && sub.tag == 0)
		{
			// The alert background UIImageView tag is 0, 
			// if you are adding your own UIImageView's 
			// make sure your tags != 0 or this fix 
			// will remove your UIImageView's as well!
            
			[sub removeFromSuperview];
			break;
		}
	}

	alertTextLabel.transform = CGAffineTransformIdentity;
	[alertTextLabel sizeToFit];
	
	CGRect textRect = alertTextLabel.frame;
	textRect.origin.x = (CGRectGetWidth(self.bounds) - CGRectGetWidth(textRect)) / 2;
	textRect.origin.y = (CGRectGetHeight(self.bounds) - CGRectGetHeight(textRect)) / 2;
	textRect.origin.y -= 30.0;
	
	alertTextLabel.frame = textRect;
	
   	//alertTextLabel.transform = CGAffineTransformMakeRotation(- M_PI * .08);
}

- (void) show {
	[super show];
	
	CGSize imageSize = self.backgroundImage.size;
	self.bounds = CGRectMake(0, 0, imageSize.width, imageSize.height);
}


- (void)dealloc {
    [super dealloc];
}

@end
