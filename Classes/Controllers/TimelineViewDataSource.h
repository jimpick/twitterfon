#import <UIKit/UIKit.h>
#import "ImageStore.h"
#import "Timeline.h"
#import "TwitterClient.h"
#import "LoadCell.h"

@interface TimelineViewDataSource : NSObject <UITableViewDataSource, UITableViewDelegate> {
    UITableViewController*  controller;
	Timeline*               timeline;
    ImageStore*             imageStore;
    LoadCell*               loadCell;
    MessageType             messageType;
    NSString*               query;
    float                   latitude, longitude;
    int                     distance;

    int                     insertPosition;
    uint64_t                since_id;
    CGPoint                 contentOffset;
    BOOL                    isRestored;
}

@property(nonatomic, readonly) Timeline* timeline;
@property(nonatomic, copy) NSString* query;
@property(nonatomic, assign) CGPoint contentOffset;

- (id)initWithController:(UITableViewController*)controller messageType:(MessageType)type;

- (void)getTimeline;
- (BOOL)searchSubstance:(BOOL)reload;
- (void)search:(NSString*)query;
- (void)geocode:(float)latitude longitude:(float)longitude distance:(int)distance;

- (void)removeAllMessages;

@end
