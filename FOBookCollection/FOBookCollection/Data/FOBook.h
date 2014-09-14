//
//  FOBook.h
//  FOBookCollection
//
//  Created by Fábio Daniel Pinto Martins de Oliveira on 14/09/14.
//  Copyright (c) 2014 Fábio Oliveira. All rights reserved.
//

#import "FOEntity.h"


@interface FOBook : FOEntity

@property (nonatomic, retain) NSString * author;
@property (nonatomic, retain) NSString * coverImageUrl;
@property (nonatomic, retain) NSString * isbn;
@property (nonatomic, retain) NSNumber * numberOfPages;
@property (nonatomic, retain) NSNumber * position;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * udid;
@property (nonatomic, retain) NSDecimalNumber * coverImageAspectRatio;

@end
