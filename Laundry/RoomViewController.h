//
//  RoomViewController.h
//  Laundry
//
//  Created by Andrew Daniels on 9/12/13.
//  Copyright (c) 2013 Andrew Daniels. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LaundryRoom.h"


@interface RoomViewController : UITableViewController


@property (strong, nonatomic) LaundryRoom *room;
@property (weak, nonatomic) NSString *status;



@property (strong, nonatomic) UIAlertView *watchAlert;

@property (strong, nonatomic) IBOutlet UITableView *tableView;
- (IBAction)setDefaultRoom:(UIBarButtonItem *)sender;

@end
