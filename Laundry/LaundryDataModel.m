//
//  LaundryDataModel.m
//  Laundry
//
//  Created by Andrew Daniels on 9/12/13.
//  Copyright (c) 2013 Andrew Daniels. All rights reserved.
//

#import "LaundryDataModel.h"
#import "LaundryMachine.h"
#import "HTMLParser.h"
#import "HTMLNode.h"


@implementation LaundryDataModel
- (LaundryDataModel*)initWithID:(NSString*)roomID{
	self = [super init];

	//construct URL
	NSString * urlString = @"http://classic.laundryview.com/laundry_room.php?lr=";
	NSString * urlWithIDString = [urlString stringByAppendingString:roomID];
	self.url = [NSURL URLWithString:urlWithIDString];
	
	
	[self refreshLaundryData];
	
	return self;
}

- (void)refreshLaundryData{
	//parser setup
	NSError * error = nil;
	
	HTMLParser *roomParser = [[HTMLParser alloc] initWithContentsOfURL:self.url error:&error];
	HTMLNode *roomBody = [roomParser body];
	
	NSRegularExpression * numberRegex = [NSRegularExpression regularExpressionWithPattern:@"\\d+"
																				  options:NSRegularExpressionCaseInsensitive
																					error:nil];
	NSNumberFormatter *numberFormatter  = [[NSNumberFormatter alloc] init];

	
	
	// each section is within an element of this class
	NSString *sectionCSSClass = @"bgwhite";
	
	// each machine is in an element of this class
	NSString *machineCSSClass = @"bgdesc";
	
	// get the two sections
	NSArray *sections = [roomBody findChildrenOfClass:sectionCSSClass];
	
	// gets lists of the elements containing each machine
	NSArray *washersHTML = [[sections objectAtIndex:0] findChildrenOfClass:machineCSSClass]; // washers are in the first section
	NSArray *dryersHTML = [[sections objectAtIndex:1] findChildrenOfClass:machineCSSClass]; //dryers are in the second
	
	//get machines
	NSArray * machinesHTML = [roomBody findChildrenWithAttribute:@"class" matchingName:@"bgdesc" allowPartial:NO];
	
	//get statuses
	NSArray * statusesHTML = [roomBody findChildrenWithAttribute:@"class" matchingName:@"stat" allowPartial:NO];
	
	
	
	// number of machines == number of elements containing them
	self.numberOfWashers = washersHTML.count;
	self.numberOfDryers = dryersHTML.count;
	
	NSMutableArray * machines = [[NSMutableArray alloc] initWithCapacity:machinesHTML.count];
	
	
	
	for (int i = 0; i < machinesHTML.count; i++) {
		// name of machine
		NSString * machineName = [[[machinesHTML objectAtIndex:i] allContents] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		
		if ([machineName characterAtIndex:0] == '0') {
			machineName = [machineName substringFromIndex:1];
		}
		
		// status of machine
		NSString * machineStatusString = [[[statusesHTML objectAtIndex:i] allContents] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		
		
		
		
		NSNumber * time;

		if ([machineStatusString rangeOfString:@"remaining"].length > 0) {
			NSRange timeRange = [numberRegex firstMatchInString:machineStatusString
									options:NSMatchingWithTransparentBounds
									  range:[machineStatusString rangeOfString:machineStatusString]].range;
			if(timeRange.length > 0){
				time = [numberFormatter numberFromString:[machineStatusString substringWithRange:timeRange]];
				
				machines[i] = [[LaundryMachine alloc] initRunningWithName:machineName time:time];
			}
		} else if ([machineStatusString rangeOfString:@"ended"].length > 0){
			NSRange timeRange = [numberRegex firstMatchInString:machineStatusString
														options:NSMatchingWithTransparentBounds
														  range:[machineStatusString rangeOfString:machineStatusString]].range;
			if(timeRange.length > 0){
				time= [numberFormatter numberFromString:[machineStatusString substringWithRange:timeRange]];
				machines[i] = [[LaundryMachine alloc] initEndedWithName:machineName time:time];
			}
		} else if ([machineStatusString rangeOfString:@"available"].length > 0){
			machines[i] = [[LaundryMachine alloc] initAvailableWithName:machineName];
		} else if ([machineStatusString rangeOfString:@"unknown"].length > 0){
			machines[i] = [[LaundryMachine alloc] initWithName:machineName];
		}
	}
	
	self.machines = machines;
}

// return the machine associated with a given index
- (NSString *)machineNameForIndex:(NSUInteger)index{
	return ((LaundryMachine *)[self.machines objectAtIndex:index]).name;
}

// return the status of the machine for a given index
- (NSString *)machineStatusForIndex:(NSUInteger)index{
	//return [[self.machinesWithStatuses objectAtIndex:index] objectAtIndex:1];
	
	LaundryMachine * machine = [self.machines objectAtIndex:index];
	
	if(machine){
		if (machine.available) {
			return @"Available";
		} else if (machine.running){
			return [NSString stringWithFormat:@"Running (%@ minutes left)", machine.time];
		} else if (machine.ended) {
			return [NSString stringWithFormat:@"Ended (%@ minutes ago)", machine.time];
		} else {
			return @"Could not retrieve machine status";
		}
	} else {
		return @"Could not retrieve machine status";
	}
}

- (UIColor *)tintColorForMachineWithIndex:(NSUInteger)index{
	
	UIColor * availableColor = [UIColor colorWithRed:0.87 green:1.00 blue:0.87 alpha:1.00];
	UIColor * runningColor = [UIColor colorWithRed:1.00 green:0.87 blue:0.87 alpha:1.00];
	UIColor * endedColor = [UIColor colorWithRed:52.0/255.0 green:152.0/255.0 blue:219.0/255.0 alpha:0.1];
	
	LaundryMachine * machine = [self.machines objectAtIndex:index];
	
	if(machine.available){
		return availableColor;
	} else if (machine.running || machine.extended){
		return runningColor;
	} else if (machine.ended){
		return endedColor;
	} else {
		return nil;
	}
}

@end