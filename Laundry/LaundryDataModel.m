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
	NSURL * roomURL = [NSURL URLWithString:urlWithIDString];
	
	//parser setup
	NSError * error = nil;
	model.roomParser = [[HTMLParser alloc] initWithContentsOfURL:roomURL error:&error];
	model.roomBody = [model.roomParser body];
	
	
	// Determine number of washers and dryers
	
	// each section is within an element of this class
	NSString *sectionCSSClass = @"bgwhite";
	
	// each machine is in an element of this class
	NSString *machineCSSClass = @"bgdesc";
	
	// get the two sections
	NSArray *sections = [model.roomBody findChildrenOfClass:sectionCSSClass];
	
	// gets lists of the elements containing each machine
	NSArray *washers = [[sections objectAtIndex:0] findChildrenOfClass:machineCSSClass]; // washers are in the first section
	NSArray *dryers = [[sections objectAtIndex:1] findChildrenOfClass:machineCSSClass]; //dryers are in the second
	
	// number of machines == number of elements containing them
	model.numberOfWashers = washers.count;
	model.numberOfDryers = dryers.count;
	
	
	
	return model;
}

- (NSArray *)getLaundryData{
	
	
	HTMLNode * roomBody = [self.roomParser body];
	
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
		
		NSArray * machineWithStatus = [NSArray arrayWithObjects:machineNameString, machineStatusString, nil];
		
		[machinesWithStatuses addObject:machineWithStatus];
	}
	
	return machinesWithStatuses;
}
@end