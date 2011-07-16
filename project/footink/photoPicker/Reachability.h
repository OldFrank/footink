//
//  Reachability.h
//  photoPicker
//
//  Created by yongsik on 11. 6. 24..
//  Copyright 2011 ag. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SystemConfiguration/SystemConfiguration.h>

typedef enum {
	NotReachable = 0,
	ReachableViaWiFi,
	ReachableViaWWAN
} NetworkStatus;
#define kReachabilityChangedNotification @"kNetworkReachabilityChangedNotification"

@interface Reachability: NSObject
{
	BOOL localWiFiRef;
	SCNetworkReachabilityRef reachabilityRef;
}

// 특정 호스트(웹주소)를 넣어서 어느것으로 연결되었는지 체크
+ (Reachability*) reachabilityWithHostName: (NSString*) hostName;

// 특정 아이피 주소로 확인
+ (Reachability*) reachabilityWithAddress: (const struct sockaddr_in*) hostAddress;


// 인터넷 접속 관련 체크
+ (Reachability*) reachabilityForInternetConnection;

//WIFI접속 관련 체크
+ (Reachability*) reachabilityForLocalWiFi;


// 현재 접속에 관하여 실시간적으로 체크
- (BOOL) startNotifier;
- (void) stopNotifier;

// 접속 Status체크
- (NetworkStatus) currentReachabilityStatus;

//WWAN may be available, but not active until a connection has been established.
//WiFi may require a connection for VPN on Demand.
- (BOOL) connectionRequired;

// 접속관련을 편하게 사용하게 하기 위해서 만들어넣은것.
+ (BOOL) isInternetReachable;
+ (BOOL) isWebSiteReachable: (NSString *)host;
@end
