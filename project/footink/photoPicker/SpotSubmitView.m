//
//  SpotSubmitView.m
//  photoPicker
//
//  Created by yongsik on 11. 7. 1..
//  Copyright 2011 ag. All rights reserved.
//

#import "SpotSubmitView.h"
#import "SpotCategoryView.h"

@implementation SpotSubmitView
@synthesize progressBar,ProgressLabel,returnData,pickerView,arrayColors,spotTable;
@synthesize fList,spotName;

- (void)viewDidLoad{

    UIImageView *logoimage=[[[UIImageView alloc]initWithFrame:CGRectMake(0,0,85,22)] autorelease] ;
    [logoimage setImage:[UIImage imageNamed:@"footink_logo.png"]];
    [self.navigationController.navigationBar.topItem setTitleView:logoimage];
    
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save)] autorelease];

    self.spotTable=[[[UITableView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 300.0) style:UITableViewStyleGrouped] autorelease];
    //self.spotTable.editing = YES;
    self.spotTable.dataSource=self;
    self.spotTable.delegate=self;
    [self.view addSubview:self.spotTable];
    
    [self.fList removeAllObjects];
    self.fList = [[NSMutableArray alloc] init];
    
    [self.fList addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Name",@"text", nil]];
    [self.fList addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Category",@"text", nil]];
    [self.fList addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Address(option)",@"text", nil]];
}
- (void)save{
    
    
    NSString *string = self.spotName.text;
    NSLog(@"save %d",[string length]);
    
    if([string length] > 0){
    }else{
        UIAlertView *alert = [[UIAlertView alloc] init];
        [alert setTitle:@"입력오류"];
        [alert setMessage:@"장소명이 입력되지 않았습니다."];
        [alert setDelegate:self];
        [alert addButtonWithTitle:@"확인"];
        //[alert addButtonWithTitle:@"No"];
        [alert show];
        [alert release];
    }
}
- (void)dealloc
{
    [fList release];
     [arrayColors release];
    [super dealloc];
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
   
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@"%d",[self.fList count]);
    return [self.fList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //tableView.style = UITableViewStylePlain;
    tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;

    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"cell"];

    if(cell == nil) {
       cell =  [[[UITableViewCell alloc] 
                          initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"] autorelease];
       cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
       
    }
    if(indexPath.row==0){
        cell.accessoryType = UITableViewCellAccessoryNone;
        self.spotName=[[[UITextField alloc] initWithFrame:CGRectMake(80.0, 12.0, 230.0, 30.0)] autorelease];
        //input.userInteractionEnabled = FALSE;
        self.spotName.text=@"";
        self.spotName.clearButtonMode = UITextFieldViewModeWhileEditing;

        [cell addSubview:self.spotName];
        
    }
    [cell.textLabel setText:[[self.fList objectAtIndex:indexPath.row] objectForKey:@"text"]];
                        
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	//id AppID = [[UIApplication sharedApplication] delegate];
	//[AppID cmdOpenDetail:[fList objectAtIndex:indexPath.row]];
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if(indexPath.row == 1 ){
        NSLog(@"modal");
        
        SpotCategoryView *category=[[SpotCategoryView alloc] init];
        [self presentModalViewController:category animated:YES];
        [category release];
        
    }else if(indexPath.row == 2 ){
        NSLog(@"%d",indexPath.row);
    }else{
         NSLog(@"%d",indexPath.row);
        //[self cmdEdit];
        [self.spotName becomeFirstResponder];
        //self.spotName.text=@"dddd";
    }
    
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return (indexPath.row % 2 == 0);
 }    

/*- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleNone) {
        id AppID = [[UIApplication sharedApplication] delegate];
        [AppID RemoveRecordWithNo:[[[self.fList objectAtIndex:indexPath.row] objectForKey:@"text"] intValue]];
        [self.fList removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } 
}
*/
- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
