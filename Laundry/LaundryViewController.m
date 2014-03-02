//
//  LaundryViewController.m
//  Laundry
//
//  Created by Andrew Daniels on 9/12/13.
//  Copyright (c) 2013 Andrew Daniels. All rights reserved.
//

#import "LaundryViewController.h"
#import "LaundryDataModel.h"
#import "TestFlight.h"



@interface LaundryViewController ()
@end


@implementation LaundryViewController

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
	self.roomModel = [LaundryDataModel  laundryDataModelWithID:self.room.ID];
	
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
	
	// adjust index for section
	NSInteger index = (self.roomModel.numberOfWashers * (indexPath.section)) + indexPath.row;
	
	
	cell.textLabel.text = [self.roomModel machineForIndex:index];
	cell.detailTextLabel.text = [self.roomModel statusForIndex:index];
	
	// adding switch <- *change this to a button*
	//UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectZero];
//	UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(0, 8, 20, 20)];
//	
//	UIImage *shirt = [UIImage imageNamed:@"glyphicons_283_t-shirt.png"];
//	
//	[button setImage:shirt forState:UIControlStateNormal];
//	
//	cell.accessoryView = button;
	
	// handle the switch being toggled
	//[switchView addTarget:self action:@selector(watch:) forControlEvents:UIControlEventValueChanged];
	
	// check user defaults to see if user is watching this machine
	NSString *key = [self keyForSwitchWithRoom:self.room.name andMachine:cell.textLabel.text];
	BOOL watch = [[NSUserDefaults standardUserDefaults] boolForKey:key];
	//[switchView setOn:watch animated:NO];
	
	
	
	//get rid of the background color of text labels
	[[cell textLabel] setBackgroundColor:[UIColor clearColor]];
	[[cell detailTextLabel] setBackgroundColor:[UIColor clearColor]];
	
	// adjust detail color based on status
	// doing string contains check instead of equality just to be safe
	
	//check for machine available status
	if ([cell.detailTextLabel.text rangeOfString:@"available"].location != NSNotFound) {
		//cell.textLabel.textColor = [UIColor greenColor];
		cell.backgroundColor = [UIColor colorWithRed:46.0/255.0 green:204.0/255.0 blue:113.0/255.0 alpha:0.07];
		
		if (watch) {
			// notify that the laundry is finsihed if watching
			UILocalNotification *notification = [[UILocalNotification alloc] init];
			notification.alertAction = @"laundry finished";
			notification.alertBody = [NSString stringWithFormat:@"Your laundry is ready in machine %@ in the %@ laundry room!",cell.textLabel.text,self.room.name];
			notification.fireDate = [NSDate date];
			notification.applicationIconBadgeNumber = notification.applicationIconBadgeNumber-1;
			
			[[UIApplication sharedApplication] presentLocalNotificationNow:notification];
			
			// turn the switch off
			//[switchView setOn:NO animated:YES];
			//[[NSUserDefaults standardUserDefaults] setBool:switchView.on forKey:key];
		}
		
	//check for cycle in progress status
	} else if ([cell.detailTextLabel.text rangeOfString:@"time remaining"].location != NSNotFound ||
			   [cell.detailTextLabel.text rangeOfString:@"extended"].location != NSNotFound) {
		//cell.textLabel.textColor = [UIColor redColor];
		cell.backgroundColor = [UIColor colorWithRed:231.0/255.0 green:76.0/255.0 blue:60.0/255.0 alpha:0.07];
		
		
	// check for cycle ended status
	} else if ([cell.detailTextLabel.text rangeOfString:@"cycle ended"].location != NSNotFound){
		cell.backgroundColor = [UIColor colorWithRed:52.0/255.0 green:152.0/255.0 blue:219.0/255.0 alpha:0.07];
		
		if (watch){
			//cell.textLabel.textColor = [UIColor blackColor];
			
			// notify that the laundry is finsihed if watching
			UILocalNotification *notification = [[UILocalNotification alloc] init];
			notification.alertAction = @"laundry finished";
			notification.alertBody = [NSString stringWithFormat:@"Your laundry is ready in machine %@ in the %@ laundry room!",cell.textLabel.text,self.room.name];
			notification.fireDate = [NSDate date];
			notification.applicationIconBadgeNumber = notification.applicationIconBadgeNumber-1;
		
			[[UIApplication sharedApplication] presentLocalNotificationNow:notification];
			
			// turn the switch off
			//[switchView setOn:NO animated:YES];
			//[[NSUserDefaults standardUserDefaults] setBool:switchView.on forKey:key];
			
		}
		
		
	}
	
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


- (IBAction)watch:(UISwitch *)sender{
	NSString * machine = ((UITableViewCell *)sender.superview.superview).textLabel.text;
	NSString * key = [self keyForSwitchWithRoom:self.room.name andMachine:machine];
	[[NSUserDefaults standardUserDefaults] setBool:sender.on forKey:key];

	
	// test local notification - alerts whenever a room is selected
	//reference: https://developer.apple.com/library/ios/documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/Chapters/IPhoneOSClientImp.html#//apple_ref/doc/uid/TP40008194-CH103-SW1
	UILocalNotification *notification = [[UILocalNotification alloc] init];
	notification.alertAction = @"watching notification";
	notification.alertBody = [NSString stringWithFormat:@"Watching machine %@ in the %@ laundry room!",machine,self.room.name];
	notification.fireDate = [NSDate date];
	notification.applicationIconBadgeNumber = notification.applicationIconBadgeNumber+1;
	
	[[UIApplication sharedApplication] presentLocalNotificationNow:notification];
}

// returns a unique key to associate with a switch for each machine
- (NSString *)keyForSwitchWithRoom:(NSString *)room andMachine:(NSString *)machine{
	return [room stringByAppendingString:machine];
}



- (IBAction)setDefaultRoom:(UIBarButtonItem *)sender {
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	LaundryRoom *favoriteRoom = [LaundryRoom roomWithArray:[userDefaults stringArrayForKey:@"favoriteRoom"]];
	
	UIAlertView *defaultChangedMessage = [[UIAlertView alloc] initWithTitle:@"Default Laundry Room"
																	message:@""
																   delegate:nil
														  cancelButtonTitle:@"Okay"
														  otherButtonTitles: nil];
	
	if(favoriteRoom != nil && favoriteRoom.ID == self.room.ID){
		[userDefaults setObject:nil forKey:@"favoriteRoom"];
		defaultChangedMessage.message = @"This room is no longer set as your laundry room";
		
		self.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];
	} else{
		[userDefaults setObject:[self.room arrayForRoom] forKey:@"favoriteRoom"];
		defaultChangedMessage.message = @"Set this room as your laundry room!";
		

		self.navigationItem.rightBarButtonItem.tintColor = [UIColor colorWithRed:241/255.0
																		   green:196/255.0
																			blue:15/255.0
																		   alpha:1.0];
		[self.view setNeedsDisplay];
	}
	
	[defaultChangedMessage show];
}
@end
