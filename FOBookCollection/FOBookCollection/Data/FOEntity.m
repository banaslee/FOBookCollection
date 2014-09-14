//
//  FOEntity.m
//  FOBookCollection
//
//  Created by Fábio Daniel Pinto Martins de Oliveira on 14/09/14.
//  Copyright (c) 2014 Fábio Oliveira. All rights reserved.
//

#import "FOEntity.h"

#import "CoreData+MagicalRecord.h"

@implementation FOEntity

#pragma mark - Class methods
+ (NSString *)entityKeyForID {
    return @"id";
}

+ (NSString *)jsonKeyForID {
    return @"id";
}

+ (NSString *)convertFromCamelCase:(NSString *)camelCaseString withSeparatorString:(NSString *)separatorString {
    NSMutableString *str2 = [NSMutableString string];
    
    for (NSInteger i=0; i < camelCaseString.length; i++){
        NSString *ch = [camelCaseString substringWithRange:NSMakeRange(i, 1)];
        if ([ch rangeOfCharacterFromSet:[NSCharacterSet uppercaseLetterCharacterSet]].location != NSNotFound) {
            [str2 appendString:separatorString];
        }
        [str2 appendString:ch];
    }
    
    return str2.lowercaseString;
}

+ (instancetype)entityWithDictionary:(id)JSON inContext:(NSManagedObjectContext *)context {
    NSDictionary *jsonDict;
    id idNumber;
    NSString *entityIdKey = [self entityKeyForID];
    NSString *jsonIdKey = [self jsonKeyForID];
    
    if ([JSON isKindOfClass:[NSDictionary class]]) {
        jsonDict = JSON;
        idNumber = jsonDict[jsonIdKey];
    }
    else if ([JSON isKindOfClass:[NSNumber class]]) {
        idNumber = JSON;
    }
    else {
        return nil;
    }
    
    FOEntity *entity = nil;
    
    NSEntityDescription *entityDescription = [[self class] MR_entityDescriptionInContext:context];
    NSDictionary *attributes = [entityDescription attributesByName];
    if (idNumber && attributes[entityIdKey]) {
        entity = [self MR_findFirstByAttribute:entityIdKey
                                     withValue:idNumber
                                     inContext:context];
    }
    
    if (![idNumber isKindOfClass:[NSNull class]]) {
        if (!entity)
            entity = [self MR_createInContext:context];
        
        if (jsonDict) {
            [entity setValuesFromDictionary:jsonDict];
        }
        else {
            [entity setValue:idNumber forKey:jsonIdKey];
        }
    }
    
    return entity;
}

+ (NSURL *)imageURLWithString:(NSString *)string forSize:(CGSize)size {
    if ([string.lastPathComponent rangeOfString:@"."].location == NSNotFound) {
        NSString *urlStringWithSize = [string stringByAppendingFormat:@"&=%@%d", IMAGE_SIZE_PARAMETER_NAME, (int)(size.width * [[UIScreen mainScreen] scale])];
        
        return [NSURL URLWithString:urlStringWithSize];
    }
    else {
        return [NSURL URLWithString:string];
    }
}

#pragma mark - Instance methods
- (void)setValuesFromDictionary:(NSDictionary*)jsonDict {
    NSEntityDescription *entity = [self entity];
    NSDictionary *attributes = [entity attributesByName];
    
    NSTimeInterval timestamp = 0;
    
    for(NSString *attributeKey in attributes){
        NSAttributeDescription *attribute = attributes[attributeKey];
        
        id value = jsonDict[attribute.name];
        if (!value) {
            value = jsonDict[[FOEntity convertFromCamelCase:attribute.name withSeparatorString:@"-"]];
            
            if (!value) {
                value = jsonDict[[FOEntity convertFromCamelCase:attribute.name withSeparatorString:@"_"]];
            }
        }
        
        if(value != nil && ![value isKindOfClass:[NSNull class]]){
            switch ([attribute attributeType]) {
                case NSBooleanAttributeType:
                case NSInteger16AttributeType:
                case NSInteger32AttributeType:
                case NSInteger64AttributeType:
                case NSDoubleAttributeType:
                case NSStringAttributeType:
                case NSDecimalAttributeType:
                    if([attributeKey isEqualToString:[[self class] entityKeyForID]] && [value isKindOfClass:[NSString class]] && [attribute attributeType] != NSStringAttributeType) {
                        value = @([value longLongValue]);
                    }
                    [self setValue:value forKey:attributeKey];
                    break;
                case NSDateAttributeType:
                    timestamp = [value longLongValue];
                    [self setValue:[NSDate dateWithTimeIntervalSince1970:timestamp] forKey:attributeKey];
                    break;
                default:
                    break;
            }
        }
    }
    
    if (![[[self class] entityKeyForID] isEqualToString:[[self class] jsonKeyForID]]) {
        [self setValue:jsonDict[[[self class] jsonKeyForID]] forKey:[[self class] entityKeyForID]];
    }
}

@end
