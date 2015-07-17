
// api url
#define kBaseAPIURLStr @""


//判断是否为iOS 7.0系统
#define IS_IOS_7 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0?YES:NO)

//各种高度、宽度
#define kScreenHeight [[UIScreen mainScreen] bounds].size.height
#define kScreenWidth [[UIScreen mainScreen] bounds].size.width

#define kBottomTabHeight 49
#define kContentBaseY (IS_IOS_7?20:0)

#define kContentViewHeight (kScreenHeight-kContentBaseY)
#define kContentViewHeightNoTab kScreenHeight
#define kContentViewWidth kScreenWidth

#define kLeftViewWidth 200

//列表分页
#define kPerPage 15

//判断是否为iPhone
#define kIS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)

//判断是否为iPad
#define kIS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

//rgb颜色设置
#define RGB(r, g, b,a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a/1.0]
#define RGBGreen RGB(138,192,78,1)
#define RGBGray  RGB(245,245,245,1)
#define RGBCell  RGB(137,156,176,1)

//图标方式
#define kIconNumber @"kIconNumber"
#define kIconWidth  @"kIconWidth"

//--------------------------






//技巧
//------- arc
//用-fno-objc-arc标记来禁用在ARC工程那些不支持ARC的文件的ARC
//用-fobjc-arc标记启用非ARC工程中支持ARC的文件
