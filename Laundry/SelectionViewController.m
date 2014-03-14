//
//  RoomSelectionViewController.m
//  Laundry
//
//  Created by Andrew Daniels on 10/13/13.
//  Copyright (c) 2013 Andrew Daniels. All rights reserved.
//

#import "SelectionViewController.h"
#import "RoomViewController.h"
#import "RoomSelectionModel.h"
#import "LaundryRoom.h"
#import "Reachability.h"

@interface SelectionViewController ()

@end

@implementation SelectionViewController

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

	// Check for a default room
	NSUserDefaults *userDefaults  = [NSUserDefaults standardUserDefaults];
	if([userDefaults stringArrayForKey:@"favoriteRoom"] != nil){
		[self performSegueWithIdentifier:@"roomSelection" sender:self];
	}
	
	
	// Set image for settings button
	UIImage * gearsImage = [UIImage imageNamed:@"glyphicons_137_cogwheels.png"];
	UIImage * scaledGearsImage = [UIImage imageWithCGImage:[gearsImage CGImage] scale:1.25*gearsImage.scale orientation:gearsImage.imageOrientation];
	self.navigationItem.rightBarButtonItem.image = scaledGearsImage;
		
	
	self.tableView.delegate = self;
	self.tableView.dataSource = self;

	
	self.reachability = [Reachability reachabilityWithHostName:@"www.laundryview.com"];
	
	if(self.reachability.currentReachabilityStatus != NotReachable){
		NSLog(@"Connected to LaundryView!");
		self.roomSelection = [RoomSelectionModel roomSelectionModel];
		self.numberOfRooms = [self.roomSelection numberOfRooms];
	}
	
	
	// Monitor internet connection
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
	[self.reachability startNotifier];


    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




// Called by reachability when connection status changes
- (void) reachabilityChanged:(NSNotification *)note
{
	
	Reachability *reachability = [note object];
	NetworkStatus status = reachability.currentReachabilityStatus;
	
	if (status == NotReachable) {
		UIAlertView *connectAlert = [[UIAlertView alloc] initWithTitle:nil
															   message:@"No Internet Connection"
															  delegate:self
													 cancelButtonTitle:@"OK"
													 otherButtonTitles:nil];
		[connectAlert show];
		self.roomSelection = nil;
		self.numberOfRooms = 0;
		[self.tableView reloadData];
	} else{
		if (!self.roomSelection) {
			self.roomSelection = [RoomSelectionModel roomSelectionModel];
			self.numberOfRooms = [self.roomSelection numberOfRooms];
			[self.tableView reloadData];
		}
	}
}




// ===== Tableview setup =====

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.numberOfRooms;
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
	cell.textLabel.text = [self.roomSelection roomForIndex:indexPath.row].name;
    
    return cell;
}




// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if([segue.identifier isEqualToString:@"roomSelection"]){
		
		RoomViewController *roomVC = [segue destinationViewController];
		
		NSUserDefaults *userDefaults  = [NSUserDefaults standardUserDefaults];
		if(self.initialLoad && [userDefaults stringArrayForKey:@"favoriteRoom"] != nil){
			roomVC.room = [LaundryRoom roomWithArray:[userDefaults stringArrayForKey:@"favoriteRoom"]];
		} else {
			//NSString * name = [self.roomSelection roomNameForIndex:[[self.tableView indexPathForSelectedRow] row]];
			
			roomVC.room = [self.roomSelection roomForIndex:[[self.tableView indexPathForSelectedRow] row]];

			[self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
		}
		
		// remove text title "back" on the view being pushed
		self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
																				 style:UIBarButtonItemStylePlain
																				target:nil
																				action:nil];
	}
	
	self.initialLoad = NO;
}
@end
