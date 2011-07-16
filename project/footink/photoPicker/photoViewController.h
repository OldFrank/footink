//
//  photoViewController.h
//  photoPicker
//
//  Created by Yongsik Cho on 11. 4. 12..
//  Copyright 2011 ag. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface photoViewController : UIViewController <UINavigationControllerDelegate>{
    IBOutlet UILabel *jsonLabel;
	IBOutlet UIImageView *jsonImage;
	NSDictionary *jsonItem;
	NSInteger *itemID;

}
-(void)setID:(NSInteger)val;

@property (nonatomic, retain) UILabel *jsonLabel;
@property (nonatomic, retain) UIImageView *jsonImage;
@property (nonatomic, retain) NSDictionary *jsonItem;
@property (nonatomic, assign) NSInteger *itemID;

@end
