//
//  RoomSelectionModel.m
//  Laundry
//
//  Created by Andrew Daniels on 10/25/13.
//  Copyright (c) 2013 Andrew Daniels. All rights reserved.
//

#import "RoomSelectionModel.h"
#import "HTMLParser.h"
#import "LaundryRoom.h"


@implementation RoomSelectionModel
+ (RoomSelectionModel *)roomSelectionModel{
	RoomSelectionModel * model = [[RoomSelectionModel alloc] init];
	
	model.url = [NSURL URLWithString:@"http://laundryview.com/lvs.php"];
	
	// need a first refresh to fill the list
	[model refreshRooms];

	if (model.roomIDs) {
		model.numberOfRooms = model.roomIDs.count;
	} else {
		model.numberOfRooms = 0;
	}

	return model;
}

// refreshes the  list of rooms from laundry view
- (void)refreshRooms{
	NSError *error = nil;
	HTMLParser *roomListParser = [[HTMLParser alloc] initWithContentsOfURL:self.url error:&error];
	HTMLNode *roomListBody = [roomListParser body];

	// "Click here to report a problem with a washer or dryer and/or a laundry room at BRANDEIS UNIVERSITY"
	NSString *campus = [[[roomListBody findChildrenOfClass:@"bg-yellow1"] objectAtIndex:1] allContents];
	campus = [campus stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	campus = [campus stringByTrimmingCharactersInSet:[NSCharacterSet punctuationCharacterSet]];
	
	// Grab last 2 words
	NSArray * components = [campus componentsSeparatedByString:@" "];
	campus = [[components objectAtIndex:components.count-2] stringByAppendingString:[components objectAtIndex:components.count-1]];
	
	self.campus = campus;
	
	
	
	// Room list
	NSArray *roomList = [roomListBody findChildrenWithAttribute:@"class" matchingName:@"a-room" allowPartial:NO];

	NSMutableArray *roomNames = [NSMutableArray arrayWithCapacity:roomList.count];
	NSMutableArray *roomIDs = [NSMutableArray arrayWithCapacity:roomList.count];
	
	for (int i = 0; i < roomList.count; i++) {
		NSString *roomName = @"";
		NSString *roomID = @"";
		
		// get room name and strip
		roomName = [[[roomList objectAtIndex:i] allContents] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		
		// fix capitalization
		
		// string with numbers need special treament
		if ([roomName rangeOfCharacterFromSet:[NSCharacterSet decimalDigitCharacterSet]].location != NSNotFound) {
			roomName = [roomName capitalizedString];
			NSArray *roomNameTokens = [roomName componentsSeparatedByString:@" "];
			NSString *capitalizedWithNumbers = @"";
			
			for (int i = 0; i < roomNameTokens.count; i++) {
				NSString *token = [roomNameTokens objectAtIndex:i];
				// tokens with numbers are all lowercase, others have first letter capitalized
				if ([token rangeOfCharacterFromSet:[NSCharacterSet decimalDigitCharacterSet]].location != NSNotFound) {
					capitalizedWithNumbers = [capitalizedWithNumbers stringByAppendingString:[token lowercaseString]];
				} else{
					capitalizedWithNumbers = [capitalizedWithNumbers stringByAppendingString:[token capitalizedString]];
				}
				
				// insert a space between tokens
				capitalizedWithNumbers = [capitalizedWithNumbers stringByAppendingString:@" "];
			}
			
			roomName = capitalizedWithNumbers;
		} else{
			roomName = [roomName capitalizedString];
		}
		
		[roomNames insertObject:roomName atIndex:i];
		
		// get room id
		NSString *roomLink = [[[roomList objectAtIndex:i] getAttributeNamed:@"href"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		NSArray *roomLinkComponents = [roomLink componentsSeparatedByString:@"lr="];
		roomID = [roomLinkComponents objectAtIndex:1];

		[roomIDs insertObject:roomID atIndex:i];
	}
	
	self.roomNames = roomNames;
	self.roomIDs = roomIDs;
}



- (LaundryRoom *)roomForIndex:(NSUInteger)index{
	return [[LaundryRoom alloc] initWithID:[self.roomIDs objectAtIndex:index]];
}

- (NSString *)roomNameForIndex:(NSUInteger)index{
	return [self.roomNames objectAtIndex:index];
}
@end
