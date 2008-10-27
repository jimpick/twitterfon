//
//  SearchResultDataSource.m
//  TwitterFon
//
//  Created by kaz on 10/26/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import "TwitterFonAppDelegate.h"
#import "SearchResultDataSource.h"
#import "MessageCell.h"

@interface NSObject (SearchResultDataSourceDelegate)
- (void)searchDidLoad;
- (void)searchDidReceiveNewMessage:(Message*)message;
- (void)noSearchResult;
- (void)searchDidFailToLoad;
@end


@implementation SearchResultDataSource

- (id)initWithDelegate:(id)aDelegate
{
    [super init];
    timeline = [[Timeline alloc] initWithDelegate:self];
    delegate = aDelegate;

    TwitterFonAppDelegate *appDelegate = (TwitterFonAppDelegate*)[UIApplication sharedApplication].delegate;
    imageStore = appDelegate.imageStore;

    return self;
}

- (void)dealloc
{ 
    [timeline release];
    [super dealloc];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [timeline countMessages];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Message *m = [timeline messageAtIndex:indexPath.row];
    return m.cellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"MessageCell";
    
    MessageCell *cell = (MessageCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[MessageCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
    }
    cell.message = [timeline messageAtIndex:indexPath.row];
    [cell.profileImage setImage:[imageStore getImage:cell.message.user.profileImageUrl delegate:self] forState:UIControlStateNormal];
    cell.contentView.backgroundColor = [UIColor whiteColor];
    [cell update:0 delegate:self];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    [tableView deselectRowAtIndexPath:indexPath animated:TRUE]; 
}

- (void)removeAllResults
{
    [timeline removeAllMessages];
}

- (void)search:(NSString*)query
{ 
    [timeline removeAllMessages];
    
    TwitterClient *client = (TwitterClient*)[[TwitterClient alloc] initWithDelegate:self];
    [client initWithDelegate:self];
    [client search:query];
}

- (void)geocode:(float)latitude longitude:(float)longitude
{
    [timeline removeAllMessages];
    
    TwitterClient *client = (TwitterClient*)[[TwitterClient alloc] initWithDelegate:self];
    [client initWithDelegate:self];
    [client geocode:latitude longitude:longitude distance:5];
}

- (void)twitterClientDidSucceed:(TwitterClient*)sender messages:(NSObject*)obj
{
    if ([obj isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dic = (NSDictionary*)obj;
        
        NSArray *array = (NSArray*)[dic objectForKey:@"results"];
        
        if ([array count] == 0) {
            [delegate noSearchResult];
            return;
        }
        
        // Add messages to the timeline
        for (int i = [array count] - 1; i >= 0; --i) {
            Message* m = [Message messageWithSearchResult:[array objectAtIndex:i]];
            [timeline insertMessage:m];
            
            [imageStore getImage:m.user.profileImageUrl delegate:delegate];
        }
        
    }
    [delegate searchDidLoad];
    [sender autorelease];
}

- (void)twitterClientDidFail:(TwitterClient*)sender error:(NSString*)error detail:(NSString*)detail
{
    [delegate searchDidFailToLoad];
}


@end
