//
//  SlidingTabView.h
//  photoPicker
//
//  Created by yongsik on 11. 6. 24..
//  Copyright 2011 ag. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SlidingTab.h"

@class SlidingTabView;
@protocol SlidingTabViewDelegate;

@interface SlidingTabView : UIView {
    SlidingTab* _tab;
    NSMutableArray* _buttons;
    NSObject <SlidingTabViewDelegate> *_delegate;
}


/**
 * Setup the tabs
 */
- (id) initWithTabCount:(NSUInteger)tabCount withText:(NSMutableArray *)labelText delegate:(NSObject <SlidingTabViewDelegate>*)slidingTabsControlDelegate;


@end

@protocol SlidingTabViewDelegate

- (UILabel*) labelFor:(SlidingTabView*)slidingTabsControl atIndex:(NSUInteger)tabIndex  atLabel:(NSString *)ltext;

@optional
- (void) touchUpInsideTabIndex:(NSUInteger)tabIndex;
- (void) touchDownAtTabIndex:(NSUInteger)tabIndex;
@end