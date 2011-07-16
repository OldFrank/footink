//
//  UIImageView+AsyncAndCache.m
//
//  Created by Yongho Ji on 10. 12. 3..
//  Copyright 2010 Wecon Communications. All rights reserved.
//

#import "UIImageView+AsyncAndCache.h"


@implementation UIImageView (AsyncAndCache)

static AsyncAndCacheImageOperatorManager *__manager = nil;

+ (AsyncAndCacheImageOperatorManager *)_manager 
{
	if (__manager == nil) 
	{
		__manager = [[AsyncAndCacheImageOperatorManager alloc]init];
	}
	return __manager;
}

+(void)setMaxAsyncCount:(NSUInteger)count 
{
	[[UIImageView _manager] setMaxAsyncCount:count];
}

- (void)dealloc 
{
	[super dealloc];
}

-(id)initWithURLString:(NSString*)url
{
	if (self == [super init]) 
	{
		[self setImageURL:[NSURL URLWithString:url]];
	}
	return self;
}

-(id)initWithURL:(NSURL*)url
{
	if (self == [super init]) 
	{
		[self setImageURL:url];
	}
	return self;
}

-(void)setImageURLString:(NSString*)url
{
	if (url == nil) 
	{
        NSLog(@"nil");
		return;
	}
	[self setImageURL:[NSURL URLWithString:url]];
}

-(void)setImageURL:(NSURL*)url
{
	if (url == nil || [url path]==nil) 
	{
		return;
	}
    
	AsyncAndCacheImageOperator *operator = [[AsyncAndCacheImageOperator alloc]initWithURL:url imageView:self];
	[[UIImageView _manager] addImageOperator:operator];
    //NSLog(@"op---%@",operator);
	[operator release];
}


@end


@implementation AsyncAndCacheImageOperator 

@synthesize imageView = _imageView;

static NSString *__cacheImagePath;

+ (NSString *)_cacheImagePath 
{
	if (__cacheImagePath==nil) 
	{
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
		NSString *cachePath = [paths objectAtIndex:0];
		__cacheImagePath = [[[cachePath stringByAppendingPathComponent:@"cacheImages"] stringByAppendingString:@"/"]retain];		
		NSLog(@"%@",__cacheImagePath);
		
		NSFileManager *manager = [NSFileManager defaultManager];
		if (![manager fileExistsAtPath:__cacheImagePath]) 
		{
			[manager createDirectoryAtPath:__cacheImagePath withIntermediateDirectories:YES attributes:nil error:nil];
		}		
	}
	return __cacheImagePath;
}


- (id)initWithURL:(NSURL*)url imageView:(UIImageView*)imageView 
{
	self = [super init];
	if (self != nil) 
	{
		_url = [url retain];
		_imageView = [imageView retain];
	}
	
	//이미지 캐쉬 디렉토리 경로 
	
	return self;		
}

- (void)dealloc 
{
	[_loadCompleteTarget release];
	[_url release];
	[_imageView release];
	[super dealloc];
}

- (void)main 
{
	NSData *data;
	UIImage *image;
	//NSString *fileName = [_url lastPathComponent];
	NSArray *paths = [[_url path] componentsSeparatedByString:@"/"];	
	NSString *fileName = [paths objectAtIndex:[paths count]-1];	
	NSString *cachePath = [AsyncAndCacheImageOperator _cacheImagePath];
	NSString *filePath = [cachePath stringByAppendingString:fileName];
	//NSLog(@"%@",filePath);
	NSFileManager *manager = [NSFileManager defaultManager];
	
	if (_canceled==YES) 
	{
		if (_loadCompleteTarget!=nil) 
		{
			[_loadCompleteTarget performSelectorOnMainThread:_loadCompleteSelector withObject:self waitUntilDone:YES];
		}
		return;
	}
	
	//해당 경로에 이미지 파일이 있는지 확인한다.
	if( NO == [manager fileExistsAtPath:filePath] ) 
	{
		//이미지를 원격에서 가져와서 cache처리 한다.
		data = [NSData dataWithContentsOfURL:_url];
		image = [UIImage imageWithData:data];
		if (NO==[manager createFileAtPath:filePath contents:data attributes:nil]) 
		{
			NSLog(@"이미지 저장실패 : %@",filePath);
		}
	} 
	else 
	{
		//cache처리된 이미지를 읽어온다.
        image=[UIImage imageWithContentsOfFile:filePath];
        //UIImage *maskImage=[UIImage imageNamed:@"250blank.png"];
		//image = [self maskImage:[UIImage imageWithContentsOfFile:filePath] withMask:maskImage];
        NSLog(@"masking");
	}
	
	if (_canceled==NO) 
	{
		if (image){
            //UIImage *maskImage=[UIImage imageNamed:@"lblank.png"];
            //image = [self maskImage:[UIImage imageWithContentsOfFile:filePath] withMask:maskImage];

            _imageView.image = image;
            
        }
	}
    
	if (_loadCompleteTarget!=nil) 
	{
		[_loadCompleteTarget performSelectorOnMainThread:_loadCompleteSelector withObject:self waitUntilDone:YES];
	}
}
- (UIImage*) maskImage:(UIImage *)image withMask:(UIImage *)maskImage {
    
	CGImageRef maskRef = maskImage.CGImage; 
    
	CGImageRef mask = CGImageMaskCreate(CGImageGetWidth(maskRef),
                                        CGImageGetHeight(maskRef),
                                        CGImageGetBitsPerComponent(maskRef),
                                        CGImageGetBitsPerPixel(maskRef),
                                        CGImageGetBytesPerRow(maskRef),
                                        CGImageGetDataProvider(maskRef), NULL, false);
    
	CGImageRef masked = CGImageCreateWithMask([image CGImage], mask);
	return [UIImage imageWithCGImage:masked];
    
}
- (void)cancel 
{
	_canceled = YES;
}

