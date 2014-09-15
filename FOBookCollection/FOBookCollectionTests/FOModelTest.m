//
//  FOModelTest.m
//  FOBookCollection
//
//  Created by Fábio Daniel Pinto Martins de Oliveira on 15/09/14.
//  Copyright (c) 2014 Fábio Oliveira. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "FOBook+Custom.h"
#import "FOBooksService.h"

#import "CoreData+MagicalRecord.h"

@interface FOModelTest : XCTestCase

@end

@implementation FOModelTest

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

- (void)testMapping {
    NSString *author = @"author";
    NSString *title = @"title";
    NSString *udid = @"udid";
    NSString *isbn = @"isbn";
    
    FOBook *book = [FOBook MR_createEntity];
    
    [book setValuesFromDictionary:@{@"author": author,
                                   @"title": title,
                                   @"udid": udid,
                                   @"isbn": isbn}];
    XCTAssert([book.author isEqualToString:author], @"Pass");
    XCTAssert([book.title isEqualToString:title], @"Pass");
    XCTAssert([book.udid isEqualToString:udid], @"Pass");
    XCTAssert([book.isbn isEqualToString:isbn], @"Pass");
}

- (void)testImageURLSizing {
    NSString *smallUrl = @"http://something.com/books?fit=TRUE&w=250";
    NSString *udid = @"udid";
    
    FOBook *book = [FOBook MR_createEntity];
    
    [book setValuesFromDictionary:@{@"small_cover_image_url": smallUrl,
                                    @"udid": udid}];
    CGSize targetSize = CGSizeMake(500, 100);
    NSURL *sizedUrl = [FOBook imageURLWithString:book.coverImageUrl forSize:targetSize];
    UIWindow *mainWindow = [[[UIApplication sharedApplication] windows] firstObject];
    CGFloat finalWidth = targetSize.width * mainWindow.screen.scale;
    
    XCTAssert(![book.coverImageUrl hasSuffix:@"250"], @"Pass");
    XCTAssert([sizedUrl.absoluteString hasSuffix:@(finalWidth).description], @"Pass");
}

@end
