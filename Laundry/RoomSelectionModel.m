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

	NSMutableArray *rooms = [NSMutableArray arrayWithCapacity:roomList.count];
	
	for (int i = 0; i < roomList.count; i++) {
		NSString *roomID = @"";
		
		// get room id
		NSString *roomLink = [[[roomList objectAtIndex:i] getAttributeNamed:@"href"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		NSArray *roomLinkComponents = [roomLink componentsSeparatedByString:@"lr="];
		roomID = [roomLinkComponents objectAtIndex:1];
		//[roomIDs insertObject:roomID atIndex:i];
		
		
		//[roomNames insertObject:roomName atIndex:i];
		[rooms insertObject:[[LaundryRoom alloc] initWithID:roomID] atIndex:i];
	}
	
	self.rooms = rooms;

}



- (LaundryRoom *)roomForIndex:(NSUInteger)index{
	return [self.rooms objectAtIndex:index];
}

- (NSUInteger)numberOfRooms{
	return self.rooms.count;
}
@end
