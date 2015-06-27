//
//  ImageView.m
//  iCity
//
//  Created by Chang Yu Qi on 11-11-7.
//  Copyright 2011年 http://www.sznews.com. All rights reserved.
//

#import "ImageView.h"
#import <QuartzCore/QuartzCore.h>

@implementation ImageView
@synthesize imageData;
@synthesize imgName;
@synthesize delegate;


- (id)initWithFrame:(CGRect)frame imageURLStr:(NSString*)url plactHolderImgName:(NSString*)name scale:(BOOL)scale{
    self=[super initWithFrame:frame];
    if(self){
        self.needScale=scale;
        //图片名字
        self.imgName=[NSString string];
        self.imgName=[url lastPathComponent];
        self.backgroundColor=[UIColor blackColor];
        self.userInteractionEnabled=YES;
        
        //double tap
        UITapGestureRecognizer *doubleTap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(gestureAction:)];
        doubleTap.numberOfTapsRequired=2;
        
        
        //single tap
        UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(gestureAction:)];
        tap.numberOfTapsRequired=1;
        tap.delegate=self;
        
        [tap requireGestureRecognizerToFail:doubleTap];
        
        [self addGestureRecognizer:doubleTap];
        [doubleTap release];
        
        [self addGestureRecognizer:tap];
        [tap release];
        tap=nil;
        
        
        
        self.layer.borderColor = RGBGray.CGColor;
        self.layer.borderWidth = 1;
        self.layer.masksToBounds=YES; 
        self.layer.cornerRadius=1.0;
        
        self.contentMode=UIViewContentModeScaleAspectFill;
        
        
        //找出本地文件位置
        NSString *path = [Singleton sharedInstance].cacheDoc;
        NSString* imagePath=[path stringByAppendingPathComponent:[url lastPathComponent]];
        if(url && [url length]>0){
            //判断是否已下载
            //no
            if(![self imageExistAtPath:imagePath]){
                if(name){
                    self.image=[UIImage imageNamed:name];
                    
                }
                [self addLoading];
                NSURL *imgURL=[NSURL URLWithString:url];
                //NSLog(@"url.............%@",imgURL);
                NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:imgURL];
                NSURLConnection *connection = [[[NSURLConnection alloc] initWithRequest:request delegate:self] autorelease];
                [connection start];
            
            }
            else{
                if(self.needScale){
                    self.image=[self imageWithImageSimple:[UIImage imageWithContentsOfFile:imagePath] scaledToSize:CGSizeMake(80, 60)];
                }
                else{
                  self.image=[UIImage imageWithContentsOfFile:imagePath];
                }
                
            }
        }
        else{
            if(name){
                self.image=[UIImage imageNamed:name];
            }
        }
        
        
        self.userInteractionEnabled=NO;
    }
    return self;
}

