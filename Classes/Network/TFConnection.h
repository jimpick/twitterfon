//
//  Connection.h
//  TwitterFon
//
//  Created by kaz on 7/25/08.
//  Copyright 2008 naan studio. All rights reserved.
//

extern NSString *TWITTERFON_FORM_BOUNDARY;

@interface TFConnection : NSObject
{
	id                  delegate;
    NSString*           requestURL;
	NSURLConnection*    connection;
    NSHTTPURLResponse*  response;
	NSMutableData*      buf;
    int                 statusCode;
    BOOL                needAuth;
}

@property (nonatomic, readonly) NSMutableData* buf;
@property (nonatomic, assign) int statusCode;
@property (nonatomic, copy) NSString* requestURL;

- (id)initWithDelegate:(id)delegate;
- (void)get:(NSString*)URL;
- (void)post:(NSString*)aURL body:(NSString*)body;
- (void)post:(NSString*)aURL data:(NSData*)data;
- (void)cancel;

- (void)TFConnectionDidFailWithError:(NSError*)error;
- (void)TFConnectionDidFinishLoading:(NSString*)content;

@end
