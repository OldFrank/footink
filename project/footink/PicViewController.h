//
//  PicViewController.h
//  footink
//
//  Created by yongsik on 11. 7. 28..
//  Copyright 2011년 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PicViewController : UIViewController{
IBOutlet UIImageView *image;
UIImage *img;
}

@property (nonatomic, retain) UIImage *img;

- (id)initWithImage:(NSString *)url;
@end
