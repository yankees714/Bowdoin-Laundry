//
//  RoomSelectionViewController.m
//  Laundry
//
//  Created by Andrew Daniels on 10/13/13.
//  Copyright (c) 2013 Andrew Daniels. All rights reserved.
//

#import "RoomSelectionViewController.h"
#import "RoomViewController.h"
#import "RoomSelectionModel.h"
#import "LaundryRoom.h"
#import "Reachability.h"

@interface RoomSelectionViewController ()

@end

@implementation RoomSelectionViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.initialLoad =YES;
	
	
	// check for a favorite room
	NSUserDefaults *userDefaults  = [NSUserDefaults standardUserDefaults];
	if([userDefaults stringArrayForKey:@"favoriteRoom"] != nil){
		[self performSegueWithIdentifier:@"roomSelection" sender:self];
	}
	
	self.tableView.delegate = self;
	self.tableView.dataSource = self;
	
	
	// set image for settings button on nav bar
	UIImage * gearsImage = [UIImage imageNamed:@"glyphicons_137_cogwheels.png"];
	UIImage * scaledGearsImage = [UIImage imageWithCGImage:[gearsImage CGImage] scale:1.25*gearsImage.scale orientation:gearsImage.imageOrientation];
	self.navigationItem.rightBarButtonItem.image = scaledGearsImage;
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
	
//	if ([[Reachability reachabilityForLocalWiFi] currentReachabilityStatus] != ReachableViaWiFi) {
//		UIAlertView * getOnWifi = [[UIAlertView alloc] initWithTitle:@"Please connect to WiFi."
//															 message:@"Laundry is only available on Bowdoin's local Wifi network."
//															delegate:nil
//												   cancelButtonTitle:nil
//												   otherButtonTitles:nil];
//		[getOnWifi show];
//	} else{
		self.roomSelection = [RoomSelectionModel roomSelectionModel];
//	}
	

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

/*!
 * Called by Reachability whenever status changes. - this isn't working
 */
- (void) reachabilityChanged:(NSNotification *)note
{
	NSLog(@"Reachability changed");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.roomSelection numberOfRooms];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"laundryRoom";
	
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];

    }
	    
    // Configure the cell...
	
	// get the room for this index
	cell.textLabel.text = [self.roomSelection roomForIndex:indexPath.row];
    
    return cell;
}


#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if([segue.identifier isEqualToString:@"roomSelection"]){
		
		RoomViewController *roomVC = [segue destinationViewController];
		
		NSUserDefaults *userDefaults  = [NSUserDefaults standardUserDefaults];
		if(self.initialLoad && [userDefaults stringArrayForKey:@"favoriteRoom"] != nil){
			roomVC.room = [LaundryRoom roomWithArray:[userDefaults stringArrayForKey:@"favoriteRoom"]];
		} else {
			NSString * name = [self.roomSelection roomForIndex:[[self.tableView indexPathForSelectedRow] row]];
			NSString * ID = [self.roomSelection idForRoom:name];
			
			roomVC.room = [LaundryRoom roomWithName:name andID: ID];

			[self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
		}
		
	}
	
	self.initialLoad = NO;
}



@end
