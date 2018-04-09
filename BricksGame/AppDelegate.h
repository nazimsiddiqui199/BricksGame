//
//  AppDelegate.h
//  BricksGame
//
//  Created by Nazim Siddiqui on 09/04/18.
//  Copyright © 2018 Nazim Siddiqui. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;


@end

