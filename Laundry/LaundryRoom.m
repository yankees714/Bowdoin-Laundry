//
//  LaundryRoom.m
//  Laundry
//
//  Created by Andrew Daniels on 2/27/14.
//  Copyright (c) 2014 Andrew Daniels. All rights reserved.
//

#import "LaundryRoom.h"

@implementation LaundryRoom

+ (LaundryRoom *)roomWithName:(NSString *)name campus:(NSString *)campus ID:(NSString *) ID{
	LaundryRoom *room = [[LaundryRoom alloc] init];
	room.name = name;
	room.campus = campus;
	room.ID = ID;
	return room;
}

+ (LaundryRoom *)roomWithArray:(NSArray *)array{
	LaundryRoom *room = [[LaundryRoom alloc] init];
	
	if(array == nil){
		room.name = nil;
		room.campus= nil;
		room.ID = nil;
	} else{
		if(array.count > 0){
			room.name = array[0];
		} else{
			room.Name = nil;
		}
		
		if(array.count > 1) {
			room.campus = array[1];
		} else{
			room.campus = nil;
		}
		
		if(array.count > 2) {
			room.ID = array[2];
		} else{
			room.ID = nil;
		}
	}
	return room;
}

- (BOOL)isDefaultRoom{
	LaundryRoom *defaultRoom = [LaundryRoom defaultRoom];
	if(defaultRoom){
		return ([self.ID isEqualToString:defaultRoom.ID] && [self.campus isEqualToString:defaultRoom.campus]);
	} else {
		return false;
	}
}

+ (LaundryRoom *)defaultRoom{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	NSArray *roomArray = [userDefaults stringArrayForKey:@"favoriteRoom"];
	
	if (roomArray) {
		return [LaundryRoom roomWithArray:roomArray];
	} else {
		return nil;
	}	
}

+ (void)setDefaultRoom:(LaundryRoom *)room{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults setObject:[room arrayForRoom] forKey:@"favoriteRoom"];
	
}



- (NSArray *)arrayForRoom{
	return [NSArray arrayWithObjects:self.name, self.campus, self.ID, nil];
}

@end
