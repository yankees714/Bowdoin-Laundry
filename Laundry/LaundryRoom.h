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

+ (LaundryRoom *)roomWithName:(NSString *)name andID:(NSString *) ID;

@end
