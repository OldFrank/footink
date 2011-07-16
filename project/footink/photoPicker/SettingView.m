//
//  SettingView.m
//  photoPicker
//
//  Created by Yongsik Cho on 11. 4. 28..
//  Copyright 2011 ag. All rights reserved.
//

#import "SettingView.h"
#import "SettingCell.h"
#import "GlobalStn.h"
//#import "FacebookAPIViewController.h"




#define _APP_KEY @"128709617185037"
#define _SECRET_KEY @"e770922fe60553ad947f439551d49b02"

@implementation SettingView

@synthesize usersession;
@synthesize username;
@synthesize post;



-(id)init {
    NSLog(@"s init");
    self = [super init];
    if(self != nil){
        self.title=@"Setting";
       // fSearch = [[UISearchBar alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 40.0)];
       // fSearch.delegate = self;
       // [self.view addSubview:fSearch];
    }
    //[self initDB];
    return self;
}
-(void)viewDidLoad{
    UIImageView *logoimage=[[UIImageView alloc]initWithFrame:CGRectMake(0,0,85,22)] ;
    [logoimage setImage:[UIImage imageNamed:@"footink_logo.png"]];
    [self.navigationController.navigationBar.topItem setTitleView:logoimage];
    
    fTable = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 480.0 - 40.0 -40.0) style:UITableViewStyleGrouped];
    fTable.delegate = self;
    fTable.dataSource = self;
    [self.view addSubview:fTable];
    
    
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(cmdAdd)] autorelease];
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(cmdEdit)] autorelease];
    
    [super viewDidLoad];

}
-(void)viewWillAppear:(BOOL)animated {

    [fList removeAllObjects];
    //    id AppID=[[UIApplication sharedApplication] delegate];
    //    NSLog(@"%@",AppID);
    //NSLog(@"%@",[self GetRecords]);
    
    fList = [[NSMutableArray alloc] init];
    
   // NSLog(@"%@",[[[GlobalStn sharedSingleton] sArray] objectAtIndex:<#(NSUInteger)#>:@"email"]);
    
   // NSArray *ssss=[[GlobalStn sharedSingleton] sArray];
    
    
    
    [fList addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"",@"grouptitle",
                      [NSMutableArray arrayWithObjects:
                       [NSDictionary dictionaryWithObjectsAndKeys:@"프로필수정",@"text", nil],
                       [NSDictionary dictionaryWithObjectsAndKeys:@"사진공유",@"text", nil],
                       [NSDictionary dictionaryWithObjectsAndKeys:@"위치정보 사용",@"text", nil],
                       [NSDictionary dictionaryWithObjectsAndKeys:@"로그아웃",@"text", nil],
                       nil],@"data",
                      nil]
     ];

    [fList addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"SNS",@"grouptitle",
                      [NSMutableArray arrayWithObjects:
                       [NSDictionary dictionaryWithObjectsAndKeys:@"Twitter",@"text", nil],
                       [NSDictionary dictionaryWithObjectsAndKeys:@"Facebook",@"text", nil],
                       [NSDictionary dictionaryWithObjectsAndKeys:@"Cyworld",@"text", nil],
                       nil],@"data",
                      nil]
     ];
    

   // [fList setArray:[self GetRecords]];
    [fTable reloadData];
}

-(void)cmdAdd{
    AddViewController *a = [[AddViewController alloc] init];
	[a setDelegate:self];
	[self.navigationController pushViewController:a animated:YES];
}
- (void)cmdEdit{
    [fTable setEditing:!fTable.editing animated:YES];
}
- (void)initDB {
    NSLog(@"initDB");
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"setting.db3"];
    NSLog(@"%@",documentsDirectory);
    if([fileManager fileExistsAtPath:filePath]) return;
    
    sqlite3 *database;
