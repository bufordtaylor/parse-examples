//
//  Translate.m
//  LanguageGame
//
//  Created by Buford Taylor on 4/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Translate.h"
#import "AppDelegate.h"
#import "NSFileManager+Tar.h"
#import <Parse/Parse.h>

@implementation Translate

+(void) checkForNewLocalizatableStringFiles {
    DLog(@"checking %@", [GameState getState].lastStringsUpdate);

    //Query parse for the class 'StringsFile'
    PFQuery *query = [PFQuery queryWithClassName:@"StringsFile"];
    [query whereKey:@"updatedAt" greaterThanOrEqualTo:[GameState getState].lastStringsUpdate];
    [query findObjectsInBackgroundWithBlock:^(NSArray* files, NSError *error) {

        // If no files to update, do nothing
        if ([files count] > 0) {

            //update the gamestate with the last update
            [GameState getState].lastStringsUpdate = [NSDate date];
            [GameState saveState];

            for (PFObject* fileObj in files) {

                //Retrieve file data for each file
                PFFile* file =  [fileObj objectForKey:@"file"];
                [file getDataInBackgroundWithBlock:^(NSData *result, NSError *error){
                    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                    NSString *documentsDirectory = [paths objectAtIndex:0];
                    NSError *error1;

                    [[NSFileManager defaultManager] createFilesAndDirectoriesAtPath:documentsDirectory withTarData:result error:&error1];
                } progressBlock:^(int percentDone) {
                    DLog(@"checking stringsfile percentDone %d", percentDone);
                }];

            }
        }
    }];
}


@end
