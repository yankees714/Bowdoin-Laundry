//
//  RoomSelectionViewController.h
//  Laundry
//
//  Created by Andrew Daniels on 10/13/13.
//  Copyright (c) 2013 Andrew Daniels. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RoomSelectionModel.h"

@interface SelectionViewController : UITableViewController

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) RoomSelectionModel * roomSelection;

@property (nonatomic, assign) BOOL initialLoad;

@end
