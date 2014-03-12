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
	
	if(array == nil){
		room.name = nil;
		room.ID = nil;
	} else{
		if(array.count > 0){
			room.name = array[0];
		} else{
			room.Name = nil;
		}
		
		if(array.count > 1) {
			room.ID = array[1];
		} else{
			room.ID = nil;
		}
	}
	return room;
}

- (BOOL)isDefaultRoom{
	LaundryRoom *defaultRoom = [LaundryRoom roomWithArray:[[NSUserDefaults standardUserDefaults] stringArrayForKey:@"favoriteRoom"]];
	return [self.ID isEqualToString:defaultRoom.ID];
}



- (NSArray *)arrayForRoom{
	return [NSArray arrayWithObjects:self.name, self.ID, nil];
}

@end
