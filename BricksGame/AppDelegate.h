//
//  AppDelegate.h
//  BricksGame
//
//  Created by Nikunj Agrawal on 09/04/18.
//  Copyright © 2018 Nikunj Agrawal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;


@end

