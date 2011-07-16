//
//  pagingViewController.h
//  photoPicker
//
//  Created by yongsik on 11. 7. 13..
//  Copyright 2011 ag. All rights reserved.
//

#import <UIKit/UIKit.h>
@class EGOImageView;

@interface pagingViewController : UIViewController {

    UILabel *pageNumberLabel;
    int pageNumber;
    
    UILabel *numberTitle;
    EGOImageView *numberImage;

}
@property (nonatomic, retain) IBOutlet UILabel *pageNumberLabel;
@property (nonatomic, retain) IBOutlet UILabel *numberTitle;

-(id)initWithPageNumber:(int)page;
-(void)setImage:(NSString *)url;

@end
