//
//  GlobalSingleton.m
//  photoPicker
//
//  Created by yongsik on 11. 5. 17..
//  Copyright 2011 ag. All rights reserved.
//

#import "GlobalStn.h"


@implementation GlobalStn

static GlobalStn * _globalStn = nil;
@synthesize uname,ukey,uprofile,celltot,sArray,pushToken,moreRow,imgTag,pickerChk;

- (id) init {
    NSLog(@"Global init");
    if(self == [super init])
    {
        self.sArray=(NSMutableArray *)[self getSetting];
        
        if([self.sArray count]!=0){
            self.uname = [[self.sArray objectAtIndex:0] objectForKey:@"name"];
            self.ukey = [[self.sArray objectAtIndex:0] objectForKey:@"privatekey"];
            self.uprofile = [[self.sArray objectAtIndex:0] objectForKey:@"profile"];
            NSLog(@"%@",self.uprofile);
        }
        
        self.celltot = 0;
        self.pushToken=nil;
        self.moreRow=0;
        self.imgTag=0;
        self.pickerChk=0;
       
        //self.btnArray = nil;
    }
    return self;
}

+(GlobalStn *)sharedSingleton
{
    @synchronized([GlobalStn class])
    {
        if (!_globalStn)        
            [[self alloc] init];
        
        return _globalStn;
    }
    
    return nil;
}

+(id)alloc
{
    @synchronized([GlobalStn class])
    {
        NSAssert(_globalStn == nil, @"Attempted to allocate a second instance of a singleton.");
        _globalStn = [super alloc];
        return _globalStn;
    }
    
    return nil;
}
-(NSArray *)getSetting{
    //NSLog(@"global setting");
    sqlite3 *db;
    NSString *Dir=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0];
    NSString *filePath = [Dir stringByAppendingPathComponent:@"setting.sqlite"];
    if(sqlite3_open([filePath UTF8String],&db)!=SQLITE_OK){
        sqlite3_close(db);
        NSLog(@"Error");
        return nil;
    }
    
    NSMutableArray *Result = [NSMutableArray array];
    sqlite3_stmt *state;
    char *ssql = "SELECT no,name,email,privatekey,profile,share,gps FROM setting";
    if(sqlite3_prepare_v2(db,ssql,-1,&state,NULL) == SQLITE_OK){
        while (sqlite3_step(state) == SQLITE_ROW){
            NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                                 [NSNumber numberWithInt:sqlite3_column_int(state,0)],@"no",
                                 [NSString stringWithUTF8String:(char *)sqlite3_column_text(state,1)],@"name",
                                 [NSString stringWithUTF8String:(char *)sqlite3_column_text(state,2)],@"email",
                                 [NSString stringWithUTF8String:(char *)sqlite3_column_text(state,3)],@"privatekey",
                                 [NSString stringWithUTF8String:(char *)sqlite3_column_text(state,4)],@"profile",
                                 [NSNumber numberWithInt:sqlite3_column_int(state,5)],@"share",
                                 [NSNumber numberWithInt:sqlite3_column_int(state,6)],@"gps",
                                 nil];
            
            [Result addObject:dic];
        }
    }
    //,.NSLog(@"%@",Result);
    return Result;
}

- (void) dealloc
{
    [uname release];
    [ukey release];
    [uprofile release];
    [sArray release];
    [super dealloc];
}
@end
