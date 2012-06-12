//
//  ViewController.h
//  ContactSample
//
//  Created by 智行 栩平 on 12/06/07.
//  Copyright (c) 2012年 aguuu Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>

@interface ViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
{
@private
  ABAddressBookRef _addressBook;
  UIActivityIndicatorView *_activityIndicatorView;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
- (void)_updateContact;
@end
