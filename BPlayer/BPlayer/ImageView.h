//
//  ImageView.h
//  iCity
//
//  Created by Chang Yu Qi on 11-11-7.
//  Copyright 2011年 http://www.sznews.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Singleton.h"
#import "Constants.h"


@protocol ImageViewDelegate <NSObject>
@optional
- (void)touchImageWithTag:(NSInteger)tag;
- (void)doubleTapWithTag:(NSInteger)tag gesture:(UITapGestureRecognizer*)sender;

@end
@interface ImageView : UIImageView<UIGestureRecognizerDelegate> {
    NSMutableData         *imageData;
    NSString              *imgName;
    id <ImageViewDelegate> delegate;
    UIActivityIndicatorView  *activityIndicator;
}
@property (nonatomic,assign)id <ImageViewDelegate>delegate;
@property (nonatomic,copy)NSString *imgName;
@property (nonatomic,retain)NSMutableData *imageData;
@property (nonatomic)BOOL needScale;
- (id)initWithFrame:(CGRect)frame imageURLStr:(NSString*)url plactHolderImgName:(NSString*)name scale:(BOOL)scale;
- (BOOL)imageExistAtPath:(NSString*)sender;
- (void)addLoading;
- (void)removeLoading;
@end
