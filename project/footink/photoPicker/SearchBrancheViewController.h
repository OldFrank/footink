//
//  SearchBrancheViewController.h
//  photoPicker
//
//  Created by yongsik on 11. 5. 20..
//  Copyright 2011 ag. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SearchBrancheViewController : UIViewController {
	UITextField *searchField;
}

@property (nonatomic, retain) IBOutlet UITextField *searchField;

- (IBAction)search:(id)sender;
- (IBAction)findSurroundings:(id)sender;

@end
