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
	
	[self.tableView setRowHeight:100];
	[self.tableView setSeparatorInset:UIEdgeInsetsMake(0, 10, 0, 10)];
		
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
	self.room = [[LaundryRoom  alloc] initWithID:self.room.ID];
	
	
	// Set up alert views
	NSString * alertTitle = [NSString stringWithFormat:@"%@- Machine ",self.room.name];
	self.watchAlert = [[UIAlertView alloc] initWithTitle:alertTitle
														  message:@"You'll get a notification when the cycle ends."
														 delegate:self
												cancelButtonTitle:@"Okay"
												otherButtonTitles: nil];
	
	
	
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
	[self.room refresh];
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
		return self.room.numberOfWashers;
	} else {
		return self.room.numberOfDryers;
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	// Get cell
	static NSString * cellIdentifier = @"machineStatus";
    
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
	
	// Calculate index from index path
	NSInteger index = (self.room.numberOfWashers * (indexPath.section)) + indexPath.row;
	
	// Tag cell with index for access by long press recognizer
	cell.tag = index;
	
	
	
	
	// Set up the cell
	cell.textLabel.text = [NSString stringWithFormat:@"%@ – %@", [self.room machineNameForIndex:index], [self.room machineStatusForIndex:index]];
	cell.detailTextLabel.text = [self.room machineTimeStatusForIndex:index];
	
	cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:20.0];
	cell.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:12.0];

	//cell.textLabel.textColor = [UIColor whiteColor];
	
	[[cell textLabel] setBackgroundColor:[UIColor clearColor]];
	[[cell detailTextLabel] setBackgroundColor:[UIColor clearColor]];
	
	//cell.backgroundColor = [self.room tintColorForMachineWithIndex:index];
	
	int radius = 15;
	cell.imageView.image = [RoomViewController imageWithColor:[self.room tintColorForMachineWithIndex:index] size:CGSizeMake(radius, radius)];
	cell.imageView.layer.cornerRadius = radius/2;
	cell.imageView.layer.masksToBounds = YES;
	
	LaundryMachine * machine = [self.room.machines objectAtIndex:index];
	
	if (machine.running || machine.extended) {
		UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGesture:)];
		longPress.minimumPressDuration = 0.7;
		[cell addGestureRecognizer:longPress];
	} else {
		cell.gestureRecognizers = nil;
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

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
	return 40;
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
	NSString * alertTitle = [NSString stringWithFormat:@"%@- Machine %@",self.room.name, [self.room machineNameForIndex:index]];
	UIAlertView * watchAlert = [[UIAlertView alloc] initWithTitle:alertTitle
														  message:@"You'll get a notification when the cycle ends."
														 delegate:self
												cancelButtonTitle:@"Okay"
												otherButtonTitles: nil];
	[watchAlert show];

}

- (void)handleLongPressGesture:(UIGestureRecognizer *)gestureRecognizer{
	UITableViewCell * cell = (UITableViewCell *)gestureRecognizer.view;
	
	// Indicate that the machine is being watched
//	UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(300,100, 100, 100)];
//	label.text = @"Watching!";
//	cell.accessoryView  = label;
	
	// this is great, but need to handle saving the watched state, and resetting each cell's circle
	cell.imageView.layer.borderColor = [UIColor yellowColor].CGColor;
	cell.imageView.layer.borderWidth = 3.0;
	[cell.imageView setNeedsDisplay];
	
	
	
	NSInteger index = gestureRecognizer.view.tag;
	
	
	
	// ** Should be moved to model **
	// Watch the selected machine
	NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
	NSArray * watchData = [NSArray arrayWithObjects:self.room.ID, self.room.name, @(index), nil];
	[userDefaults setObject:watchData forKey:@"watch"];
	
	
	
	// Alert that the machine is being watched
	NSString * alertTitle = [NSString stringWithFormat:@"%@ - Machine %@",self.room.name, [self.room machineNameForIndex:index]];
	self.watchAlert.title  = alertTitle;
	
	//[self.watchAlert show];
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


// source: http://codely.wordpress.com/2013/02/04/how-to-make-a-solid-color-uiimage/
+ (UIImage*) imageWithColor:(UIColor*)color size:(CGSize)size
{
	UIGraphicsBeginImageContext(size);
	UIBezierPath* rPath = [UIBezierPath bezierPathWithRect:CGRectMake(0., 0., size.width, size.height)];
	[color setFill];
	[rPath fill];
	UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return image;
}
@end
