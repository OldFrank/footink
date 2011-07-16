//
//  SpotCategoryView.m
//  photoPicker
//
//  Created by yongsik on 11. 7. 2..
//  Copyright 2011 ag. All rights reserved.
//

#import "SpotCategoryView.h"


@implementation SpotCategoryView
@synthesize CategoryView,catList;

-(void)viewWillAppear:(BOOL)animated{

    self.CategoryView = [[[UITableView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 480.0) style:UITableViewStyleGrouped] autorelease];
    self.CategoryView.delegate=self;
    self.CategoryView.dataSource=self;
    [self.view addSubview:self.CategoryView];
    
    [self.catList removeAllObjects];
    self.catList = [[NSMutableArray alloc] init];
    
    [self.catList addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Food",@"text", nil]];
    [self.catList addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Bar",@"text", nil]];
    [self.catList addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Cafe",@"text", nil]];
    [self.catList addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Food",@"text", nil]];
    [self.catList addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Bar",@"text", nil]];
    [self.catList addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Cafe",@"text", nil]];
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@"cat %d",[self.catList count]);
    return [self.catList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //tableView.style = UITableViewStylePlain;
    tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"catcell"];
    
    if(cell == nil) {
        cell =  [[[UITableViewCell alloc] 
                  initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"catcell"] autorelease];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
    }

    [cell.textLabel setText:[[self.catList objectAtIndex:indexPath.row] objectForKey:@"text"]];
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    [self dismissModalViewControllerAnimated:YES];    
}

- (void)dealloc
{
    
    [catList release],catList=nil;
    [super dealloc];
}

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
