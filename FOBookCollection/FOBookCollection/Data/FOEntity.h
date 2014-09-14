//
//  FOEntity.h
//  FOBookCollection
//
//  Created by Fábio Daniel Pinto Martins de Oliveira on 14/09/14.
//  Copyright (c) 2014 Fábio Oliveira. All rights reserved.
//

@import Foundation;
@import UIKit;
@import CoreData;

#define IMAGE_SIZE_PARAMETER_NAME @"w"

@interface FOEntity : NSManagedObject
+ (instancetype)entityWithDictionary:(id)JSON inContext:(NSManagedObjectContext *)context;

+ (NSURL *)imageURLWithString:(NSString *)string forSize:(CGSize)size;

- (void)setValuesFromDictionary:(NSDictionary*)jsonDict;
@end
