//
//  SpotInkletSubmit.h
//  photoPicker
//
//  Created by yongsik on 11. 7. 1..
//  Copyright 2011 ag. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface SpotInkletSubmit : UIViewController <CLLocationManagerDelegate,UIPickerViewDataSource, UIPickerViewDelegate>{
    NSURLConnection*			urlConnection;
    long						Total_FileSize;
	long                        CurLength;
	IBOutlet UIProgressView*	ProgressBar;
	IBOutlet UILabel*			ProgressLabel;
    
    NSMutableData *returnData;
    UIPickerView *pickerView;
    NSMutableArray *arrayColors;
}

@property (nonatomic, retain) UIProgressView*	progressBar;
@property (nonatomic, retain) UILabel*			ProgressLabel;
@property (nonatomic, retain) NSMutableData *returnData;
@property (nonatomic, retain) UIPickerView *pickerView;
@property (nonatomic, retain) NSMutableArray *arrayColors;

-(BOOL)requestUrl:(NSString *)url;

@end