//    NSLog(@"db open %@",sqlite3_open([filePath UTF8String], &database));
    if(sqlite3_open([filePath UTF8String], &database) != SQLITE_OK){
        sqlite3_close(database);
        NSLog(@"Error");
        return;
    }
    
    char *sql = "create TABLE footink (no INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, memo CHAR, priority INTEGER)";
    //NSLog(@"query %@",sql);
    if(sqlite3_exec(database, sql, nil, nil, nil) != SQLITE_OK){
        sqlite3_close(database);
        NSLog(@"Error");
        return;
    }
    
    sqlite3_close(database);
    
}
-(void)AddRecordWithMemo:(NSString *)Memo Priority:(int)Priority{
    NSLog(@"AddRecord %@",Memo);
    sqlite3 *database;
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"footdb.db3"];
    if(sqlite3_open([filePath UTF8String],&database) != SQLITE_OK){
        sqlite3_close(database);
        NSLog(@"Error");
        return;
    }
    sqlite3_stmt *statement;
    char *sql = "INSERT INTO footink (memo,priority) VALUES(?,?)";
    
    if(sqlite3_prepare_v2(database,sql,-1,&statement,NULL)==SQLITE_OK){
        sqlite3_bind_text(statement,1,[Memo UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_int(statement, 2,Priority);
        //NSLog(@"%@",Priority);
        if(sqlite3_step(statement) != SQLITE_DONE){
            NSLog(@"Error");
        }
    }
    sqlite3_finalize(statement);
    sqlite3_close(database);
}
-(void)ModifyRecordWithNo:(int)No Memo:(NSString *)Memo Priority:(int)Priority{
    sqlite3 *database;
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"footdb.db3"];
    if(sqlite3_open([filePath UTF8String],&database) != SQLITE_OK){
        sqlite3_close(database);
        NSLog(@"Error");
        return;
    }
    
    sqlite3_stmt *statement;
    char *sql = "UPDATE footink SET memo=?, priority=? WHERE no=?";
    if(sqlite3_prepare_v2(database, sql,-1,&statement, NULL) == SQLITE_OK){
        sqlite3_bind_text(statement,1,[Memo UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_int(statement,2,Priority);
        sqlite3_bind_int(statement,3,No);
        if(sqlite3_step(statement) != SQLITE_DONE){
            NSLog(@"Error");   
        }
    }
    sqlite3_finalize(statement);
    sqlite3_close(database);
}
-(void)RemoveRecordWithNo:(int)No{
    sqlite3 *database;
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES) objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"footdb.db3"];
    if(sqlite3_open([filePath UTF8String], &database) != SQLITE_OK){
        sqlite3_close(database);
        NSLog(@"Error");
        return;
    }
    
    sqlite3_stmt *statement;
    char *sql = "DELETE FROM footink WHERE no=?";
    if(sqlite3_prepare_v2(database,sql,-1,&statement,NULL) == SQLITE_OK){
        sqlite3_bind_int(statement,1,No);
        if(sqlite3_step(statement) != SQLITE_DONE){
            NSLog(@"Error");
        }
    }
    sqlite3_finalize(statement);
    sqlite3_close(database);
}
-(NSArray *)GetRecords{
    NSLog(@"GetRecords");
    sqlite3 *database;
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"footdb.db3"];
    if(sqlite3_open([filePath UTF8String], &database) != SQLITE_OK){
        sqlite3_close(database);
        NSLog(@"Error");
        return nil;
    }
    NSMutableArray *Result = [NSMutableArray array];
    sqlite3_stmt *statement;
    char *sql = "SELECT no,memo,priority FROM footink";
    if(sqlite3_prepare_v2(database, sql,-1, &statement, NULL) == SQLITE_OK){
        while(sqlite3_step(statement)==SQLITE_ROW){
            NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                                 [NSNumber numberWithInt:sqlite3_column_int(statement,0)],@"no",
                                 [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement,1)],@"memo",
                                 [NSNumber numberWithInt:sqlite3_column_int(statement,2)],@"priority",
                                 nil];
            [Result addObject:dic];
        }
    }
    return Result;
}
- (void)AddviewSubmitWithMemo:(NSString *)Memo Priority:(int)Priority {
	[self AddRecordWithMemo:Memo Priority:Priority];
}

