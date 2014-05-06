//
//  LaundryRoom.m
//  Laundry
//
//  Created by Andrew Daniels on 2/27/14.
//  Copyright (c) 2014 Andrew Daniels. All rights reserved.
//

#import "LaundryRoom.h"
#import "LaundryMachine.h"
#import "HTMLParser.h"

@implementation LaundryRoom



- (LaundryRoom*)initWithID:(NSString*)roomID{
	self = [super init];
	
	self.ID = roomID;
	
	//construct URL
	NSString * urlString = @"http://classic.laundryview.com/laundry_room.php?lr=";
	NSString * urlWithIDString = [urlString stringByAppendingString:roomID];
	self.url = [NSURL URLWithString:urlWithIDString];
	

	[self getInfo];
	[self refresh];
	
	return self;
}


- (void)getInfo{
	NSError * error = nil;
	HTMLParser *roomParser = [[HTMLParser alloc] initWithContentsOfURL:self.url error:&error];
	HTMLNode *roomBody = [roomParser body];
	
	self.name = @"";
	self.campus = @"";
	
	NSArray *roomInfoHTML = [roomBody findChildrenWithAttribute:@"id" matchingName:@"monitor-head" allowPartial:NO];
	
	if (roomInfoHTML.count > 0) {
		NSArray *infoComponentsHTML = [[roomInfoHTML objectAtIndex:0] children];
		
		if (infoComponentsHTML.count > 1) {
			self.campus = [[infoComponentsHTML objectAtIndex:1] allContents];
			self.campus = [[self.campus stringByReplacingOccurrencesOfString:@" " withString:@""] uppercaseString];
			
			NSString * name = [[infoComponentsHTML objectAtIndex:3] allContents];
			
			name = [name stringByReplacingOccurrencesOfString:@"LAUNDRY ROOM" withString:@""];
			name = [name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
			
			// fix capitalization
			
			// string with numbers need special treament
			if ([name rangeOfCharacterFromSet:[NSCharacterSet decimalDigitCharacterSet]].location != NSNotFound) {
				name = [name capitalizedString];
				NSArray *nameTokens = [name componentsSeparatedByString:@" "];
				NSString *capitalizedWithNumbers = @"";
				
				for (int i = 0; i < nameTokens.count; i++) {
					NSString *token = [nameTokens objectAtIndex:i];
					// tokens with numbers are all lowercase, others have first letter capitalized
					if ([token rangeOfCharacterFromSet:[NSCharacterSet decimalDigitCharacterSet]].location != NSNotFound) {
						capitalizedWithNumbers = [capitalizedWithNumbers stringByAppendingString:[token lowercaseString]];
					} else{
						capitalizedWithNumbers = [capitalizedWithNumbers stringByAppendingString:[token capitalizedString]];
					}
					
					// insert a space between tokens
					capitalizedWithNumbers = [capitalizedWithNumbers stringByAppendingString:@" "];
				}
				
				name = capitalizedWithNumbers;
			} else{
				name = [name capitalizedString];
			}
			
			self.name = name;
		}
	}
}


- (void)refresh{
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
		} else if ([machineStatusString rangeOfString:@"extended"].length > 0){
			NSRange timeRange = [numberRegex firstMatchInString:machineStatusString
														options:NSMatchingWithTransparentBounds
														  range:[machineStatusString rangeOfString:machineStatusString]].range;
			if (timeRange.length > 0) {
				time = [numberFormatter numberFromString:[machineStatusString substringWithRange:timeRange]];
				machines[i] = [[LaundryMachine alloc] initExtendedCycleWithName:machineName time:time];
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
		} else {
			machines[i] = [[LaundryMachine alloc] initWithName:machineName];
		}
	}
	
	self.machines = machines;
}

// Formatted name string for a given machine index
- (NSString *)machineNameForIndex:(NSUInteger)index{
	return ((LaundryMachine *)[self.machines objectAtIndex:index]).name;
}

// Formatted status string for a given machine index
- (NSString *)machineStatusForIndex:(NSUInteger)index{
	//return [[self.machinesWithStatuses objectAtIndex:index] objectAtIndex:1];
	
	LaundryMachine * machine = [self.machines objectAtIndex:index];
	
	if(machine){
		if (machine.available) {
			return @"Available";
		} else if (machine.running){
			if(machine.time){
				return [NSString stringWithFormat:@"Running (%@ minutes left)", machine.time];
			} else {
				return @"Running";
			}
		} else if (machine.extended){
			if (machine.time) {
				return [NSString stringWithFormat:@"Extended cycle (%@ minutes ago)", machine.time];
			} else {
				return @"Extended cycle";
			}
			
		} else if (machine.ended) {
			if (machine.time) {
				return [NSString stringWithFormat:@"Ended (%@ minutes ago)", machine.time];
			} else {
				return @"Ended";
			}
		} else {
			return @"Could not retrieve machine status";
		}
	} else {
		return @"Could not retrieve machine status";
	}
}

// Status color for a given machine index
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




// *** Default Room utilities ***

+ (void)setDefaultRoom:(LaundryRoom *)room{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults setObject:[room infoArrayForRoom] forKey:@"defaultRoom"];
	
}

- (BOOL)isDefaultRoom{
	NSArray *defaultRoomInfo = [LaundryRoom defaultRoomInfo];
	
	if(defaultRoomInfo){
		NSString *defaultCampus = [defaultRoomInfo objectAtIndex:1];
		NSString *defaultID = [defaultRoomInfo objectAtIndex:2];
		
		return ([self.ID isEqualToString:defaultID] && [self.campus isEqualToString:defaultCampus]);
	} else {
		return false;
	}
}

+ (LaundryRoom *)defaultRoom{
	NSString *defaultID = [[LaundryRoom defaultRoomInfo] objectAtIndex:2];
	return [[LaundryRoom alloc] initWithID:defaultID];
}

+ (BOOL)defaultRoomSetForCampus:(NSString *)campus{
	NSArray *defaultRoomInfo = [LaundryRoom defaultRoomInfo];
	return defaultRoomInfo && [campus isEqualToString:defaultRoomInfo[1]];
}

+ (NSArray *)defaultRoomInfo{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	return [userDefaults stringArrayForKey:@"defaultRoom"];
}

- (NSArray *)infoArrayForRoom{
	return [NSArray arrayWithObjects:self.name, self.campus, self.ID, nil];
}
@end
