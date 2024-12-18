//
//  XMLReader.m
//  PRIME
//
//  Created by Davit on 8/24/16.
//  Copyright © 2016 XNTrends. All rights reserved.
//

#import "XMLReader.h"

NSString* const kXMLReaderTextNodeKey = @"text";

@interface XMLReader () {
    NSMutableArray* _dictionaryStack;
    NSMutableString* _textInProgress;
    NSError* __autoreleasing* _errorPointer;
}

@end

@interface XMLReader (Internal)

- (id)initWithError:(NSError**)error;
- (NSDictionary*)objectWithData:(NSData*)data;

@end

@implementation XMLReader

#pragma mark -
#pragma mark Public methods

+ (NSDictionary*)dictionaryForXMLData:(NSData*)data error:(NSError**)error
{
    XMLReader* reader = [[XMLReader alloc] initWithError:error];
    NSDictionary* rootDictionary = [reader objectWithData:data];
    return rootDictionary;
}

+ (NSDictionary*)dictionaryForXMLString:(NSString*)string error:(NSError**)error
{
    NSData* data = [string dataUsingEncoding:NSUTF8StringEncoding];
    return [XMLReader dictionaryForXMLData:data error:error];
}

#pragma mark -
#pragma mark Parsing

- (id)initWithError:(NSError**)error
{
    if (self = [super init]) {
        _errorPointer = error;
    }
    return self;
}

- (NSDictionary*)objectWithData:(NSData*)data
{
    _dictionaryStack = [[NSMutableArray alloc] init];
    _textInProgress = [[NSMutableString alloc] init];

    // Initialize the stack with a fresh dictionary.
    [_dictionaryStack addObject:[NSMutableDictionary dictionary]];

    // Parse the XML.
    NSXMLParser* parser = [[NSXMLParser alloc] initWithData:data];
    parser.delegate = self;
    BOOL success = [parser parse];

    // Return the stack’s root dictionary on success.
    if (success) {
        NSDictionary* resultDict = [_dictionaryStack objectAtIndex:0];
        return resultDict;
    }

    return nil;
}

#pragma mark -
#pragma mark NSXMLParserDelegate methods

- (void)parser:(NSXMLParser*)parser didStartElement:(NSString*)elementName namespaceURI:(NSString*)namespaceURI qualifiedName:(NSString*)qName attributes:(NSDictionary*)attributeDict
{
    // Get the dictionary for the current level in the stack.
    NSMutableDictionary* parentDict = [_dictionaryStack lastObject];

    // Create the child dictionary for the new element, and initilaize it with the attributes.
    NSMutableDictionary* childDict = [NSMutableDictionary dictionary];
    [childDict addEntriesFromDictionary:attributeDict];

    // If there’s already an item for this key, it means we need to create an array.
    id existingValue = [parentDict objectForKey:elementName];
    if (existingValue) {
        NSMutableArray* array = nil;
        if ([existingValue isKindOfClass:[NSMutableArray class]]) {
            // The array exists, so use it.
            array = (NSMutableArray*)existingValue;
        }
        else {
            // Create an array if it doesn’t exist.
            array = [NSMutableArray array];
            [array addObject:existingValue];

            // Replace the child dictionary with an array of children dictionaries.
            [parentDict setObject:array forKey:elementName];
        }

        // Add the new child dictionary to the array.
        [array addObject:childDict];
    }
    else {
        // No existing value, so update the dictionary.
        [parentDict setObject:childDict forKey:elementName];
    }

    // Update the stack.
    [_dictionaryStack addObject:childDict];
}

- (void)parser:(NSXMLParser*)parser didEndElement:(NSString*)elementName namespaceURI:(NSString*)namespaceURI qualifiedName:(NSString*)qName
{
    // Update the parent dict with text info.
    NSMutableDictionary* dictInProgress = [_dictionaryStack lastObject];

    // Set the text property.
    if ([_textInProgress length] > 0) {
        // Get rid of leading + trailing whitespace.
        [dictInProgress setObject:_textInProgress forKey:kXMLReaderTextNodeKey];

        // Reset the text.
        _textInProgress = [[NSMutableString alloc] init];
    }

    // Pop the current dict.
    [_dictionaryStack removeLastObject];
}

- (void)parser:(NSXMLParser*)parser foundCharacters:(NSString*)string
{
    // Build the text value.
    [_textInProgress appendString:string];
}

- (void)parser:(NSXMLParser*)parser parseErrorOccurred:(NSError*)parseError
{
    // Set the error pointer to the parser’s error object
    *_errorPointer = parseError;
}

@end
