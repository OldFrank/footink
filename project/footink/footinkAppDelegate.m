//
//  photoPickerAppDelegate.m
//  photoPicker
//
//  Created by Yongsik Cho on 11. 4. 11..
//  Copyright 2011 ag. All rights reserved.
//

#import "footinkAppDelegate.h"
#import "FacebookAPIViewController.h"
#import "GlobalStn.h"
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import "Reachability.h"

@interface footinkAppDelegate (PrivateMethods)
- (CGFloat) horizontalLocationFor:(NSUInteger)tabIndex;
- (void) addTabBarArrow;
@end

@implementation footinkAppDelegate
@synthesize tabController;
@synthesize tabBarArrow;
@synthesize window,textView;
@synthesize _fsession;
@synthesize FBviewController;

- (void)applicationDidFinishLaunching:(UIApplication *)application {
    // Add registration for remote notifications
	[[UIApplication sharedApplication] 
     registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)];
	
	// Clear application badge when app launches
	application.applicationIconBadgeNumber = 0;
    
    tabController = [[UITabBarController alloc]init];
    tabController.viewControllers = [NSArray arrayWithObjects:
                                     [[[UINavigationController alloc] initWithRootViewController:[[PhotoRoot new] autorelease]] autorelease],
                                     [[[UINavigationController alloc] initWithRootViewController:[[[withRootView alloc]init] autorelease]] autorelease],
                                     [[[UINavigationController alloc] initWithRootViewController:[[[photoPickerViewController alloc]init] autorelease]] autorelease],
                                     [[[UINavigationController alloc] initWithRootViewController:[[[SpotListViewController alloc]init] autorelease]] autorelease],
                                     [[[UINavigationController alloc] initWithRootViewController:[[[SettingView alloc] init] autorelease]] autorelease],
                                     nil];
    
    tabController.delegate = self;
    //[item1 performSelectorOnMainThread:@selector(Yourfunction) withObject:nil waitUntilDone:NO];
    
    [window addSubview:tabController.view];
    //[self addTabBarArrow];
    [self.window makeKeyAndVisible];
    
    
    /*NSError *error;
     NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); //1
     NSString *documentsDirectory = [paths objectAtIndex:0]; //2
     NSString *path = [documentsDirectory stringByAppendingPathComponent:@"data.plist"]; //3
     
     NSFileManager *fileManager = [NSFileManager defaultManager];
     
     if (![fileManager fileExistsAtPath: path]) //4
     {
     NSString *bundle = [[NSBundle mainBundle] pathForResource:@"data" ofType:@"plist"]; //5
     
     [fileManager copyItemAtPath:bundle toPath: path error:&error]; //6
     }
     
     //æ≤±‚
     NSMutableDictionary *myDic = [[[NSMutableDictionary alloc]init]  autorelease];
     [myDic setObject:@"father, mother, son" forKey:@"familyRole"];
     [myDic setObject:@"stday, wiseleeg, YOUNGYOUNG" forKey:@"names"];
     [myDic writeToFile:path atomically:YES];
     
     NSMutableDictionary *saveData = [[[NSMutableDictionary alloc]init]  autorelease];
     saveData = [NSMutableDictionary dictionaryWithCapacity: 3];
     [saveData setObject: @"d1" forKey:@"dataOne"];
     [saveData setObject: @"d2" forKey:@"dataTwo"];
     [saveData setObject: @"d3" forKey:@"dataThree"];
     
     [saveData writeToFile:path atomically:YES];
     
     
     NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
     
     NSMutableArray *arrayIWillWrite = [NSMutableArray array];
     NSMutableDictionary *dictionary;
     
     dictionary = [NSMutableDictionary dictionary];
     [dictionary setObject:[NSNumber numberWithInt:0] forKey:@"favourites"];
     [dictionary setObject:[NSNumber numberWithInt:0] forKey:@"id"];
     [dictionary setObject:@"This is my first record" forKey:@"story"];
     [dictionary setObject:[NSNumber numberWithInt:324567] forKey:@"timestamp"];
     [arrayIWillWrite addObject:dictionary];
     
     dictionary = [NSMutableDictionary dictionary];
     [dictionary setObject:[NSNumber numberWithInt:0] forKey:@"favourites"];
     [dictionary setObject:[NSNumber numberWithInt:1] forKey:@"id"];
     [dictionary setObject:@"This is my second record" forKey:@"story"];
     [dictionary setObject:[NSNumber numberWithInt:321456] forKey:@"timestamp"];
     [arrayIWillWrite addObject:dictionary];
     
     [arrayIWillWrite writeToFile:path atomically:NO];
     
     NSArray *arrayThatWasRead = [NSArray arrayWithContentsOfFile:path];
     NSLog(@"%@", arrayThatWasRead);
     
     NSDictionary *dictionaryFromArrayThatWasRead = [arrayThatWasRead objectAtIndex:0];
     NSLog(@"%@", dictionaryFromArrayThatWasRead);
     
     [pool release];
     
     
     
     
     
     //¿–±‚
     NSMutableDictionary *savedStock = [[NSMutableDictionary alloc] initWithContentsOfFile: path];
     //load from savedStock example int value
     
     int value2;
     value2 = [[savedStock objectForKey:@"item2"] intValue];
     NSLog(@"plist %d",value2);
     [savedStock release];
     */
    
    [self initAuth];
    NSArray *ct=[self ChkAuth];
    int ck;
    ck=ct.count;
    //NSLog(@"ct %d",ck);
    if(ck==0){
        LoginView *login = [[LoginView alloc] init];
        [tabController presentModalViewController:login animated:NO];
        [login release];
    }
    
    [self carrierTelCountryCode];
}