- (void)dealloc{
    //[imgName release];
    imgName=nil;
    [imageData release];
    [super dealloc];
}
- (void)tapAction:(UITapGestureRecognizer*)sender{
    [delegate touchImageWithTag:self.tag];
}
- (void)gestureAction:(UITapGestureRecognizer *)sender{
    if([sender isKindOfClass:[UITapGestureRecognizer class]]){
        NSLog(@"点击手势");
        NSInteger number=[(UITapGestureRecognizer*)sender numberOfTapsRequired];
        switch (number) {
            case 1:
            {
                NSLog(@"image tap 1");
                [delegate touchImageWithTag:self.tag];
            }
                break;
            case 2:
            {
               NSLog(@"image tap 2");
                [delegate doubleTapWithTag:self.tag gesture:sender];
            }
                break;
                
            default:
                break;
        }
    }
}
- (BOOL)imageExistAtPath:(NSString*)sender{
    //NSLog(@"image path is :%@",sender);
    NSFileManager *fileManager=[NSFileManager defaultManager];
    if([fileManager isReadableFileAtPath:sender]){
        UIImage *img=[UIImage imageWithContentsOfFile:sender];
        self.image=img;
        return YES;
    }
    else{
//        NSString *imgPath=[[NSBundle mainBundle]pathForResource:@"1" ofType:@"png"];
//        UIImage *img=[UIImage imageWithContentsOfFile:imgPath];
//        self.image=img;
        return NO;
    }
}
#pragma mark -
#pragma mark NSURLConnection delegate methods
- (void)handleError:(NSError *)error{
    
}
- (void)handleError2:(NSError *)error
{
    NSString *errorMessage = [error localizedDescription];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"errorTitle",nil)
														message:errorMessage
													   delegate:nil
											  cancelButtonTitle:NSLocalizedString(@"cancelButtonTitle",nil)
											  otherButtonTitles:nil];
    [alertView show];
    [alertView release];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	//NSLog(@"didReceiveResponse");
    self.imageData = [NSMutableData data];    
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	//NSLog(@"didReceiveData is %@",data);
    [imageData appendData:data];  
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	//[defaultImage removeFromSuperview];
	
    if ([error code] == kCFURLErrorNotConnectedToInternet)
	{
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:NSLocalizedString(@"errorInfo",nil)
															 forKey:NSLocalizedDescriptionKey];
        NSError *noConnectionError = [NSError errorWithDomain:NSCocoaErrorDomain
														 code:kCFURLErrorNotConnectedToInternet
													 userInfo:userInfo];
        [self handleError:noConnectionError];
    }
	else
	{
        [self handleError:error];
    }
    
    // self.appListFeedConnection = nil;   
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [self removeLoading];
    
    NSString *path = [Singleton sharedInstance].cacheDoc;
    NSString* imgSavePath=[path stringByAppendingPathComponent:self.imgName];
    [self.imageData writeToFile:imgSavePath atomically:YES];
    NSLog(@"--------image save path:%@",imgSavePath);
//    NSFileManager *filemanager=[NSFileManager defaultManager];
//    if([filemanager fileExistsAtPath:imgSavePath]){
//        
//    }
    UIImage *img;
    if(self.needScale){
        img=[self imageWithImageSimple:[UIImage imageWithData:self.imageData] scaledToSize:CGSizeMake(80, 60)];
    }
    else{
       img=[UIImage imageWithData:self.imageData];
    }
    
    
    self.image=img;
    
    CATransition *transition = [CATransition animation];
    transition.duration = 0.6;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type=kCATransitionFade;
    transition.subtype=kCATransitionFromRight;
    transition.delegate = self;
    [self.layer addAnimation:transition forKey:nil];
    
}
#pragma mark -Gesture delegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    return YES;
}
#pragma mark -Touches
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
//    UITouch *touch=[touches anyObject];
//    if(touch.view==self){
//        [delegate touchImageWithTag:self.tag];
//        //NSLog(@"touch img:%d",self.tag);
//        
//    }
    NSLog(@"image touch");
}
#pragma mark -Loading

- (void)addLoading{
//    activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(55.0, 55.0, 20, 20)]; 
    float x=(self.frame.size.width-20)/2.0;
    float y=(self.frame.size.height-20)/2.0;
    activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(x, y, 20, 20)];
    
    //[activityIndicator setCenter:self.center];  
    [activityIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhite];
    [self addSubview:activityIndicator];  
    
    
    [activityIndicator startAnimating];
    
}
- (void)removeLoading{
    [activityIndicator stopAnimating]; 
    [activityIndicator removeFromSuperview];
    [activityIndicator release];
    activityIndicator=nil;
}
- (UIImage *)scale:(UIImage *)image toSize:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}
-(UIImage*)imageWithImageSimple:(UIImage*)image scaledToSize:(CGSize)newSize
{
    // Create a graphics image context
    UIGraphicsBeginImageContext(newSize);
    // Tell the old image to draw in this new context, with the desired
    // new size
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    // Get the new image from the context
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    // End the context
    UIGraphicsEndImageContext();
    // Return the new image.
    return newImage;
}
@end
