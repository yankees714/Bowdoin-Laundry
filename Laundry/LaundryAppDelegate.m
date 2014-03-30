//
//  LaundryAppDelegate.m
//  Laundry
//
//  Created by Andrew Daniels on 9/12/13.
//  Copyright (c) 2013 Andrew Daniels. All rights reserved.
//

#import "LaundryAppDelegate.h"
#import "LaundryDataModel.h"
#import "LaundryRoom.h"
#import "LaundryMachine.h"
#import "TestFlight.h"

@implementation LaundryAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
	
	// TestFlight integration
	[TestFlight takeOff:@"0e30d72c-712a-4da4-8f93-4f54be77360e"];
	
	// zero out the badge on launch
	[UIApplication sharedApplication].applicationIconBadgeNumber = 0;
	
	[[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
	
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
	// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
	// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{
	NSArray * watchData = [[NSUserDefaults standardUserDefaults] objectForKey:@"watch"];
	if(watchData){
		NSString * roomID = [watchData objectAtIndex:0];
		NSString * roomName = [watchData objectAtIndex:1];
		NSNumber * machineIndex = [watchData objectAtIndex:2];
		
		LaundryDataModel * model = [[LaundryDataModel alloc] initWithID:roomID];
		LaundryMachine * machine = [model.machines objectAtIndex:machineIndex.integerValue];
		
		if (machine.ended || machine.available) {
			// Clear watched machine
			[[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"watch"];
			
			UILocalNotification *notification = [[UILocalNotification alloc] init];
			notification.alertAction = @"laundry finished";
			notification.alertBody = [NSString stringWithFormat:@"Laundry finished! (Machine %@ in %@)", machine.name, roomName];
			notification.soundName = UILocalNotificationDefaultSoundName;
			notification.fireDate = [NSDate date];
			notification.applicationIconBadgeNumber = notification.applicationIconBadgeNumber-1;
			
			[[UIApplication sharedApplication] presentLocalNotificationNow:notification];
			
		}
		
		completionHandler(UIBackgroundFetchResultNewData);
	} else {
		completionHandler(UIBackgroundFetchResultNoData);
	}
	
	NSLog(@"Laundry fetched in background");

}

@end
