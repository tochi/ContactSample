//
//  Contact.h
//  ContactSample
//
//  Created by 智行 栩平 on 12/06/12.
//  Copyright (c) 2012年 aguuu Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Contact : NSManagedObject

@property (nonatomic, retain) NSString * companyName;
@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSNumber * recordId;
@property (nonatomic, retain) NSNumber * deleteFlag;

@end
