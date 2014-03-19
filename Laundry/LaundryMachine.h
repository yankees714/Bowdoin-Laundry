//
//  LaundryMachine.h
//  Laundry
//
//  Created by Andrew Daniels on 3/18/14.
//  Copyright (c) 2014 Andrew Daniels. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LaundryMachine : NSObject

@property NSString * name;

@property NSNumber * time;

@property bool available;
@property bool running;
@property bool extended;
@property bool ended;


- (LaundryMachine *)initWithName:(NSString *)name;
- (LaundryMachine *)initAvailableWithName:(NSString *)name;
- (LaundryMachine *)initExtendedCycleWithName:(NSString *)name time:(NSNumber*)time;
- (LaundryMachine *)initRunningWithName:(NSString *)name time:(NSNumber *)time;
- (LaundryMachine *)initEndedWithName:(NSString *)name time:(NSNumber *)time;


@end