//æÓ«√∏Æƒ…¿Ãº«¿Ã Ω««‡µ«æÓ¿÷¡ˆ æ ¿∫ ∞ÊøÏ «™Ω√∏¶ πﬁæ∆º≠ æÓ«√∏Æƒ…¿Ãº«¿Ã Ω««‡µ…∂ß ∞¸∑√ ¡§∫∏∞° launchOptionsø° ¥„∞‹ø¿∞‘ µ«∏Á ±◊ ¡§∫∏∏¶ ∞°¡ˆ∞Ì didFinishLaunchingWithOptions∏¶ ¿Á»£√‚«œ¥¬ ∑Œ¡˜. 
//±◊ µ⁄ø° ∫∏∏È ≥™øÕ¿÷¥¬ APNSµÓ∑œ ∫Œ∫–¿Ã ªÁøÎ¿⁄ø°∞‘ «™Ω√∏¶ «„øÎ«“¡ˆ π∞æÓ∫∏¥¬ ∫Œ∫–.

/* 
 * --------------------------------------------------------------------------------------------------------------
 *  BEGIN APNS CODE 
 * --------------------------------------------------------------------------------------------------------------
 */

/**
 * Fetch and Format Device Token and Register Important Information to Remote Server
 */
//APNSø° µπŸ¿ÃΩ∫ ¡§∫∏∏¶ µÓ∑œ«œ∞Ì 64πŸ¿Ã∆Æ¿« πÆ¿⁄ø≠¿ª πﬁæ∆ø¬¥Ÿ.
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)devToken {
	
#if !TARGET_IPHONE_SIMULATOR
    //NSLog(@"token %@",devToken);
    
    [[GlobalStn sharedSingleton] setPushToken:devToken];
    
	// Get Bundle Info for Remote Registration (handy if you have more than one app)
	NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
	NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
	
	// Check what Notifications the user has turned on.  We registered for all three, but they may have manually disabled some or all of them.
	NSUInteger rntypes = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
	
	// Set the defaults to disabled unless we find otherwise...
	NSString *pushBadge = @"disabled";
	NSString *pushAlert = @"disabled";
	NSString *pushSound = @"disabled";
	
	// Check what Registered Types are turned on. This is a bit tricky since if two are enabled, and one is off, it will return a number 2... not telling you which
	// one is actually disabled. So we are literally checking to see if rnTypes matches what is turned on, instead of by number. The "tricky" part is that the 
	// single notification types will only match if they are the ONLY one enabled.  Likewise, when we are checking for a pair of notifications, it will only be 
	// true if those two notifications are on.  This is why the code is written this way ;)
	if(rntypes == UIRemoteNotificationTypeBadge){
		pushBadge = @"enabled";
	}
	else if(rntypes == UIRemoteNotificationTypeAlert){
		pushAlert = @"enabled";
	}
	else if(rntypes == UIRemoteNotificationTypeSound){
		pushSound = @"enabled";
	}
	else if(rntypes == ( UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert)){
		pushBadge = @"enabled";
		pushAlert = @"enabled";
	}
	else if(rntypes == ( UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)){
		pushBadge = @"enabled";
		pushSound = @"enabled";
	}
	else if(rntypes == ( UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound)){
		pushAlert = @"enabled";
		pushSound = @"enabled";
	}
	else if(rntypes == ( UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound)){
		pushBadge = @"enabled";
		pushAlert = @"enabled";
		pushSound = @"enabled";
	}
	
	// Get the users Device Model, Display Name, Unique ID, Token & Version Number
	UIDevice *dev = [UIDevice currentDevice];
	NSString *deviceUuid = dev.uniqueIdentifier;
    NSString *deviceName = dev.name;
	NSString *deviceModel = dev.model;
	NSString *deviceSystemVersion = dev.systemVersion;
	
	// Prepare the Device Token for Registration (remove spaces and < >)
	NSString *deviceToken = [[[[devToken description] 
                               stringByReplacingOccurrencesOfString:@"<"withString:@""] 
                              stringByReplacingOccurrencesOfString:@">" withString:@""] 
                             stringByReplacingOccurrencesOfString: @" " withString: @""];
	
	// Build URL String for Registration
	// !!! CHANGE "www.mywebsite.com" TO YOUR WEBSITE. Leave out the http://
	// !!! SAMPLE: "secure.awesomeapp.com"
	NSString *host = @"lpmagazine.co.kr";
	
	// !!! CHANGE "/apns.php?" TO THE PATH TO WHERE apns.php IS INSTALLED 
	// !!! ( MUST START WITH / AND END WITH ? ). 
	// !!! SAMPLE: "/path/to/apns.php?"
	NSString *urlString = [NSString stringWithFormat:@"/apns/apns.php?task=%@&appname=%@&appversion=%@&deviceuid=%@&devicetoken=%@&devicename=%@&devicemodel=%@&deviceversion=%@&pushbadge=%@&pushalert=%@&pushsound=%@", @"register", appName,appVersion, deviceUuid, deviceToken, deviceName, deviceModel, deviceSystemVersion, pushBadge, pushAlert, pushSound];
	
	// Register the Device Data
	// !!! CHANGE "http" TO "https" IF YOU ARE USING HTTPS PROTOCOL
    //NSLog(@"%@",urlString);
	NSURL *url = [[NSURL alloc] initWithScheme:@"http" host:host path:urlString];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
	NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
	NSLog(@"Register URL: %@", url);
	NSLog(@"Return Data: %@", returnData);
	
#endif
}

