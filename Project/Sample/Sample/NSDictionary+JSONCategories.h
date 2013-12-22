//
//  NSDictionary+JSONCategories.h
//  Sample
//
//  Created by Jurica Jurjevic on 23.12.13.
//  Copyright (c) 2013 real-prometheus. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary(JSONCategories)
+(NSDictionary*)dictionaryWithContentsOfJSONURLString:
(NSString*)urlAddress;
-(NSData*)toJSON;
@end
