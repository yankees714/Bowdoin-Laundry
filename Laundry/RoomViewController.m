//
//  RoomViewController.m
//  Laundry
//
//  Created by Andrew Daniels on 9/12/13.
//  Copyright (c) 2013 Andrew Daniels. All rights reserved.
//

#import "RoomViewController.h"
#import "LaundryDataModel.h"
#import "LaundryMachine.h"
#import "LaundryRoom.h"
#import "TestFlight.h"



@interface RoomViewController ()
@end


@implementation RoomViewController

- (void)viewDidLoad{
	[super viewDidLoad];
	
	[TestFlight passCheckpoint:self.room.name];
	
	
	self.tableView.delegate = self;
	self.tableView.dataSource = self;
	
	
		
	if ([self.room isDefaultRoom]) {
		self.navigationItem.rightBarButtonItem.tintColor = [UIColor colorWithRed:241/255.0
																		   green:196/255.0
																			blue:15/255.0
																		   alpha:1.0];
	}
	
	
	// set image for settings button on nav bar
	UIImage * starImage = [UIImage imageNamed:@"glyphicons_049_star.png"];
	UIImage * scaledStarImage = [UIImage imageWithCGImage:[starImage CGImage] scale:1.2*starImage.scale orientation:starImage.imageOrientation];
	self.navigationItem.rightBarButtonItem.image = scaledStarImage;
	
	//interface setup
	self.navigationItem.title = self.room.name;
	
	
	[self.refreshControl addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
	
	// Let notification center start an update when the app becomes active
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateMachinesAndStatus) name:UIApplicationDidBecomeActiveNotification object:nil];
	
	// Grab and fill laundry data
	self.roomModel = [[LaundryDataModel  alloc] initWithID:self.room.ID];
	
	//set up updates and begin - not necessary for now
//	[NSTimer scheduledTimerWithTimeInterval:30.0 target:self selector:@selector(updateMachinesAndStatus) userInfo:nil repeats:YES];
//	[self updateMachinesAndStatus];
	
}




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)updateMachinesAndStatus {
	
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	[self.roomModel refreshLaundryData];
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	
	// update tableview
	[self.tableView reloadData];
	//refresh view
	[self.view setNeedsDisplay];
}