/**
 * Failed to Register for Remote Notifications
 */
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
	
#if !TARGET_IPHONE_SIMULATOR
	
	NSLog(@"Error in registration. Error: %@", error);
	
#endif
}

/**
 * Remote Notification Received while application was open.
 */
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
	NSLog(@"didReceive");
#if !TARGET_IPHONE_SIMULATOR
    
	NSLog(@"remote notification: %@",[userInfo description]);
	NSDictionary *apsInfo = [userInfo objectForKey:@"aps"];
	
	NSString *alert = [apsInfo objectForKey:@"alert"];
	NSLog(@"Received Push Alert: %@", alert);
	
	NSString *sound = [apsInfo objectForKey:@"sound"];
	NSLog(@"Received Push Sound: %@", sound);
	AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
	
	NSString *badge = [apsInfo objectForKey:@"badge"];
	NSLog(@"Received Push Badge: %@", badge);
	application.applicationIconBadgeNumber = [[apsInfo objectForKey:@"badge"] integerValue];
	
    
    //application.applicationIconBadgeNumber = 0;
    self.textView.text = [userInfo description];
    
    // We can determine whether an application is launched as a result of the user tapping the action
    // button or whether the notification was delivered to the already-running application by examining
    // the application state.
    
    if (application.applicationState == UIApplicationStateActive) {
        // Nothing to do if applicationState is Inactive, the iOS already displayed an alert view.
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Did receive a Remote Notification"
                                                            message:[NSString stringWithFormat:@"hello:\n%@",
                                                                     [[userInfo objectForKey:@"aps"] objectForKey:@"alert"]]
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
        [alertView release];
    }
    
