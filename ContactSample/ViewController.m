//
//  ViewController.m
//  ContactSample
//
//  Created by 智行 栩平 on 12/06/07.
//  Copyright (c) 2012年 aguuu Inc. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"
#import "Contact.h"
#import "Contact+Customized.h"

@interface ViewController ()
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
void _addressBookChanged (ABAddressBookRef addressBook, CFDictionaryRef info, void *context);
@end

@implementation ViewController
@synthesize tableView = _tableView;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize fetchedResultsController = _fetchedResultsController;

- (NSManagedObjectContext *)managedObjectContext
{
  if (_managedObjectContext != nil) {
    return _managedObjectContext;
  }
  AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
  _managedObjectContext = appDelegate.managedObjectContext;
  return _managedObjectContext;
}

- (NSFetchedResultsController *)fetchedResultsController
{
  if (_fetchedResultsController != nil) {
    return _fetchedResultsController;
  }  
  NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
  fetchRequest.entity = [NSEntityDescription entityForName:@"Contact"
                                    inManagedObjectContext:self.managedObjectContext];
  NSSortDescriptor *sortDescriptorByFirstName = [NSSortDescriptor sortDescriptorWithKey:@"firstName"
                                                                              ascending:YES];
  NSSortDescriptor *sortDescriptorByLastName = [NSSortDescriptor sortDescriptorWithKey:@"lastName"
                                                                             ascending:YES];
  NSSortDescriptor *sortDescriptorByCompanyName = [NSSortDescriptor sortDescriptorWithKey:@"companyName"
                                                                                ascending:YES];
  NSSortDescriptor *sortDescriptorByRecordId = [NSSortDescriptor sortDescriptorWithKey:@"recordId"
                                                                             ascending:YES];
  fetchRequest.sortDescriptors = [NSArray arrayWithObjects:
                                  sortDescriptorByLastName,
                                  sortDescriptorByFirstName,
                                  sortDescriptorByCompanyName,
                                  sortDescriptorByRecordId,
                                  nil];
  
  NSFetchedResultsController *fetchedResultsController;
  fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                 managedObjectContext:self.managedObjectContext
                                                                   sectionNameKeyPath:nil
                                                                            cacheName:@"Contact"];
  self.fetchedResultsController = fetchedResultsController;
  return _fetchedResultsController;
}

/* -------------------------------------------------- */
#pragma mark - Initialized.
/* -------------------------------------------------- */
void _addressBookChanged (ABAddressBookRef addressBook, CFDictionaryRef info, void *context)
{
  ABAddressBookRevert(addressBook);
  ViewController *viewController = (__bridge_transfer ViewController *)context;
  [viewController _updateContact];
}

- (id)initWithCoder:(NSCoder *)coder
{
  self = [super initWithCoder:coder];
  if (self) {
    _addressBook = ABAddressBookCreate();
//    ABAddressBookRegisterExternalChangeCallback(_addressBook,
//                                                _addressBookChanged,
//                                                (__bridge_retained void *)self);
  }
  return self;
}

/* -------------------------------------------------- */
#pragma mark - View lifecycle.
/* -------------------------------------------------- */
- (void)viewDidLoad
{
  [super viewDidLoad];
  
  _activityIndicatorView = [[UIActivityIndicatorView alloc] init];
  _activityIndicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
  _activityIndicatorView.center = self.view.center;
}

- (void)viewDidUnload
{
  [self setTableView:nil];
  [super viewDidUnload];
}

/* -------------------------------------------------- */
#pragma mark - UITableView delegate.
/* -------------------------------------------------- */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return self.fetchedResultsController.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
  id <NSFetchedResultsSectionInfo> sectionInfo;
  sectionInfo = [self.fetchedResultsController.sections objectAtIndex:section];
  return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
  Contact *contact = [self.fetchedResultsController objectAtIndexPath:indexPath];
  cell.textLabel.text = contact.name;
  cell.detailTextLabel.text = contact.companyName;
  return cell;
}