- (void)refreshView:(UIRefreshControl *)sender {
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		[self updateMachinesAndStatus];
	});
	
	[sender endRefreshing];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section {
    //return [self.machinesAndStatuses count];
	if (section == 0) {
		return self.roomModel.numberOfWashers;
	} else {
		return self.roomModel.numberOfDryers;
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * cellIdentifier = @"machineStatus";
    
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
	
//	UILongPressGestureRecognizer * longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressCell)];
//	[cell addGestureRecognizer:longPress];
	
	// calculate index from index path
	NSInteger index = (self.roomModel.numberOfWashers * (indexPath.section)) + indexPath.row;
	
	
	
	// Set up the cell
	cell.textLabel.text = [self.roomModel machineNameForIndex:index];
	cell.detailTextLabel.text = [self.roomModel machineStatusForIndex:index];
	
	cell.textLabel.font = [UIFont fontWithName:@"Avenir-Roman" size:18.0];
	cell.detailTextLabel.font = [UIFont fontWithName:@"Avenir-Roman" size:12.0];
	
	
	
	//get rid of the background color of text labels
	[[cell textLabel] setBackgroundColor:[UIColor clearColor]];
	[[cell detailTextLabel] setBackgroundColor:[UIColor clearColor]];
	
	cell.backgroundColor = [self.roomModel tintColorForMachineWithIndex:index];
	
	LaundryMachine * machine = [self.roomModel.machines objectAtIndex:index];
	
	
	if (machine.running || machine.extended) {
		// adding switch <- *change this to a button*
		//UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectZero];
		UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(0, 8, 20, 20)];
		UIImage *star = [UIImage imageNamed:@"glyphicons_049_star.png"];
		[button setImage:star forState:UIControlStateNormal];
		button.tag = index;
		
		cell.accessoryView = button;
		
		// handle the switch being toggled
		[button addTarget:self action:@selector(watch:) forControlEvents:UIControlEventTouchUpInside];
	} else {
		cell.accessoryView = nil;
	}
	
	
	
	// check user defaults to see if user is watching this machine
	//NSString *key = [self keyForSwitchWithRoom:self.room.name andMachine:cell.textLabel.text];
	//BOOL watch = [[NSUserDefaults standardUserDefaults] boolForKey:key];
	//[switchView setOn:watch animated:NO];
	
	
//	LaundryMachine * machine = [self.roomModel.machines objectAtIndex:index];
//	
//	//check for machine available status
//	if (machine.available) {
//		
//		if (watch) {
//			// notify that the laundry is finsihed if watching
//			UILocalNotification *notification = [[UILocalNotification alloc] init];
//			notification.alertAction = @"laundry finished";
//			notification.alertBody = [NSString stringWithFormat:@"Your laundry is ready in machine %@ in the %@ laundry room!",cell.textLabel.text,self.room.name];
//			notification.fireDate = [NSDate date];
//			notification.applicationIconBadgeNumber = notification.applicationIconBadgeNumber-1;
//			
//			[[UIApplication sharedApplication] presentLocalNotificationNow:notification];
//			
//			// turn the switch off
//			//[switchView setOn:NO animated:YES];
//			//[[NSUserDefaults standardUserDefaults] setBool:switchView.on forKey:key];
//		}
//		
//	//check for cycle in progress status
//	} else if (machine.running || machine.extended) {
//		
//		
//	// check for cycle ended status
//	} else if (machine.ended){
//		
//		if (watch){
//			//cell.textLabel.textColor = [UIColor blackColor];
//			
//			// notify that the laundry is finsihed if watching
//			UILocalNotification *notification = [[UILocalNotification alloc] init];
//			notification.alertAction = @"laundry finished";
//			notification.alertBody = [NSString stringWithFormat:@"Your laundry is ready in machine %@ in the %@ laundry room!",cell.textLabel.text,self.room.name];
//			notification.fireDate = [NSDate date];
//			notification.applicationIconBadgeNumber = notification.applicationIconBadgeNumber-1;
//		
//			[[UIApplication sharedApplication] presentLocalNotificationNow:notification];
//
//			// turn the switch off
//			//[switchView setOn:NO animated:YES];
//			//[[NSUserDefaults standardUserDefaults] setBool:switchView.on forKey:key];
//			
//		}
//		
//		
//	}
	
    return cell;
}

//title the washer and dryer sections in the table
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
	if (section == 0) {
		return @"Washers";
	} else {
		return @"Dryers";
	}
}


- (IBAction)watch:(UIButton *)button{
	// Begin background fetching
	[[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
	
	NSInteger index = button.tag;
	
	
	
	// Watch the selected machine
	NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
	NSArray * watchData = [NSArray arrayWithObjects:self.room.ID, self.room.name, @(index), nil];
	[userDefaults setObject:watchData forKey:@"watch"];
	
	// Alert that the machine is being watched
	NSString * alertTitle = [NSString stringWithFormat:@"%@- Machine %@",self.room.name, [self.roomModel machineNameForIndex:index]];
	UIAlertView * watchAlert = [[UIAlertView alloc] initWithTitle:alertTitle
														  message:@"You'll get a notification when the cycle ends."
														 delegate:self
												cancelButtonTitle:@"Okay"
												otherButtonTitles: nil];
	[watchAlert show];

}

- (void)longPressCell{
	UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Machine" message:@"Watch this machine" delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
	[alert show];
}

// returns a unique key to associate with a switch for each machine
- (NSString *)keyForSwitchWithRoom:(NSString *)room andMachine:(NSString *)machine{
	return [room stringByAppendingString:machine];
}



- (IBAction)setDefaultRoom:(UIBarButtonItem *)sender {
	if([self.room isDefaultRoom]){
		[LaundryRoom setDefaultRoom:nil];
		self.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];
	} else{
		[LaundryRoom setDefaultRoom:self.room];
		self.navigationItem.rightBarButtonItem.tintColor = [UIColor colorWithRed:241/255.0
																		   green:196/255.0
																			blue:15/255.0
																		   alpha:1.0];
		UIAlertView *defaultChangedMessage = [[UIAlertView alloc] initWithTitle:self.room.name
																		message:@"Set as your laundry room."
																	   delegate:nil
															  cancelButtonTitle:@"Cancel"
															  otherButtonTitles: @"Okay", nil];
		[defaultChangedMessage show];
	}
}
@end