#endif
}

/* 
 * --------------------------------------------------------------------------------------------------------------
 *  END APNS CODE 
 * --------------------------------------------------------------------------------------------------------------
 */
-(void)initAuth{
    //NSLog(@"initAuth");
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *Dir=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0];
    NSString *filePath = [Dir stringByAppendingPathComponent:@"setting.sqlite"];
    
    if([fileManager fileExistsAtPath:filePath]) return;
    
    sqlite3 *db;
    if(sqlite3_open([filePath UTF8String], &db) != SQLITE_OK){
        sqlite3_close(db);
        NSLog(@"Error");
        return;
    }
    char *sql = "create TABLE IF NOT EXISTS setting (no INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,name CHAR,email CHAR,privatekey CHAR,profile CHAR,share INTEGER, gps INTEGER)";
    NSLog(@"exc");
    if(sqlite3_exec(db, sql, nil, nil, nil) != SQLITE_OK){
        sqlite3_close(db);
        NSLog(@"Error");
        return;
    }
    sqlite3_close(db);
}
-(NSArray *)ChkAuth{
    // NSLog(@"ChkAuth");
    sqlite3 *db;
    NSString *Dir=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0];
    NSString *filePath = [Dir stringByAppendingPathComponent:@"setting.sqlite"];
    if(sqlite3_open([filePath UTF8String],&db)!=SQLITE_OK){
        sqlite3_close(db);
        NSLog(@"Error");
        return nil;
    }
    NSLog(@"%@",filePath);
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
    //NSLog(@"%@",Result);
    return Result;
}
//tabbar animation
- (void) addTabBarArrow
{
    UIImage* tabBarArrowImage = [UIImage imageNamed:@"TabBarNipple.png"];
    self.tabBarArrow = [[[UIImageView alloc] initWithImage:tabBarArrowImage] autorelease];
    // To get the vertical location we start at the bottom of the window, go up by height of the tab bar, go up again by the height of arrow and then come back down 2 pixels so the arrow is slightly on top of the tab bar.
    CGFloat verticalLocation = self.window.frame.size.height - tabController.tabBar.frame.size.height - tabBarArrowImage.size.height + 2;
    tabBarArrow.frame = CGRectMake([self horizontalLocationFor:0], verticalLocation, tabBarArrowImage.size.width, tabBarArrowImage.size.height);
    
    [self.window addSubview:tabBarArrow];
}

- (CGFloat) horizontalLocationFor:(NSUInteger)tabIndex
{
    // A single tab item's width is the entire width of the tab bar divided by number of items
    CGFloat tabItemWidth = tabController.tabBar.frame.size.width / tabController.tabBar.items.count;
    // A half width is tabItemWidth divided by 2 minus half the width of the arrow
    CGFloat halfTabItemWidth = (tabItemWidth / 2.0) - (tabBarArrow.frame.size.width / 2.0);
    
    // The horizontal location is the index times the width plus a half width
    return (tabIndex * tabItemWidth) + halfTabItemWidth;
}

- (void)tabBarController:(UITabBarController *)theTabBarController didSelectViewController:(UIViewController *)viewController
{
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.2];
    CGRect frame = tabBarArrow.frame;
    frame.origin.x = [self horizontalLocationFor:tabController.selectedIndex];
    tabBarArrow.frame = frame;
    [UIView commitAnimations];  
    
}

-(void)carrierTelCountryCode{
    CTTelephonyNetworkInfo *networkInfo = [[[CTTelephonyNetworkInfo alloc] init] autorelease];
    CTCarrier *carrier = [networkInfo subscriberCellularProvider];
    
    // ªÁæ˜¿⁄ ¿Ã∏ß æÀæ∆ø¿±‚
    NSString *carrierName = [carrier carrierName];
    if (carrierName != nil)
        NSLog(@"Carrier: %@", carrierName);
    
    // ∏πŸ¿œ ±π∞°ƒ⁄µÂ æÀæ∆ ø¿±‚
    NSString *mcc = [carrier mobileCountryCode];
    if (mcc != nil)
        NSLog(@"Mobile Country Code (MCC): %@", mcc);
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
    //exit(0);
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

- (void)dealloc
{
    //[tabController release];
    [_fsession release];
    [FBviewController release];
    [window release];
    [super dealloc];
}

@end
