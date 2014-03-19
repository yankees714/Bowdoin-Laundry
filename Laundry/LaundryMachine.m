//
//  LaundryMachine.m
//  Laundry
//
//  Created by Andrew Daniels on 3/18/14.
//  Copyright (c) 2014 Andrew Daniels. All rights reserved.
//

#import "LaundryMachine.h"

@implementation LaundryMachine

- (LaundryMachine *)initWithName:(NSString *)name{
	self = [super init];
	
	self.name = name;
	
	self.time = nil;
	
	self.available = NO;
	self.running = NO;
	self.extended = NO;
	self.ended = NO;
	
	return self;
}

- (LaundryMachine *)initAvailableWithName:(NSString *)name{
	self = [self initWithName:name];
	
	self.time = @(0);
	self.available = YES;
	
	return self;
}

- (LaundryMachine *)initExtendedCycleWithName:(NSString *)name time:(NSNumber*)time{
	self = [self initWithName:name];
	
	self.time = time;
	self.extended = YES;
	
	return self;
}

- (LaundryMachine *)initRunningWithName:(NSString *)name time:(NSNumber *)time{
	self = [self initWithName:name];
	
	self.time = time;
	self.running = YES;
	
	return self;
}

- (LaundryMachine *)initEndedWithName:(NSString *)name time:(NSNumber *)time{
	self = [self initWithName:name];
	
	self.time = time;
	self.ended = YES;
	
	return self;
}



@end
