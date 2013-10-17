//
//  LaundryViewController.h
//  Laundry
//
//  Created by Andrew Daniels on 9/12/13.
//  Copyright (c) 2013 Andrew Daniels. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LaundryDataModel.h"

@interface LaundryViewController : UITableViewController

@property (strong, nonatomic) NSArray *machinesAndStatuses;
@property (nonatomic) LaundryDataModel * roomModel;
@property (weak, nonatomic) NSString *status;
@property (weak,nonatomic) NSString *roomID;
@property (weak, nonatomic) NSString *roomName;

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end
