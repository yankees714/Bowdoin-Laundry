//
//  LaundryRoom.m
//  Laundry
//
//  Created by Andrew Daniels on 2/27/14.
//  Copyright (c) 2014 Andrew Daniels. All rights reserved.
//

#import "LaundryRoom.h"

@implementation LaundryRoom

+ (LaundryRoom *)laundryRoomWithName:(NSString *)name andID:(NSString *) ID{
	LaundryRoom *room = [[LaundryRoom alloc] init];
	room.name = name;
	room.ID = ID;
	return room;
}

@end
