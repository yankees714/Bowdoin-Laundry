//
//  RoomSelectionModel.m
//  Laundry
//
//  Created by Andrew Daniels on 10/25/13.
//  Copyright (c) 2013 Andrew Daniels. All rights reserved.
//

#import "RoomSelectionModel.h"
#import "HTMLParser.h"


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
	NSArray *roomList = [roomListBody findChildrenWithAttribute:@"class" matchingName:@"a-room" allowPartial:NO];
	
	NSMutableArray *rooms = [NSMutableArray arrayWithCapacity:roomList.count];
	NSMutableArray *roomIDs = [NSMutableArray arrayWithCapacity:roomList.count];
	
	for (int i = 0; i < roomList.count; i++) {
		// get room name and strip
		NSString * roomName = [[[roomList objectAtIndex:i] allContents] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		
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
		
		
		
		[rooms insertObject:roomName atIndex:i];
		
		
		
		// get room id
		NSString *roomLink = [[[roomList objectAtIndex:i] getAttributeNamed:@"href"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		NSArray *roomLinkComponents = [roomLink componentsSeparatedByString:@"lr="];
		NSString *roomID = [roomLinkComponents objectAtIndex:1];
		[roomIDs insertObject:roomID atIndex:i];
	}
	
	// dictionary to retrieve the id for a given room
	self.idsForRooms = [NSDictionary dictionaryWithObjects:roomIDs forKeys:rooms];
	// sort list of rooms
	self.rooms = [[self.idsForRooms allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
}

- (NSString *)idForRoom:(NSString *)roomName{
	return [self.idsForRooms valueForKey:roomName];
}

- (NSString *)roomForIndex:(NSUInteger)index{
	return [self.rooms objectAtIndex:index];
}

- (NSUInteger)numberOfRooms{
	return self.rooms.count;
}


@end
