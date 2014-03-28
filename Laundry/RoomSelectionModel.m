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

	return model;
}

// refreshes the  list of rooms from laundry view
- (void)refreshRooms{
	NSError *error = nil;
	HTMLParser *roomListParser = [[HTMLParser alloc] initWithContentsOfURL:self.url error:&error];
	
	
	HTMLNode *roomListBody = [roomListParser body];
	
	// School name
	HTMLNode *schoolInfo = [[roomListBody findChildrenWithAttribute:@"id" matchingName:@"right_col_hp_cont" allowPartial:NO] objectAtIndex:0];
	NSString *schoolName = [[schoolInfo findChildOfClass:@"h4"] allContents];
	schoolName = [[schoolName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] lowercaseString];
	
	NSLog(@"%@", schoolName);
	
	
	
	// Room list
	NSArray *roomList = [roomListBody findChildrenWithAttribute:@"class" matchingName:@"a-room" allowPartial:NO];
	
	NSMutableArray *roomNames = [NSMutableArray arrayWithCapacity:roomList.count];
	NSMutableArray *rooms = [NSMutableArray arrayWithCapacity:roomList.count];
	
	for (int i = 0; i < roomList.count; i++) {
		NSString *roomName, *roomID = @"";
		
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
		
		// get room id
		NSString *roomLink = [[[roomList objectAtIndex:i] getAttributeNamed:@"href"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		NSArray *roomLinkComponents = [roomLink componentsSeparatedByString:@"lr="];
		roomID = [roomLinkComponents objectAtIndex:1];
		//[roomIDs insertObject:roomID atIndex:i];
		
		
		[roomNames insertObject:roomName atIndex:i];
		[rooms insertObject:[LaundryRoom roomWithName:roomName campus:@"BOWDOIN COLLEGE"ID:roomID] atIndex:i];
	}
	
	// dictionary to retrieve a room given its name
	self.roomsForNames = [NSDictionary dictionaryWithObjects:rooms forKeys:roomNames];
	
	// list of room names, sorted
	self.roomNames = [roomNames sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
	
	
				  
}



- (LaundryRoom *)roomForIndex:(NSUInteger)index{
	return [self.roomsForNames valueForKey:[self.roomNames objectAtIndex:index]];
}

- (NSUInteger)numberOfRooms{
	return self.roomNames.count;
}
@end
