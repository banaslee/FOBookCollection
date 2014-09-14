//
//  FOBook+Custom.m
//  FOBookCollection
//
//  Created by Fábio Daniel Pinto Martins de Oliveira on 14/09/14.
//  Copyright (c) 2014 Fábio Oliveira. All rights reserved.
//

#import "FOBook+Custom.h"

@implementation FOBook (Custom)

+ (NSString *)entityKeyForID {
    return @"udid";
}

+ (NSString *)jsonKeyForID {
    return @"udid";
}

- (void)setValuesFromDictionary:(NSDictionary *)jsonDict {
    [super setValuesFromDictionary:jsonDict];
    
    NSURL *smallCoverImageUrl = [NSURL URLWithString:jsonDict[@"small_cover_image_url"]];
    NSString *pathExtension = smallCoverImageUrl.query;
    NSMutableArray *parameters = [pathExtension componentsSeparatedByString:@"&"].mutableCopy;
    for (NSString *parameter in parameters) {
        if ([parameter hasPrefix:[NSString stringWithFormat:@"%@=", IMAGE_SIZE_PARAMETER_NAME]]) {
            [parameters removeObject:parameter];
        }
    }
    NSString *newPathExtension = [parameters componentsJoinedByString:@"&"];
    self.coverImageUrl = [[smallCoverImageUrl absoluteString] stringByReplacingOccurrencesOfString:pathExtension withString:newPathExtension];
}

@end
