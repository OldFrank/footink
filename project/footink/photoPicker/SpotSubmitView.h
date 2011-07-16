//
//  SpotSubmitView.h
//  photoPicker
//
//  Created by yongsik on 11. 7. 1..
//  Copyright 2011 ag. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SpotSubmitView : UIViewController <UITableViewDelegate,UITableViewDataSource,UIAlertViewDelegate>{
    NSURLConnection*			urlConnection;
    long						Total_FileSize;
	long                        CurLength;
	IBOutlet UIProgressView*	ProgressBar;
	IBOutlet UILabel*			ProgressLabel;
    
    UITableView *spotTable;
    NSMutableData *returnData;
    UIPickerView *pickerView;
    NSMutableArray *arrayColors;
    
    NSMutableArray *fList;
    UITextField *spotName;
}
@property (nonatomic, retain) UIProgressView*	progressBar;
@property (nonatomic, retain) UILabel*			ProgressLabel;
@property (nonatomic, retain) NSMutableData *returnData;
@property (nonatomic, retain) UIPickerView *pickerView;
@property (nonatomic, retain) UITableView *spotTable;
@property (nonatomic, retain) NSMutableArray *arrayColors;
@property (nonatomic, retain) NSMutableArray *fList;
@property (nonatomic, retain) UITextField *spotName;
-(BOOL)requestUrl:(NSString *)url;
@end
