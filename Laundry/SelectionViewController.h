//
//  RoomSelectionViewController.h
//  Laundry
//
//  Created by Andrew Daniels on 10/13/13.
//  Copyright (c) 2013 Andrew Daniels. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RoomSelectionModel.h"
#import "Reachability.h"

@interface SelectionViewController : UITableViewController

@property (nonatomic) UIColor * laundryBlue;

@property (nonatomic, retain) Reachability *reachability;

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) RoomSelectionModel * roomSelection;

@property (nonatomic) NSInteger numberOfRooms;

@property (nonatomic, assign) BOOL initialLoad;

@end
