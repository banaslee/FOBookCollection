//
//  FOBooksService.h
//  FOBookCollection
//
//  Created by Fábio Daniel Pinto Martins de Oliveira on 14/09/14.
//  Copyright (c) 2014 Fábio Oliveira. All rights reserved.
//

@import Foundation;

#import "CoreData+MagicalRecord.h"

@class AFHTTPRequestOperationManager;

FOUNDATION_EXPORT NSString *const FOBooksServiceNotification;
FOUNDATION_EXPORT NSString *const FOServiceNotificationTypeKey;
FOUNDATION_EXPORT NSString *const FOServiceNotificationOperationKey;
FOUNDATION_EXPORT NSString *const FOServiceNotificationObjectsKey;
FOUNDATION_EXPORT NSString *const FOServiceNotificationTypeStart;
FOUNDATION_EXPORT NSString *const FOServiceNotificationTypeSuccess;
FOUNDATION_EXPORT NSString *const FOServiceNotificationTypeFail;

@interface FOBooksService : NSObject

+ (AFHTTPRequestOperationManager *)operationManagerWithBaseUrl:(NSURL*)baseUrl;
+ (void)requestBooksInCategory:(NSString *)categoryId withPageId:(NSInteger)pageId andPageSize:(NSInteger)pageSize inContext:(NSManagedObjectContext *)context;

- (instancetype)initWithOperationManager:(AFHTTPRequestOperationManager *)operationManager;
- (void)requestBooksInCategory:(NSString *)categoryId withPageId:(NSInteger)pageId andPageSize:(NSInteger)pageSize inContext:(NSManagedObjectContext *)context;
@end
