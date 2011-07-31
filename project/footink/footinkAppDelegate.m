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
#import "splashViewController.h"


@implementation footinkAppDelegate

@synthesize tabController;

@synthesize window,textView;
@synthesize _fsession;
@synthesize FBviewController;


- (void)applicationDidFinishLaunching:(UIApplication *)application {
    // Add registration for remote notifications
    
    splashViewController *splash=[[splashViewController alloc] init];
    
    [window addSubview:splash.view];
    [splash showSplash];
    [splash release];
    
 

    
	[[UIApplication sharedApplication] 
     registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)];
	
	// Clear application badge when app launches
	application.applicationIconBadgeNumber = 0;
    
    tabController = [[UITabBarController alloc]init];
    tabController.delegate = self;
    [window addSubview:tabController.view];
    [self.window makeKeyAndVisible];
    

    
    tabController.viewControllers = [NSArray arrayWithObjects:
                                     [[[UINavigationController alloc] initWithRootViewController:[[PhotoRoot new] autorelease]] autorelease],
                                     [[[UINavigationController alloc] initWithRootViewController:[[[WithRootViewController alloc]init] autorelease]] autorelease],
                                     [[[UINavigationController alloc] initWithRootViewController:[[[photoPickerViewController alloc]init] autorelease]] autorelease],
                                     [[[UINavigationController alloc] initWithRootViewController:[[[SpotListViewController alloc]init] autorelease]] autorelease],
                                     [[[UINavigationController alloc] initWithRootViewController:[[[SettingView alloc] init] autorelease]] autorelease],
                                     [[[UINavigationController alloc] initWithRootViewController:[[[LoginView alloc] init] autorelease]] autorelease],
                                     nil];
    tabController.customizableViewControllers=nil;
    
    
    [self initAuth];
    NSArray *ct=[self ChkAuth];
    int ck;
    ck=ct.count;
    //NSLog(@"ct %d",ck);
    if(ck==0){
      
        self.tabController.selectedIndex = 5;
     
        
    }
    
    //[item1 performSelectorOnMainThread:@selector(Yourfunction) withObject:nil waitUntilDone:NO];
    
    
 
    [self carrierTelCountryCode];
}

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
   
   NSLog(@"---555555");
   // if(![self hasValidLogin] && (viewController != [tabController.viewControllers objectAtIndex:0]))
   // {
   //     NSLog(@"---/////-%@",[self hasValidLogin]);
   //     return NO;
   // }
   // return YES;
    return YES;
}
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    
    NSLog(@"tab select %d",tabBarController.selectedIndex);
    NSInteger tabIndex=tabBarController.selectedIndex;
    
    switch (tabIndex) {
        case 0:
            
            break;
        case 1:
            
            break;    
        default:
            break;
    }
}

/* 
 * --------------------------------------------------------------------------------------------------------------
 *  BEGIN APNS CODE 
 * --------------------------------------------------------------------------------------------------------------
 */


- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)devToken {
	
#if !TARGET_IPHONE_SIMULATOR

    
    [[GlobalStn sharedSingleton] setPushToken:devToken];

	NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
	NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];

	NSUInteger rntypes = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
	

	NSString *pushBadge = @"disabled";
	NSString *pushAlert = @"disabled";
	NSString *pushSound = @"disabled";
	

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

	UIDevice *dev = [UIDevice currentDevice];
	NSString *deviceUuid = dev.uniqueIdentifier;
    NSString *deviceName = dev.name;
	NSString *deviceModel = dev.model;
	NSString *deviceSystemVersion = dev.systemVersion;
	

	NSString *deviceToken = [[[[devToken description] 
                               stringByReplacingOccurrencesOfString:@"<"withString:@""] 
                              stringByReplacingOccurrencesOfString:@">" withString:@""] 
                             stringByReplacingOccurrencesOfString: @" " withString: @""];
	

	NSString *host = @"lpmagazine.co.kr";

	NSString *urlString = [NSString stringWithFormat:@"/apns/apns.php?task=%@&appname=%@&appversion=%@&deviceuid=%@&devicetoken=%@&devicename=%@&devicemodel=%@&deviceversion=%@&pushbadge=%@&pushalert=%@&pushsound=%@", @"register", appName,appVersion, deviceUuid, deviceToken, deviceName, deviceModel, deviceSystemVersion, pushBadge, pushAlert, pushSound];
	
	
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
