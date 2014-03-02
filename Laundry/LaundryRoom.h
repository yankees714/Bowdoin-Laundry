//
//  LaundryRoom.h
//  Laundry
//
//  Created by Andrew Daniels on 2/27/14.
//  Copyright (c) 2014 Andrew Daniels. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LaundryRoom : NSObject

@property (nonatomic) NSString *ID;
@property (nonatomic) NSString *name;


// Create a room given a name and ID
+ (LaundryRoom *)roomWithName:(NSString *)name andID:(NSString *) ID;

// Create a room given an array of form [name, ID]
+ (LaundryRoom *)roomWithArray:(NSArray *)array;

// Returns an array containing [name, ID]
- (NSArray *)arrayForRoom;

// Checks if a given room is the default room
- (BOOL)isDefaultRoom;

@end
