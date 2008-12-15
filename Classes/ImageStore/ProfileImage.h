#import <UIKit/UIKit.h>
#import <sqlite3.h>
#import "User.h"

@interface ProfileImage : NSObject
{
  	NSMutableArray*     delegates;
	UIImage*            image;
    sqlite3*            database;
    NSString*           url;
    BOOL                isLoading;
}

@property(nonatomic, readonly) UIImage* image;
@property(nonatomic, readonly) BOOL isLoading; 

- (ProfileImage*)initWithURL:(NSString*)url;
- (void)addDelegate:(id)delegate;

@end
