/**
 * Your Copyright Here
 *
 * Appcelerator Titanium is Copyright (c) 2009-2010 by Appcelerator, Inc.
 * and licensed under the Apache Public License (version 2)
 */
#import "TiCustomphotoalbumModule.h"
#import "TiBase.h"
#import "TiHost.h"
#import "TiUtils.h"

@implementation TiCustomphotoalbumModule

@synthesize library;

#pragma mark Internal

// this is generated for your module, please do not change it
-(id)moduleGUID
{
	return @"93c009b7-0181-4c60-9e55-da6a87667a61";
}

// this is generated for your module, please do not change it
-(NSString*)moduleId
{
	return @"ti.customphotoalbum";
}

#pragma mark Lifecycle

-(void)startup
{
	// this method is called when the module is first loaded
	// you *must* call the superclass
	[super startup];
	self.library = [[ALAssetsLibrary alloc] init];

	NSLog(@"[INFO] %@ loaded",self);
}

-(void)shutdown:(id)sender
{
	// this method is called when the module is being unloaded
	// typically this is during shutdown. make sure you don't do too
	// much processing here or the app will be quit forceably
	
	// you *must* call the superclass
    self.library = nil;
	[super shutdown:sender];
}

-(void)_addAssetURL:(NSURL *)assetURL
            toAlbum:(NSString *)albumName
       failureBlock:(ALAssetsLibraryAccessFailureBlock)failureBlock {
    __block BOOL albumWasFound = NO;
    
    
    NSLog(@"[INFO] %@ addAssetURL Function",self);
    
    //ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    
    
    
    ALAssetsLibraryGroupsEnumerationResultsBlock enumerationBlock;
    enumerationBlock = ^(ALAssetsGroup *group, BOOL *stop) {
        // compare the names of the albums
        if ([albumName compare:[group valueForProperty:ALAssetsGroupPropertyName]] == NSOrderedSame) {
            // target album is found
            albumWasFound = YES;
            
            // get a hold of the photo's asset instance
            [self.library assetForURL:assetURL
                          resultBlock:^(ALAsset *asset) {
                              // add photo to the target album
                              [group addAsset:asset];
                          }
                         failureBlock:failureBlock];
            
            // album was found, bail out of the method
            return;
        }
        
        if (group == nil && albumWasFound == NO) {
            // photo albums are over, target album does not exist, thus create it
            
            // Since you use the assets library inside the block,
            //   ARC will complain on compile time that there’s a retain cycle.
            //   When you have this – you just make a weak copy of your object.
            //
            //   __weak ALAssetsLibrary * weakSelf = self;
            //
            // by @Marin.
            //
            // I don't use ARC right now, and it leads a warning.
            // by @Kjuly
            ALAssetsLibrary * weakSelf = self.library;
            
            // if iOS version is lower than 5.0, throw a warning message
            if (! [self.library respondsToSelector:@selector(addAssetsGroupAlbumWithName:resultBlock:failureBlock:)]) {
                NSLog(@"![WARNING][LIB:ALAssetsLibrary+CustomPhotoAlbum]: \
                      |-addAssetsGroupAlbumWithName:resultBlock:failureBlock:| \
                      only available on iOS 5.0 or later. \
                      ASSET cannot be saved to album!");
            }
            // create new assets album
            else [self.library addAssetsGroupAlbumWithName:albumName
                                               resultBlock:^(ALAssetsGroup *group) {
                                                   // get the photo's instance
                                                   [weakSelf assetForURL:assetURL
                                                             resultBlock:^(ALAsset *asset) {
                                                                 // add photo to the newly created album
                                                                 [group addAsset:asset];
                                                             }
                                                            failureBlock:failureBlock];
                                               }
                                              failureBlock:failureBlock];
            
            // should be the last iteration anyway, but just in case
            return;
        }
    };
    
    // search all photo albums in the library
    [self.library enumerateGroupsWithTypes:ALAssetsGroupAlbum
                                usingBlock:enumerationBlock
                              failureBlock:failureBlock];
}


- (void)saveImage:(UIImage *)image
          toAlbum:(NSString *)albumName
  completionBlock:(ALAssetsLibraryWriteImageCompletionBlock)completionBlock
     failureBlock:(ALAssetsLibraryAccessFailureBlock)failureBlock {
    
    
    NSLog(@"[INFO] %@ saveImage Function",self);
    
    //ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    
    // write the image data to the assets library (camera roll)
    [self.library writeImageToSavedPhotosAlbum:image.CGImage
                                   orientation:(ALAssetOrientation)image.imageOrientation
                               completionBlock:^(NSURL *assetURL, NSError *error) {
                                   // run the completion block for writing image to saved
                                   //   photos album
                                   if (completionBlock) completionBlock(assetURL, error);
                                   
                                   // if an error occured, do not try to add the asset to
                                   //   the custom photo album
                                   if (error != nil)
                                       return;
                                   
                                   // add the asset to the custom photo album
                                   [self _addAssetURL:assetURL
                                              toAlbum:albumName
                                         failureBlock:failureBlock];
                               }];
}

#pragma mark Cleanup 

-(void)dealloc
{
	// release any resources that have been retained by the module
	[super dealloc];
}

#pragma mark Internal Memory Management

-(void)didReceiveMemoryWarning:(NSNotification*)notification
{
	// optionally release any resources that can be dynamically
	// reloaded once memory is available - such as caches
	[super didReceiveMemoryWarning:notification];
}

#pragma mark Listener Notifications

-(void)_listenerAdded:(NSString *)type count:(int)count
{
	if (count == 1 && [type isEqualToString:@"my_event"])
	{
		// the first (of potentially many) listener is being added 
		// for event named 'my_event'
	}
}

-(void)_listenerRemoved:(NSString *)type count:(int)count
{
	if (count == 0 && [type isEqualToString:@"my_event"])
	{
		// the last listener called for event named 'my_event' has
		// been removed, we can optionally clean up any resources
		// since no body is listening at this point for that event
	}
}

#pragma Public APIs

-(void)addCustomAlbumAndSaveImage:(id)args
{
    UIImage *Image = [TiUtils image:[args objectAtIndex:0] proxy:self];
    NSString *albumName = [args objectAtIndex:1];

    //completionBlock
    void (^completionBlock)(NSURL *, NSError *) = ^(NSURL *assetURL, NSError *error) {
        if (error) NSLog(@"!!!ERROR,  write the image data to the assets library (camera roll): %@",
                         [error description]);
        NSLog(@"*** URL %@ | %@ || type: %@ ***", assetURL, [assetURL absoluteString], [assetURL class]);
        // Add new one to |photos_|
        //[self.photos addObject:[assetURL absoluteString]];
        // Reload tableview data
        //[self.tableView reloadData];
    };
    
    //failureBlock
    void (^failureBlock)(NSError *) = ^(NSError *error) {
        if (error == nil) return;
        NSLog(@"!!!ERROR, failed to add the asset to the custom photo album: %@", [error description]);
    };
    
    
    [self saveImage:Image
            toAlbum:albumName
    completionBlock:completionBlock
       failureBlock:failureBlock];
}

@end
