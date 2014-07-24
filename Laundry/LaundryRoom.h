//
//  LaundryRoom.h
//  Laundry
//
//  Created by Andrew Daniels on 2/27/14.
//  Copyright (c) 2014 Andrew Daniels. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LaundryRoom : NSObject

@property (nonatomic) NSURL *url;

@property (nonatomic) NSString *name;
@property (nonatomic) NSString *campus;
@property (nonatomic) NSString *ID;

@property (nonatomic) NSArray * machines;
@property (nonatomic) NSInteger numberOfWashers;
@property (nonatomic) NSInteger numberOfDryers;



// *** Core methods ***

- (LaundryRoom*)initWithID:(NSString*)roomID;
- (void)refresh;



// *** UI **

- (NSString *)machineNameForIndex:(NSUInteger)index;
- (NSString *)machineStatusForIndex:(NSUInteger)index;
- (UIColor *)tintColorForMachineWithIndex:(NSUInteger)index;
- (NSString *)machineTimeStatusForIndex:(NSUInteger)index;



// *** Default room ***

// Gets the default room
+ (LaundryRoom *)defaultRoom;

// Sets the default room
+ (void)setDefaultRoom:(LaundryRoom *)room;

// Returns true if there is a default room and it belongs to the current campus
+ (BOOL)defaultRoomSetForCampus:(NSString *)campus;

// Checks if a given room is the default room
- (BOOL)isDefaultRoom;

// Returns an array containing [name, ID]
- (NSArray *)infoArrayForRoom;
@end
