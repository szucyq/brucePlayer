
#import <UIKit/UIKit.h>
#import "WithTableViewController.h"

#import <MediaServerBrowserService/MediaServerBrowserService.h>
#import "ItemsViewController.h"

@class ServerContentViewController;
@class CGUpnpAvController;

@interface ServerViewController : WithTableViewController <MediaServerBrowserServiceDelegate>

@property (strong, nonatomic) ServerContentViewController *detailViewController;
@property (nonatomic, retain) NSArray* dataSource;
@property (nonatomic, retain) NSArray* renderers;
@property (nonatomic,retain) NSMutableDictionary* dmsArr;
@property (nonatomic, retain) CGUpnpAvController* avController;
@end
