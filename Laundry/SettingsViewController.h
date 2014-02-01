//
//  SettingsViewController.h
//  Laundry
//
//  Created by Andrew Daniels on 2/1/14.
//  Copyright (c) 2014 Andrew Daniels. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsViewController : UIViewController
@property (weak, nonatomic) IBOutlet UISegmentedControl *levelChooser;
- (IBAction)levelSelected:(UISegmentedControl *)sender;

@end
