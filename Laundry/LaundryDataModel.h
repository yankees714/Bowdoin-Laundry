//
//  LaundryDataModel.h
//  Laundry
//
//  Created by Andrew Daniels on 9/12/13.
//  Copyright (c) 2013 Andrew Daniels. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HTMLNode.h"

@interface LaundryDataModel : NSObject

@property (nonatomic) HTMLParser * roomParser;
@property (nonatomic) HTMLNode * roomBody;
@property (nonatomic) NSInteger numberOfWashers;
@property (nonatomic) NSInteger numberOfDryers;

+ (LaundryDataModel*)laundryDataModelWithID:(NSString*)roomID;
- (NSArray *)getLaundryData;
+ (NSDictionary *)getLaundryRooms;


@end