- (void)setLoadCompleteWithTarget:(id)target selector:(SEL)selector 
{
	[target retain];
	[_loadCompleteTarget release];
	_loadCompleteTarget = target;
	_loadCompleteSelector = selector;
}

@end

@implementation AsyncAndCacheImageOperatorManager

-(id)init 
{
	if (self == [super init]) 
	{
		_maxAsyncCount = 2;
		_currentAscynCount = 0;
		_standByImageOperators = [[NSMutableArray alloc]init];
		_loadImageOperators = [[NSMutableArray alloc]init];
	}
	return self;
}

- (void)dealloc 
{
	[super dealloc];
	[_standByImageOperators release];
	[_loadImageOperators release];
}

-(void)setMaxAsyncCount:(NSUInteger)count 
{
	_maxAsyncCount = count;
}

-(void)addImageOperator:(AsyncAndCacheImageOperator*)imageOperator 
{
	//대기열에서 중복되는 imageView가 있는가 체크 
	UIImageView *imggView = imageOperator.imageView;
	for (AsyncAndCacheImageOperator *operator in _standByImageOperators) 
	{
		if (imggView == operator.imageView) 
		{
			[_standByImageOperators removeObject:operator];
			break;
		}
	}
	//로드중인 imageView중에 같은 것이 있다면 로드 cancel시킨다.
	for (AsyncAndCacheImageOperator *operator in _loadImageOperators) 
	{
		if (imggView == operator.imageView) 
		{
			[operator cancel];
		}
	}
	
	//대기열에 추가 
	[_standByImageOperators addObject:imageOperator];
	
	[self performSelector:@selector(_load) withObject:nil];
	
}

-(void)_load 
{
	//로드 실시 
	while (_currentAscynCount < _maxAsyncCount && [_standByImageOperators count] > 0) 
	{
		_currentAscynCount++;
		AsyncAndCacheImageOperator *imageOperator = [_standByImageOperators objectAtIndex:0];
		[_loadImageOperators addObject:imageOperator];
		[_standByImageOperators removeObjectAtIndex:0];
		[imageOperator setLoadCompleteWithTarget:self selector:@selector(_loadComplete:)];
		[NSThread detachNewThreadSelector:@selector(_loadThread:) toTarget:self withObject:imageOperator];
	}
}

//이미지 로드를 실시한다. ImageOperator가 로드한다.
-(void)_loadThread:(AsyncAndCacheImageOperator*)imageOperator
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
	
	[imageOperator main];
	
	[pool release];
}

//이미지 로드가 완료되면 해당 Operator를 삭제한다.
-(void)_loadComplete:(AsyncAndCacheImageOperator*)imageOperator 
{
	UIImageView *imggView = imageOperator.imageView;
	for (AsyncAndCacheImageOperator *operator in _loadImageOperators) 
	{
		if (imggView == operator.imageView) 
		{
			[_loadImageOperators removeObject:operator];
			break;
		}
	}
	_currentAscynCount--;
	//다시 다른 이미지 로드 요청 
	[self performSelector:@selector(_load)];
}


@end