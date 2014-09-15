//
//  FOBookServiceTests.m
//  FOBookCollection
//
//  Created by Fábio Daniel Pinto Martins de Oliveira on 15/09/14.
//  Copyright (c) 2014 Fábio Oliveira. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "FOBooksService.h"

@interface AFHTTPRequestOperation : NSObject
@property (nonatomic, getter=isFinished) BOOL finished;
@property (nonatomic, getter=isExecuting) BOOL executing;
@property (nonatomic, getter=isCancelled) BOOL cancelled;
@end

@implementation AFHTTPRequestOperation

@end

@interface AFHTTPRequestOperationManager : NSObject
@property (nonatomic) BOOL failureMode;
@end

@implementation AFHTTPRequestOperationManager

- (AFHTTPRequestOperation *)GET:(NSString *)URLString
                     parameters:(id)parameters
                        success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                        failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] init];
    operation.executing = YES;
    operation.finished = NO;
    operation.cancelled = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        operation.executing = NO;
        operation.finished = YES;
        if (!self.failureMode) {
            success(operation, @[@{@"author": @"author",
                                   @"title": @"title",
                                   @"udid": @"udid",
                                   @"isbn": @"isbn",
                                   @"coverImageAspectRatio": @(.6f)}]);
        }
        else {
            failure(operation, nil);
        }
    });
    
    return operation;
}

@end

@interface FOBookServiceTests : XCTestCase
@property (nonatomic) BOOL didReceiveStartNotification;
@end

@implementation FOBookServiceTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    [MagicalRecord setupAutoMigratingCoreDataStack];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    [MagicalRecord cleanUp];
}

- (void)testSuccessfulResponse {
    AFHTTPRequestOperationManager *operationManager = [[AFHTTPRequestOperationManager alloc] init];
    operationManager.failureMode = NO;
    FOBooksService *service = [[FOBooksService alloc] initWithOperationManager:operationManager];
    
    self.didReceiveStartNotification = NO;
    [self expectationForNotification:FOBooksServiceNotification object:service handler:^BOOL(NSNotification *notification) {
        if ([notification.name isEqualToString:FOBooksServiceNotification]) {
            if ([notification.userInfo[FOServiceNotificationTypeKey] isEqualToString:FOServiceNotificationTypeStart]) {
                self.didReceiveStartNotification = YES;
                return YES;
            }
        }
        return NO;
    }];
    [self expectationForNotification:FOBooksServiceNotification object:service handler:^BOOL(NSNotification *notification) {
        if ([notification.name isEqualToString:FOBooksServiceNotification]) {
            if ([notification.userInfo[FOServiceNotificationTypeKey] isEqualToString:FOServiceNotificationTypeSuccess]) {
                return self.didReceiveStartNotification;
            }
        }
        return NO;
    }];
    [service requestBooksInCategory:@"category"
                         withPageId:1
                        andPageSize:23
                          inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
    
    [self waitForExpectationsWithTimeout:5.f
                                 handler:^(NSError *error) {
                                     XCTAssertNil(error, @"Pass");
    }];
}

- (void)testFailureResponse {
    AFHTTPRequestOperationManager *operationManager = [[AFHTTPRequestOperationManager alloc] init];
    operationManager.failureMode = YES;
    FOBooksService *service = [[FOBooksService alloc] initWithOperationManager:operationManager];
    
    self.didReceiveStartNotification = NO;
    [self expectationForNotification:FOBooksServiceNotification object:service handler:^BOOL(NSNotification *notification) {
        if ([notification.name isEqualToString:FOBooksServiceNotification]) {
            if ([notification.userInfo[FOServiceNotificationTypeKey] isEqualToString:FOServiceNotificationTypeStart]) {
                self.didReceiveStartNotification = YES;
                return YES;
            }
        }
        return NO;
    }];
    [self expectationForNotification:FOBooksServiceNotification object:service handler:^BOOL(NSNotification *notification) {
        if ([notification.name isEqualToString:FOBooksServiceNotification]) {
            if ([notification.userInfo[FOServiceNotificationTypeKey] isEqualToString:FOServiceNotificationTypeFail]) {
                return self.didReceiveStartNotification;
            }
        }
        return NO;
    }];
    [service requestBooksInCategory:@"category"
                         withPageId:1
                        andPageSize:23
                          inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
    
    [self waitForExpectationsWithTimeout:5.f
                                 handler:^(NSError *error) {
                                     XCTAssertNil(error, @"Pass");
                                 }];
}

@end
