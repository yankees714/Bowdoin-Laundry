//
//  LaundryViewController.m
//  Laundry
//
//  Created by Andrew Daniels on 9/12/13.
//  Copyright (c) 2013 Andrew Daniels. All rights reserved.
//

#import "LaundryViewController.h"
#import "LaundryDataModel.h"

@interface LaundryViewController ()

@end

@implementation LaundryViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	
	self.tableView.delegate = self;
	self.tableView.dataSource = self;
	
	//interface setup
	self.navigationItem.title = self.roomName;
	
	[self.refreshControl addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
	
	self.roomModel = [LaundryDataModel  laundryDataModelWithID:self.roomID];
	
	//set up updates and begin
	[NSTimer scheduledTimerWithTimeInterval:30.0 target:self selector:@selector(updateMachinesAndStatus) userInfo:nil repeats:YES];
	[self updateMachinesAndStatus];
	
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
	
	// test local notification - alerts whenever a room is selected
	//reference: https://developer.apple.com/library/ios/documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/Chapters/IPhoneOSClientImp.html#//apple_ref/doc/uid/TP40008194-CH103-SW1
	UILocalNotification *notification = [[UILocalNotification alloc] init];
	notification.alertAction = @"refresh notification";
	notification.alertBody = [NSString stringWithFormat:@"Refreshed data for %@ laundry room!",self.roomName];
	notification.fireDate = [NSDate date];
	notification.applicationIconBadgeNumber = notification.applicationIconBadgeNumber+1;
	
	[[UIApplication sharedApplication] presentLocalNotificationNow:notification];	
}

- (void)refreshView:(UIRefreshControl *)sender {
	[self updateMachinesAndStatus];
	
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
	UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(0, 8, 20, 20)];
	
	UIImage *shirt = [UIImage imageNamed:@"glyphicons_283_t-shirt.png"];
	
	[button setImage:shirt forState:UIControlStateNormal];
	
	cell.accessoryView = button;
	
	// handle the switch being toggled
	//[switchView addTarget:self action:@selector(watch:) forControlEvents:UIControlEventValueChanged];
	
	// check user defaults to see if user is watching this machine
	NSString *key = [self keyForSwitchWithRoom:self.roomName andMachine:cell.textLabel.text];
	BOOL watch = [[NSUserDefaults standardUserDefaults] boolForKey:key];
	//[switchView setOn:watch animated:NO];
	
	
	
	// adjust detail color based on status
	// doing string contains check instead of equality just to be safe
	//check for machine available status
	if ([cell.detailTextLabel.text rangeOfString:@"available"].location != NSNotFound) {
		cell.textLabel.textColor = [UIColor greenColor];
		
		
		if (watch) {
			// notify that the laundry is finsihed if watching
			UILocalNotification *notification = [[UILocalNotification alloc] init];
			notification.alertAction = @"laundry finished";
			notification.alertBody = [NSString stringWithFormat:@"Your laundry is ready in machine %@ in the %@ laundry room!",cell.textLabel.text,self.roomName];
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
		cell.textLabel.textColor = [UIColor redColor];
	// check for cycle ended status
	} else if ([cell.detailTextLabel.text rangeOfString:@"cycle ended"].location != NSNotFound){
		if (watch){
			cell.textLabel.textColor = [UIColor blackColor];
			
			// notify that the laundry is finsihed if watching
			UILocalNotification *notification = [[UILocalNotification alloc] init];
			notification.alertAction = @"laundry finished";
			notification.alertBody = [NSString stringWithFormat:@"Your laundry is ready in machine %@ in the %@ laundry room!",cell.textLabel.text,self.roomName];
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
	NSString * key = [self keyForSwitchWithRoom:self.roomName andMachine:machine];
	[[NSUserDefaults standardUserDefaults] setBool:sender.on forKey:key];

	
	// test local notification - alerts whenever a room is selected
	//reference: https://developer.apple.com/library/ios/documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/Chapters/IPhoneOSClientImp.html#//apple_ref/doc/uid/TP40008194-CH103-SW1
	UILocalNotification *notification = [[UILocalNotification alloc] init];
	notification.alertAction = @"watching notification";
	notification.alertBody = [NSString stringWithFormat:@"Watching machine %@ in the %@ laundry room!",machine,self.roomName];
	notification.fireDate = [NSDate date];
	notification.applicationIconBadgeNumber = notification.applicationIconBadgeNumber+1;
	
	[[UIApplication sharedApplication] presentLocalNotificationNow:notification];
}

// returns a unique key to associate with a switch for each machine
- (NSString *)keyForSwitchWithRoom:(NSString *)room andMachine:(NSString *)machine{
	return [room stringByAppendingString:machine];
}



@end