- (void)cmdOpenDetail:(NSDictionary *)data {
	
}
-(NSArray *)SearchRecordWithMemo:(NSString *)text {
    if(!text || [text length] == 0) return [self GetRecords];
    
    sqlite3 *database;
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"footdb.db3"];
    if(sqlite3_open([filePath UTF8String], &database) != SQLITE_OK){
        sqlite3_close(database);
        NSLog(@"Error");
        return nil;
    }
    
    NSMutableArray *Result = [NSMutableArray array];
    sqlite3_stmt *statement;
    char *sql = "SELECT no,memo,priority FROM footink WHERE memo LIKE ?";
    if(sqlite3_prepare_v2(database, sql,-1, &statement, NULL) == SQLITE_OK){
        sqlite3_bind_text(statement, 1, [[NSString stringWithFormat:@"%%%@%%",text] UTF8String], -1, SQLITE_TRANSIENT);
        while(sqlite3_step(statement)==SQLITE_ROW){
            NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                                 [NSNumber numberWithInt:sqlite3_column_int(statement,0)],@"no",
                                 [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement,1)],@"memo",
                                 [NSNumber numberWithInt:sqlite3_column_int(statement,2)],@"priority",
                                 nil];
            [Result addObject:dic];
        }
    }
    return Result;
}
- (void)session:(FBSession*)session didLogin:(FBUID)uid {
	self.usersession =session;
    NSLog(@"User with id %lld logged in.", uid);
	[self getFacebookName];
}

- (void)getFacebookName {
	NSString* fql = [NSString stringWithFormat:
					 @"select uid,name from user where uid == %lld", self.usersession.uid];
	NSDictionary* params = [NSDictionary dictionaryWithObject:fql forKey:@"query"];
	[[FBRequest requestWithDelegate:self] call:@"facebook.fql.query" params:params];
	self.post=YES;
}

- (void)request:(FBRequest*)request didLoad:(id)result {
	if ([request.method isEqualToString:@"facebook.fql.query"]) {
		NSArray* users = result;
		NSDictionary* user = [users objectAtIndex:0];
		NSString* name = [user objectForKey:@"name"];
		self.username = name;		
		
		if (self.post) {
			[self postToWall];
			self.post = NO;
		}
	}
}

- (void)postToWall {
	
	FBStreamDialog *dialog = [[[FBStreamDialog alloc] init] autorelease];
	dialog.userMessagePrompt = @"Enter your message:";
	dialog.attachment = [NSString stringWithFormat:@"{\"name\":\"Facebook Connect for iPhone\",\"href\":\"http://developers.facebook.com/connect.php?tab=iphone\",\"caption\":\"Caption\",\"description\":\"Description\",\"media\":[{\"type\":\"image\",\"src\":\"http://img40.yfrog.com/img40/5914/iphoneconnectbtn.jpg\",\"href\":\"http://developers.facebook.com/connect.php?tab=iphone/\"}],\"properties\":{\"another link\":{\"text\":\"Facebook home page\",\"href\":\"http://www.facebook.com\"}}}"];
	[dialog show];
	
}



- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];
	return YES;
}
- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;

}
-(void)dealloc {
    [fSearch release];
    [fTable release];
    [fList release];
    [username release];
	[usersession release];
    


    [super dealloc];
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (!fList) return 1;
    return ([fList count] == 0 ? 1: [fList count]);
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [[fList objectAtIndex:section] objectForKey:@"grouptitle"];
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [[[fList objectAtIndex:section] objectForKey:@"data"] count];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    //tableView.style = UITableViewStylePlain;
    tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    tableView.separatorColor = [UIColor lightGrayColor];
    
    if (cell == nil) {
        
     cell = [[[SettingCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"cell"] autorelease];
    
    //UILabel* label = [ cell textLabel ];
    //[label setText : [[[[fList objectAtIndex:indexPath.section] objectForKey:@"data"] objectAtIndex:indexPath.row] objectForKey:@"text"]];
        
    NSLog(@"%d",indexPath.section);
        
    switch(indexPath.section){
        case 0: {
            switch(indexPath.row){
                case 1:{
                    [cell.textLabel setText:[[[[fList objectAtIndex:indexPath.section] objectForKey:@"data"] objectAtIndex:indexPath.row] objectForKey:@"text"]];
			//[cell.textLabel setTextAlignment:UITextAlignmentRight];
                    
                    cell.accessoryType = UITableViewCellAccessoryNone;
                   
                      
                    UIView	*viewCell = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 160, 40)];
                    UISwitch *switchAutoSave = [[UISwitch alloc] initWithFrame:CGRectMake(60, 6, 94, 27)];
                    [switchAutoSave setTag:1];
            
                    NSString *sha=[[[[GlobalStn sharedSingleton] sArray] objectAtIndex:0] objectForKey:@"share"];
                    int sh=[sha intValue];
            
                    if (sh==1) [switchAutoSave setOn:YES animated:NO];			
                    else [switchAutoSave setOn:NO animated:NO];
			
                    [viewCell addSubview:switchAutoSave];
                    [switchAutoSave addTarget:self action:@selector(switchChange:) forControlEvents:UIControlEventValueChanged];
                    cell.accessoryView = viewCell;
                    cell.accessoryView.userInteractionEnabled = YES;
                    
                    [switchAutoSave release];
                    [viewCell		release];
                    break;
                }
                case 2:{
                    [cell.textLabel setText:[[[[fList objectAtIndex:indexPath.section] objectForKey:@"data"] objectAtIndex:indexPath.row] objectForKey:@"text"]];
                    //[cell.textLabel setTextAlignment:UITextAlignmentRight];
                   
                    cell.accessoryType = UITableViewCellAccessoryNone;
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    
                    UIView	*viewCell = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 160, 40)];
                    UISwitch *switchAutoSave = [[UISwitch alloc] initWithFrame:CGRectMake(60, 6, 90, 24)];
                    [switchAutoSave setTag:1];
                    
                    NSString *sha=[[[[GlobalStn sharedSingleton] sArray] objectAtIndex:0] objectForKey:@"share"];
                    int sh=[sha intValue];
                    
                    if (sh==1) [switchAutoSave setOn:YES animated:YES];			
                    else [switchAutoSave setOn:NO animated:YES];
                    
                    [viewCell addSubview:switchAutoSave];
                    [switchAutoSave addTarget:self action:@selector(switchChange:) forControlEvents:UIControlEventValueChanged];
                    
                    cell.accessoryView = viewCell;
                    cell.accessoryView.userInteractionEnabled = YES;
                    
                    [switchAutoSave release];
                    [viewCell		release];
                    break;
                }

                default:{
                    cell.userInteractionEnabled = YES;
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    [(SettingCell *)cell textLabel].text = [[[[fList objectAtIndex:indexPath.section] objectForKey:@"data"] objectAtIndex:indexPath.row] objectForKey:@"text"];
                    
                    break;
                }

            }
            break;
        }
        default:{
            cell.userInteractionEnabled = YES;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            [(SettingCell *)cell textLabel].text = [[[[fList objectAtIndex:indexPath.section] objectForKey:@"data"] objectAtIndex:indexPath.row] objectForKey:@"text"];
            
            break;
        }
    }
    }
    return cell;
}
-(NSIndexPath*)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0){
        switch (indexPath.row) {
            case 0:
                return indexPath;
                break;
            case 3:
                return indexPath;
                break;
            default:
                return nil;
                break;
        }
    }
        
    return indexPath;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"table height");
    if (indexPath.section == 0 && indexPath.row == 0) {
        return 36;
    }
    return 36;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	//id AppID = [[UIApplication sharedApplication] delegate];
	//[AppID cmdOpenDetail:[fList objectAtIndex:indexPath.row]];
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if(indexPath.section == 1 && indexPath.row == 0 ){
        [self fbLoginFrm];
    }else if(indexPath.section == 1 && indexPath.row == 1 ){
        
    }
    
}
-(IBAction)switchChange:(UISwitch *)tempSwitch{
    if(tempSwitch.tag==1){
        if(tempSwitch.on == YES){
            NSLog(@"YES");  
        
                        
            //[sharedAppl registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)];

        }else{
            NSLog(@"NO"); 
        //[sharedAppl unregisterForRemoteNotifications];
        }
    }
}
-(void)fbLoginFrm{
    footinkAppDelegate *appDelegate =(footinkAppDelegate *)[[UIApplication sharedApplication]delegate];
    
    if (appDelegate._fsession == nil){
        appDelegate._fsession = [FBSession sessionForApplication:_APP_KEY 
                                                         secret:_SECRET_KEY delegate:self];
    }
    
    if (appDelegate._fsession.isConnected) {
        [appDelegate._fsession logout];
    } else {
        FBLoginDialog *dialog=[[[FBLoginDialog alloc] initWithFSession:appDelegate._fsession] autorelease];
        [dialog show];
    }

}

/*
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
   return (indexPath.row % 2 == 0);
}    
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		id AppID = [[UIApplication sharedApplication] delegate];
		[AppID RemoveRecordWithNo:[[[fList objectAtIndex:indexPath.row] objectForKey:@"no"] intValue]];
		[fList removeObjectAtIndex:indexPath.row];
		[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
	} 
}
 */


@end
