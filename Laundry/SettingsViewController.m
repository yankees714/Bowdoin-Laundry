//
//  SettingsViewController.m
//  Laundry
//
//  Created by Andrew Daniels on 2/1/14.
//  Copyright (c) 2014 Andrew Daniels. All rights reserved.
//

#import "SettingsViewController.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	// set current watch level
	NSInteger watchLevel = [[NSUserDefaults standardUserDefaults]  integerForKey:@"level"];
	[self.levelChooser setSelectedSegmentIndex:watchLevel];
	
	
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)levelSelected:(UISegmentedControl *)sender {
	//store watch level
	[[NSUserDefaults standardUserDefaults] setInteger:[sender selectedSegmentIndex] forKey:@"level"];
}
@end
