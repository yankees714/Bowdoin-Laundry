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
@property (nonatomic) NSURL *url;
@property (nonatomic) NSInteger numberOfWashers;
@property (nonatomic) NSInteger numberOfDryers;


@property (nonatomic) NSArray * machines;

- (LaundryDataModel*)initWithID:(NSString*)roomID;

- (void)refreshLaundryData;

- (NSString *)machineNameForIndex:(NSUInteger)index;
- (NSString *)machineStatusForIndex:(NSUInteger)index;
- (UIColor *)tintColorForMachineWithIndex:(NSUInteger)index;

@end
