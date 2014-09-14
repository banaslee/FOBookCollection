//
//  FOBooksService.m
//  FOBookCollection
//
//  Created by Fábio Daniel Pinto Martins de Oliveira on 14/09/14.
//  Copyright (c) 2014 Fábio Oliveira. All rights reserved.
//

#import "FOBooksService.h"

#import "FOBook+Custom.h"

#import "AFNetworking.h"

NSString *const FOBooksServiceNotification = @"FOBooksServiceNotification";

NSString *const FOServiceNotificationTypeKey = @"type";
NSString *const FOServiceNotificationOperationKey = @"operation";
NSString *const FOServiceNotificationObjectsKey = @"objects";

NSString *const FOServiceNotificationTypeStart = @"start";
NSString *const FOServiceNotificationTypeSuccess = @"success";
NSString *const FOServiceNotificationTypeFail = @"fail";

@interface FOBooksService ()
@property (nonatomic, strong) AFHTTPRequestOperationManager *operationManager;
@property (nonatomic, strong) AFHTTPRequestOperation *booksRequestOperation;
@end

@implementation FOBooksService

#pragma mark - Class methods
+ (instancetype)sharedInstance {
    static id gInstance = nil;
    static dispatch_once_t pred;
    
    dispatch_once(&pred, ^{
        gInstance = [[self alloc] init];
    });
    return (gInstance);
}

+ (void)requestBooksInCategory:(NSString *)categoryId withPageId:(NSInteger)pageId andPageSize:(NSInteger)pageSize inContext:(NSManagedObjectContext *)context {
    [[self sharedInstance] requestBooksInCategory:categoryId
                                       withPageId:pageId
                                      andPageSize:pageSize
                                        inContext:context];
}

#pragma mark - Instance methods
- (AFHTTPRequestOperationManager *)operationManager {
    if (!_operationManager) {
        _operationManager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:@"http://turbine-production-eu.herokuapp.com"]];
        _operationManager.requestSerializer = [[AFJSONRequestSerializer alloc] init];
        _operationManager.responseSerializer = [[AFJSONResponseSerializer alloc] init];
    }
    
    return _operationManager;
}

- (void)requestBooksInCategory:(NSString *)categoryId withPageId:(NSInteger)pageId andPageSize:(NSInteger)pageSize inContext:(NSManagedObjectContext *)context {
    if (self.booksRequestOperation) {
        [self.booksRequestOperation cancel];
    }
    
    self.booksRequestOperation = [self.operationManager GET:[NSString stringWithFormat:@"categories/%@/books", categoryId]
                                                 parameters:@{@"page": @(pageId),
                                                              @"per_page": @(pageSize)}
                                                    success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                        if ([responseObject isKindOfClass:[NSArray class]]) {
                                                            NSArray *bookDicts = responseObject;
                                                            if (pageId == 1) {
                                                                [FOBook MR_truncateAllInContext:context];
                                                            }
                                                            NSMutableArray *books = [NSMutableArray array];
                                                            for (int i=0; i < bookDicts.count; i++) {
                                                                NSDictionary *bookDict = bookDicts[i];
                                                                FOBook *book = [FOBook entityWithDictionary:bookDict
                                                                                                  inContext:context];
                                                                book.position = @(i+((pageId-1)*pageSize));
                                                                [books addObject:book];
                                                            }
                                                            
                                                            [[NSNotificationCenter defaultCenter] postNotificationName:FOBooksServiceNotification
                                                                                                                object:self
                                                                                                              userInfo:@{FOServiceNotificationTypeKey: FOServiceNotificationTypeSuccess,
                                                                                                                         FOServiceNotificationOperationKey: operation,
                                                                                                                         FOServiceNotificationObjectsKey: books}];
                                                        }
    }
                                                    failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                        [[NSNotificationCenter defaultCenter] postNotificationName:FOBooksServiceNotification
                                                                                                            object:self
                                                                                                          userInfo:@{FOServiceNotificationTypeKey: FOServiceNotificationTypeFail,FOServiceNotificationOperationKey: operation}];
    }];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:FOBooksServiceNotification
                                                        object:self
                                                      userInfo:@{FOServiceNotificationTypeKey: FOServiceNotificationTypeStart,
                                                                 FOServiceNotificationOperationKey: self.booksRequestOperation}];
}

@end
