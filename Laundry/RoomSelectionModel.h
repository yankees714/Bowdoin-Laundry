//
//  RoomSelectionModel.h
//  Laundry
//
//  Created by Andrew Daniels on 10/25/13.
//  Copyright (c) 2013 Andrew Daniels. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RoomSelectionModel : NSObject
@property (nonatomic) NSURL *url;
@property (nonatomic) NSDictionary *idsForRooms;
@property (nonatomic) NSArray *rooms;

+ (RoomSelectionModel *)roomSelectionModel;
- (void)refreshRooms;
- (NSString *)idForRoom:(NSString *)roomName;
- (NSString *)roomForIndex:(NSUInteger)index;
- (NSUInteger)numberOfRooms;

@end
