//
//  UIImageView+AsyncAndCache.h
//
//  Created by Yongho Ji on 10. 12. 3..
//  Copyright 2010 Wecon Communications. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AsyncAndCacheImageOperator;
@class AsyncAndCacheImageOperatorManager;

//////////////////////////////////////////////////////////////
//
// UIImageView에 대한 카테고리 
// 이 카테고리는 테이블뷰에 적용된 Cell안에 UIImageView에서 활용하면 좋다.
// UIImageView의 주요 기능은 다음과 같다. 
//
// 1. 이미지 비동기 로드 
//	  이미지를 비동기로 로드해서 화면에 이미지가 뜨는데 버벅거림을 없앤다.
// 2. 이미지 캐쉬기능 
//	  이미 로드한 이미지는 cache 디렉토리에 캐쉬해서 나중에 반복 요청시 
//	  로컬에 저장된 캐쉬 이미지를 로드해서 네트워크 부하를 없애준다.
// 3. 반복적인 이미지 요청에 대한 로드부하 최소화 
//    같은 UIImageView에 중복으로 로드 요청한다면 맨 마지막에 요청한 이미지가 적용되도록 한다.
//    그뿐 아니라 수십번 반복해서 요청하더라도 무조건 이미지 로드 요청하지 않고 되도록이면 
//	  마지막 이미지를 로드요청하여 네트워크 부하를 줄여준다. 
// 
// 개선해야할 사항 
//
// 1. 캐쉬기능 강제삭제기능 
// 2. 지정된 시간이 지난 캐쉬 이미지 자동 삭제기능 
// 3. 캐쉬사용여부 결정기능  
// 
//////////////////////////////////////////////////////////////

@interface UIImageView (AsyncAndCache)

//String형태의 이미지 URL로 초기화
-(id)initWithURLString:(NSString*)url;

//NSURL 형태의 이미지 URL로 초기화 
-(id)initWithURL:(NSURL*)url;

//String형태의 이미지 URL로 셋팅 
-(void)setImageURLString:(NSString*)url;

//NSURL 형태의 이미지 URL로 셋팅 
-(void)setImageURL:(NSURL*)url;

//동시에 로드할 이미지 최대수 수 
+(void)setMaxAsyncCount:(NSUInteger)count;

@end

//////////////////////////////////////////////////////////////
//
// 한개의 ImageView에 대한 오퍼레이터이다.
// 비동기적으로 로드하는 것을 지원하며 더불어 캐쉬기능까지 지닌다.
// 개발자가 이 클래스를 직접 사용하지 않는다.
// 이 클래스는 AsyncAndCacheImageOperatorManager 클래스에서 동작/관리한다.
//
//////////////////////////////////////////////////////////////
@interface AsyncAndCacheImageOperator : NSObject
{
	NSURL			*_url;					//로드할 이미지의 URL 정보 
	UIImageView		*_imageView;			//이미지를 적용할 View
	BOOL			_canceled;				//이미지 적용을 막는다. 즉 UIImageView 재사용시 나중에 로드되더라도 이게 YES이면 적용하지 못하도록 해서 사용자들로 하여금 잘못된 이미지가 로드되는 것을 방지 한다.
	id				_loadCompleteTarget;	//이미지 로드가 완료되었을때 호출할 target
	SEL				_loadCompleteSelector;	//이미지 로드를 완료했을때 호출할 selector
}

@property (readonly) UIImageView *imageView;

//초기화 함수 
- (id)initWithURL:(NSURL*)url imageView:(UIImageView*)imageView;

//스레드 적용 함수 
- (void)main;

//이미지 적용 취소
//main 메서드가 실행중일때 스레드자체는 중단시킬 수 없지만 imageView에 로드한 image를 적용하는 것은 방지시킨다.
- (void)cancel;

//이미지 로드 완료후 호출할 target/selector 적용 
- (void)setLoadCompleteWithTarget:(id)target selector:(SEL)selctor;

- (UIImage*) maskImage:(UIImage *)image withMask:(UIImage *)maskImage;
@end

//////////////////////////////////////////////////////////////
//
// ImageView정보를 담은 여러개의 오퍼레이터(AsyncAndCacheImageOperator클래스 객체)를 관리한다.
// 개발자가 이 클래스를 직접 사용하지 않는다.
// setMaxAsyncCount를 이용해 한번에 로드할 수 있는 이미지 갯수를 설정할 수 있다.
// 중요한 것은 동일한 UIImageView에 대해서 다른 이미지 로드 요청이 있는 경우 
// 맨 마지막에 요청한 이미지가 붙도록 하며, 같은 UIImageView가 이미지 로드 대기중인 경우에는 
// 이전 UIImageView에 대한 Operator를 삭제함으로써 부적절한 로드로 인한 네트워크 부하를 최소화 해준다.
//
//////////////////////////////////////////////////////////////
@interface AsyncAndCacheImageOperatorManager : NSObject
{
@private
	NSUInteger _maxAsyncCount;				//동시에 비동기적으로 로드할 이미지 갯수 
	NSUInteger _currentAscynCount;			//현재 비동기적으로 로드하고 있는 이미지 갯수 
	NSMutableArray *_standByImageOperators;	//대기중인 Image Operator들
	NSMutableArray *_loadImageOperators;	//로드중인 Image Operator들 
}

//한번에 로드할 수 있는 이미지 갯수(스레드 최대 갯수)
-(void)setMaxAsyncCount:(NSUInteger)count;

//오퍼레이터 추가 
-(void)addImageOperator:(AsyncAndCacheImageOperator*)imageOperator;

@end
