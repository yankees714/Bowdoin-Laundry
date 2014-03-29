//
//  RoomSelectionModel.h
//  Laundry
//
//  Created by Andrew Daniels on 10/25/13.
//  Copyright (c) 2013 Andrew Daniels. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LaundryRoom.h"

@interface RoomSelectionModel : NSObject

@property (nonatomic) NSURL *url;
@property (nonatomic) NSString * campus;

@property (nonatomic) NSArray * roomNames;
@property (nonatomic) NSDictionary *roomsForNames;
@property (nonatomic) NSMutableDictionary *watching;

+ (RoomSelectionModel *)roomSelectionModel;

- (void)refreshRooms;

- (LaundryRoom *)roomForIndex:(NSUInteger)index;
- (NSUInteger)numberOfRooms;

@end
