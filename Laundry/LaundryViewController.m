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
	
	//interface setup
	self.navigationItem.title = self.roomName;
	
	[self.refreshControl addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
	
	self.roomModel = [LaundryDataModel  laundryDataModelWithID:self.roomID];
	
	self.tableView.delegate = self;
	self.tableView.dataSource = self;
	
	
	// test local notification - alerts whenever a room is selected
	//reference: https://developer.apple.com/library/ios/documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/Chapters/IPhoneOSClientImp.html#//apple_ref/doc/uid/TP40008194-CH103-SW1
	UILocalNotification *notification = [[UILocalNotification alloc] init];
	notification.alertAction = @"test notification";
	notification.alertBody = [NSString stringWithFormat:@"Selected the %@ laundry room",self.roomName];
	notification.fireDate = [NSDate date];
	notification.applicationIconBadgeNumber = 1;
	
	
	[[UIApplication sharedApplication] presentLocalNotificationNow:notification];
	
	
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
	self.machinesAndStatuses = [self.roomModel getLaundryData];
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	
	[self.tableView reloadData];
	
}

- (void)refreshView:(UIRefreshControl *)sender {
	[self updateMachinesAndStatus];
	
	NSLog(@"%@", self.machinesAndStatuses);
	
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
	
	// adding switch
	UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectZero];
	cell.accessoryView = switchView;
	[switchView setOn:NO animated:NO];
	
	//little trick for adjustment
	NSInteger index = (self.roomModel.numberOfWashers * (indexPath.section)) + indexPath.row;
	
	cell.textLabel.text = [[self.machinesAndStatuses objectAtIndex:index] objectAtIndex:0];
	cell.detailTextLabel.text = [[self.machinesAndStatuses objectAtIndex:index] objectAtIndex:1];
	
	// adjust detail color based on status
	// doing string contains check instead of equality just to be safe
	if ([cell.detailTextLabel.text rangeOfString:@"available"].location != NSNotFound) {
		cell.textLabel.textColor = [UIColor greenColor];
	} else if ([cell.detailTextLabel.text rangeOfString:@"time remaining"].location != NSNotFound) {
		cell.textLabel.textColor = [UIColor redColor];
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



@end
