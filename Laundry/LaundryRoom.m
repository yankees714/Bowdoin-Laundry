//
//  LaundryRoom.m
//  Laundry
//
//  Created by Andrew Daniels on 2/27/14.
//  Copyright (c) 2014 Andrew Daniels. All rights reserved.
//

#import "LaundryRoom.h"

@implementation LaundryRoom

+ (LaundryRoom *)roomWithName:(NSString *)name andID:(NSString *) ID{
	LaundryRoom *room = [[LaundryRoom alloc] init];
	room.name = name;
	room.ID = ID;
	return room;
}

+ (LaundryRoom *)roomWithArray:(NSArray *)array{
	LaundryRoom *room = [[LaundryRoom alloc] init];
	room.name = array[0];
	room.ID = array[1];
	return room;
}



- (NSArray *)arrayForRoom{
	return [NSArray arrayWithObjects:self.name, self.ID, nil];
}

@end
