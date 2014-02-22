//
//  LaundryDataModel.m
//  Laundry
//
//  Created by Andrew Daniels on 9/12/13.
//  Copyright (c) 2013 Andrew Daniels. All rights reserved.
//

#import "LaundryDataModel.h"
#import "HTMLParser.h"
#import "HTMLNode.h"

@implementation LaundryDataModel

+ (LaundryDataModel*)laundryDataModelWithID:(NSString*)roomID{
	LaundryDataModel * model = [[LaundryDataModel alloc] init];
	
	//construct URL
	NSString * urlString = @"http://classic.laundryview.com/laundry_room.php?lr=";
	NSString * urlWithIDString = [urlString stringByAppendingString:roomID];
	model.url = [NSURL URLWithString:urlWithIDString];
	
	
	[model refreshLaundryData];
	
	return model;
}

- (void)refreshLaundryData{
	//parser setup
	NSError * error = nil;
	
	HTMLParser *roomParser = [[HTMLParser alloc] initWithContentsOfURL:self.url error:&error];
	HTMLNode *roomBody = [roomParser body];

	
	// each section is within an element of this class
	NSString *sectionCSSClass = @"bgwhite";
	
	// each machine is in an element of this class
	NSString *machineCSSClass = @"bgdesc";
	
	// get the two sections
	NSArray *sections = [roomBody findChildrenOfClass:sectionCSSClass];
	
	// gets lists of the elements containing each machine
	NSArray *washers = [[sections objectAtIndex:0] findChildrenOfClass:machineCSSClass]; // washers are in the first section
	NSArray *dryers = [[sections objectAtIndex:1] findChildrenOfClass:machineCSSClass]; //dryers are in the second
	
	// number of machines == number of elements containing them
	self.numberOfWashers = washers.count;
	self.numberOfDryers = dryers.count;
	
	//get machines
	NSArray * machines = [roomBody findChildrenWithAttribute:@"class" matchingName:@"bgdesc" allowPartial:NO];
	
	
	//get statuses
	NSArray * stats = [roomBody findChildrenWithAttribute:@"class" matchingName:@"stat" allowPartial:NO];
	
	NSMutableArray * machinesWithStatuses = [[NSMutableArray alloc] initWithCapacity:stats.count];
	
	
	for (int i = 0; i < machines.count; i++) {
		NSString * machineNameString = [[[machines objectAtIndex:i] allContents] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		
		// remove a leading zero if present
		if ([machineNameString characterAtIndex:0] == '0') {
			machineNameString = [machineNameString substringFromIndex:1];
		}
		
		NSString * machineStatusString = [[[stats objectAtIndex:i] allContents] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		
		// array for holding a machine at index 0, status at index 1
		NSArray * machineWithStatus = [NSArray arrayWithObjects:machineNameString, machineStatusString, nil];
		
		[machinesWithStatuses addObject:machineWithStatus];
	}
	
	self.machinesWithStatuses = machinesWithStatuses;
}

// return the machine associated with a given index
- (NSString *)machineForIndex:(NSUInteger)index{
	return [[self.machinesWithStatuses objectAtIndex:index] objectAtIndex:0];
}

// return the status of the machine for a given index
- (NSString *)statusForIndex:(NSUInteger)index{
	return [[self.machinesWithStatuses objectAtIndex:index] objectAtIndex:1];
}
@end