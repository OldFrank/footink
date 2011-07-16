//
//  GlobalSingleton.h
//  photoPicker
//
//  Created by yongsik on 11. 5. 17..
//  Copyright 2011 ag. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <sqlite3.h>

@interface GlobalStn : NSObject {
    NSString *uname;
    NSString *ukey;
    NSString *uprofile;
    
    int celltot;
    NSMutableArray *sArray;
    NSData *pushToken;
    int moreRow; 
    int imgTag; 
    int pickerChk; 
}
+(GlobalStn *)sharedSingleton;
@property (nonatomic, retain) NSString *uname;
@property (nonatomic, retain) NSString *ukey;
@property (nonatomic, retain) NSString *uprofile;
@property (nonatomic, retain) NSMutableArray *sArray;
@property (nonatomic, retain) NSData *pushToken;
///@property (nonatomic, retain) NSMutableArray *btnArray;
@property (nonatomic, assign) int celltot;
@property (nonatomic, assign) int moreRow;
@property (nonatomic, assign) int imgTag;
@property (nonatomic, assign) int pickerChk;

-(NSArray *)getSetting;

@end
