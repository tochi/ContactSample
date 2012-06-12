//
//  Contact+Customized.m
//  ContactSample
//
//  Created by 智行 栩平 on 12/06/08.
//  Copyright (c) 2012年 aguuu Inc. All rights reserved.
//

#import "Contact+Customized.h"

@implementation Contact (Customized)
- (NSString *)name
{
  NSMutableString *name = [NSMutableString stringWithFormat:@"%@ ", self.recordId];
  if (self.lastName != nil) {
    [name appendString:self.lastName];
  }
  if (self.firstName != nil) {
    [name appendString:self.firstName];
  }
  return name;;
}

@end