/* -------------------------------------------------- */
#pragma mark - 
/* -------------------------------------------------- */
- (void)_updateContact
{
  dispatch_queue_t mainQueue = dispatch_get_main_queue();
  dispatch_queue_t updateQueue = dispatch_queue_create("com.aguuu.contactsample.update", nil);
  [_activityIndicatorView startAnimating];
  [self.view addSubview:_activityIndicatorView];
  
  dispatch_async(updateQueue, ^{
    // Update contacts.
    ABAddressBookRef addressBook = ABAddressBookCreate();
    CFArrayRef records = ABAddressBookCopyArrayOfAllPeople(addressBook);
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    static NSString *key = @"deleteFlag";
    [userDefaults registerDefaults:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES]
                                                               forKey:key]];
    BOOL deleteFlag = [userDefaults boolForKey:@"deleteFlag"];
    
    for (int i = 0; i < CFArrayGetCount(records); i++) {
      @autoreleasepool {
        ABRecordRef person = CFArrayGetValueAtIndex(records, i);
        NSNumber *recordId = [NSNumber numberWithInteger:ABRecordGetRecordID(person)];
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Contact"];
        request.predicate = [NSPredicate predicateWithFormat:@"recordId = %@", recordId];
        request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"recordId"
                                                                                         ascending:YES]];
        NSError *error = nil;
        NSArray *contacts = [self.managedObjectContext executeFetchRequest:request error:&error];
        if (error != nil) {
          NSLog(@"Error:%@", error);
          abort();
        }
        
        Contact *contact;
        if ([contacts count] == 1) {
          // Update contact
          contact = (Contact *)[contacts objectAtIndex:0];
        } else {
          // New contact
          contact = (Contact *)[NSEntityDescription insertNewObjectForEntityForName:@"Contact"
                                                             inManagedObjectContext:self.managedObjectContext]; 
        }
        contact.recordId = recordId;
        contact.deleteFlag = [NSNumber numberWithBool:!deleteFlag];
        
        NSString *firstName = (__bridge_transfer NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty);
        contact.firstName = firstName;
        
        NSString *lastName = (__bridge_transfer NSString *)ABRecordCopyValue(person, kABPersonLastNameProperty);
        contact.lastName = lastName;
        
        NSString *companyName = (__bridge_transfer NSString *)ABRecordCopyValue(person, kABPersonOrganizationProperty);
        contact.companyName = companyName;
      }
    }
    
    NSError *error = nil;
    if ([self.managedObjectContext save:&error] == NO) {
      NSLog(@"Error:%@", error);
      abort();
    }
    CFRelease(records);
    CFRelease(addressBook);
    
    // Delete contacts.
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Contact"];
    request.predicate = [NSPredicate predicateWithFormat:@"deleteFlag == %@",
                         [NSNumber numberWithBool:deleteFlag]];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"recordId"
                                                                                     ascending:YES]];
    error = nil;
    NSArray *contacts = [self.managedObjectContext executeFetchRequest:request error:&error];
    if (error != nil) {
      NSLog(@"Error:%@", error);
      abort();
    }
    for (Contact *contact in contacts) {
      [self.managedObjectContext deleteObject:contact];
    }
    error = nil;
    if ([self.managedObjectContext save:&error] == NO) {
      NSLog(@"Error:%@", error);
      abort();
    }
    [userDefaults setBool:!deleteFlag forKey:@"deleteFlag"];
    [userDefaults synchronize];
    
    dispatch_async(mainQueue, ^{      
      [_activityIndicatorView stopAnimating];
      [_activityIndicatorView removeFromSuperview];
      NSError *error = nil;
      if ([self.fetchedResultsController performFetch:&error] == NO) {
        NSLog(@"Error:%@", error);
        abort();
      }
      [self.tableView reloadData];
    });
  });
  dispatch_release(updateQueue);
}

@end
