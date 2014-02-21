//
//  RoomSelectionViewController.m
//  Laundry
//
//  Created by Andrew Daniels on 10/13/13.
//  Copyright (c) 2013 Andrew Daniels. All rights reserved.
//

#import "RoomSelectionViewController.h"
#import "LaundryViewController.h"
#import "RoomSelectionModel.h"
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
	
	self.tableView.delegate = self;
	self.tableView.dataSource = self;
	
	
	// set image for settings button on nav bar
	UIImage * gearsImage = [UIImage imageNamed:@"glyphicons_137_cogwheels.png"];
	UIImage * scaledGearsImage = [UIImage imageWithCGImage:[gearsImage CGImage] scale:1.25*gearsImage.scale orientation:gearsImage.imageOrientation];
	self.settingsBarButton.image = scaledGearsImage;
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
	
	if ([[Reachability reachabilityForLocalWiFi] currentReachabilityStatus] != ReachableViaWiFi) {
		UIAlertView * getOnWifi = [[UIAlertView alloc] initWithTitle:@"Please connect to WiFi."
															 message:@"Laundry is only available on Bowdoin's local Wifi network."
															delegate:nil
												   cancelButtonTitle:nil
												   otherButtonTitles:nil];
		[getOnWifi show];
	} else{
		self.roomSelection = [RoomSelectionModel roomSelectionModel];
	}
	

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

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue.destinationViewController className] isEqualToString:@"LaundryViewController"]){
		// Get the new view controller using [segue destinationViewController].
		LaundryViewController *laundryVC = [segue destinationViewController];
										
	
		// Pass the selected object to the new view controller.
	
		// get the index of the selected key
		NSInteger selected = [[self.tableView indexPathForSelectedRow] row];
	
		// get the room for the selected row
		NSString * room = [self.roomSelection roomForIndex:selected];
	
		laundryVC.roomName = room;
		laundryVC.roomID = [self.roomSelection idForRoom:room];
	}
}



@end
