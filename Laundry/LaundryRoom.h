//
//  LaundryRoom.h
//  Laundry
//
//  Created by Andrew Daniels on 2/27/14.
//  Copyright (c) 2014 Andrew Daniels. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LaundryRoom : NSObject

@property (nonatomic) NSString *name;
@property (nonatomic) NSString *campus;
@property (nonatomic) NSString *ID;



// Returns an array containing [name, ID]
- (NSArray *)infoArrayForRoom;

// Checks if a given room is the default room
- (BOOL)isDefaultRoom;


// Sets the default room
+ (void)setDefaultRoom:(LaundryRoom *)room;

+ (BOOL)defaultRoomSetForCampus:(NSString *)campus;

+ (LaundryRoom *)defaultRoom;




@property (nonatomic) NSURL *url;
@property (nonatomic) NSInteger numberOfWashers;
@property (nonatomic) NSInteger numberOfDryers;


@property (nonatomic) NSArray * machines;

- (LaundryRoom*)initWithID:(NSString*)roomID;

- (void)refresh;

- (NSString *)machineNameForIndex:(NSUInteger)index;
- (NSString *)machineStatusForIndex:(NSUInteger)index;
- (UIColor *)tintColorForMachineWithIndex:(NSUInteger)index;

@end
