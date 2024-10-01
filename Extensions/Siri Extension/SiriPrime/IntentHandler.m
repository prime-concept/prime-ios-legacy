//
//  IntentHandler.m
//  SiriPrime
//
//  Created by Hamlet on 10/25/18.
//  Copyright © 2018 XNTrends. All rights reserved.
//

#import "IntentHandler.h"
#import "SendMessageIntentHandler.h"

// As an example, this class is set up to handle Message intents.
// You will want to replace this or add other intents as appropriate.
// The intents you wish to handle must be declared in the extension's Info.plist.

// You can test your example integration by saying things to Siri like:
// "Send a message using <myApp>"
// "<myApp> John saying hello"
// "Search for messages in <myApp>"

@interface IntentHandler ()

@end

@implementation IntentHandler

- (id)handlerForIntent:(INIntent *)intent {

    if([intent isKindOfClass:[INSendMessageIntent class]]) {
        return [[SendMessageIntentHandler alloc] init];
    }
    return nil;
}

@end
