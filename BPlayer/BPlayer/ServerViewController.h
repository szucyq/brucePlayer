
#import <UIKit/UIKit.h>
#import "WithTableViewController.h"

#import <MediaServerBrowserService/MediaServerBrowserService.h>
#import "ItemsViewController.h"

#import "TestTableViewController.h"

@interface ServerViewController : WithTableViewController <MediaServerBrowserServiceDelegate>


@property (nonatomic, retain) NSArray* dataSource;
@property (nonatomic, retain) NSArray* renderers;
@property (nonatomic,retain) NSMutableDictionary* dmsArr;

@end
