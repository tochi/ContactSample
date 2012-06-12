//
//  AppDelegate.m
//  ContactSample
//
//  Created by 智行 栩平 on 12/06/07.
//  Copyright (c) 2012年 aguuu Inc. All rights reserved.
//

#import "AppDelegate.h"
#import <CoreData/CoreData.h>
#import "ViewController.h"

@interface AppDelegate ()
@property (strong, nonatomic, readonly) NSManagedObjectModel *managedObjectModel;
@property (strong, nonatomic, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
- (NSURL *)applicationDocumentsDirectory;
@end

@implementation AppDelegate
@synthesize window = _window;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  ViewController *viewController = (ViewController *)self.window.rootViewController;
  [viewController _updateContact];
  return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
}

/* -------------------------------------------------- */
#pragma mark - CoreData stack.
/* -------------------------------------------------- */
- (NSManagedObjectContext *)managedObjectContext
{
  if (_managedObjectContext != nil) {
    return _managedObjectContext;
  }
  
  NSPersistentStoreCoordinator *coordinator = self.persistentStoreCoordinator;
  if (coordinator != nil) {
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
  }
  return _managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel
{
  if (_managedObjectModel != nil) {
    return _managedObjectModel;
  }
  NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"ContactSample" withExtension:@"momd"];
  _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
  return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
  if (_persistentStoreCoordinator != nil) {
    return _persistentStoreCoordinator;
  }
  
  NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"ContactSample.sqlite"];
  NSError *error = nil;
  _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
  if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                 configuration:nil
                                                           URL:storeURL
                                                       options:nil
                                                         error:&error]) {
    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    abort();
  }    
  
  return _persistentStoreCoordinator;
}    

- (NSURL *)applicationDocumentsDirectory
{
  return [[[NSFileManager defaultManager] URLsForDirectory:NSLibraryDirectory
                                                 inDomains:NSUserDomainMask] lastObject];
}

@end
