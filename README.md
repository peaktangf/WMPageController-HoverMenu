<h1 align="center">Welcome to WMPageController-HoverMenu 👋</h1>

> WMPageController-HoverMenu是WMPageController的一个扩展，再次基础上实现了悬停菜单

### 效果图

![效果图](https://github.com/gaofengtan/WMPageController-HoverMenu/blob/master/%E5%B1%95%E7%A4%BA%E5%9B%BE.gif)

### 详细介绍

#### 实现思路：
我的实现是直接使用了第三方分页菜单控制器WMPageController。使用过WMPageController的童鞋可以往下看，没使用过得也可以去试一下，个人感觉比较好用，如下图：

![菜单.png](http://upload-images.jianshu.io/upload_images/1248713-26bff9aeb52acc73.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

这一部分可以直接使用WMPageController来集成，我们只需要在外面套一层UIScrollView即可。 

#### 开撸
##### 1、自定义一个ArtScrollView继承自UIScrollView，重写代理方法。
```
#import "ArtScrollView.h"

@implementation ArtScrollView

//返回YES，则可以多个手势一起触发方法，返回NO则为互斥（比如外层UIScrollView名为mainScroll内嵌的UIScrollView名为subScroll，当我们拖动subScroll时，mainScroll是不会响应手势的（多个手势默认是互斥的），
//当下面这个代理返回YES时，subScroll和mainScroll就能同时响应手势，同时滚动，这符合我们这里的需求）
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

@end
```
该ArtScrollView用在MainViewController中，解决UIScrollView嵌套的手势冲突问题。

##### 2、创建一个控制器作为容器
```
#import "ViewController.h"
#import "WMPageController.h"
#import "ArtScrollView.h"
#import "ChildTableViewController.h"

@interface ViewController ()<UIScrollViewDelegate>
@property (nonatomic, strong) WMPageController *pageController;
@property (nonatomic, strong) ArtScrollView *containerScrollView;
@property (nonatomic, strong) UIView *bannerView;
@property (nonatomic, strong) UIView *contentView;

@property (nonatomic, assign) BOOL isTopIsCanNotMoveTabView;
@property (nonatomic, assign) BOOL isTopIsCanNotMoveTabViewPre;
@property (nonatomic, assign) BOOL canScroll;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"标题";
    _canScroll = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(acceptMsg:) name:kHomeLeaveTopNotification object:nil];
    [self setupView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.navigationController.navigationBar.alpha = 0;
}

- (void)setupView {
    [self.view addSubview:self.containerScrollView];
    [self.containerScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.bottom.trailing.equalTo(self.view).offset(0);
    }];
    [self.containerScrollView addSubview:self.bannerView];
    [self.bannerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.trailing.equalTo(self.containerScrollView);
        make.width.equalTo(self.containerScrollView);
        make.height.mas_equalTo(200);
    }];
    [self.containerScrollView addSubview:self.contentView];
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.bannerView.mas_bottom);
        make.leading.trailing.bottom.equalTo(self.containerScrollView);
        make.width.equalTo(self.containerScrollView);
        make.height.mas_equalTo(kScreenHeight-64);
    }];
    [self.contentView addSubview:self.pageController.view];
    self.pageController.viewFrame = CGRectMake(0, 0, kScreenWidth, kScreenHeight-64);
}

#pragma mark - getter

- (ArtScrollView *)containerScrollView {
    if (!_containerScrollView) {
        _containerScrollView = [[ArtScrollView alloc] init];
        _containerScrollView.delegate = self;
        _containerScrollView.showsVerticalScrollIndicator = NO;
    }
    return _containerScrollView;
}

- (UIView *)bannerView {
    if (!_bannerView) {
        _bannerView = [[UIView alloc] init];
        _bannerView.backgroundColor = [UIColor blueColor];
    }
    return _bannerView;
}

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
        _contentView.backgroundColor = [UIColor yellowColor];
    }
    return _contentView;
}

- (WMPageController *)pageController {
    if (!_pageController) {
        _pageController = [[WMPageController alloc] initWithViewControllerClasses:@[[ChildTableViewController class],[ChildTableViewController class],[ChildTableViewController class]] andTheirTitles:@[@"tab1",@"tab2",@"tab3"]];
        _pageController.menuViewStyle      = WMMenuViewStyleLine;
        _pageController.menuHeight         = 44;
        _pageController.progressWidth      = 20;
        _pageController.titleSizeNormal    = 15;
        _pageController.titleSizeSelected  = 15;
        _pageController.titleColorNormal   = [UIColor grayColor];
        _pageController.titleColorSelected = [UIColor blueColor];
    }
    return _pageController;
}

#pragma mark - notification

-(void)acceptMsg:(NSNotification *)notification{
    NSDictionary *userInfo = notification.userInfo;
    NSString *canScroll = userInfo[@"canScroll"];
    if ([canScroll isEqualToString:@"1"]) {
        _canScroll = YES;
    }
}

#pragma mark - UIScrollViewDelegate

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    CGFloat maxOffsetY = 136;
    CGFloat offsetY = scrollView.contentOffset.y;
    self.navigationController.navigationBar.alpha = offsetY/136;
    if (offsetY>=maxOffsetY) {
        scrollView.contentOffset = CGPointMake(0, maxOffsetY);
        //NSLog(@"滑动到顶端");
        [[NSNotificationCenter defaultCenter] postNotificationName:kHomeGoTopNotification object:nil userInfo:@{@"canScroll":@"1"}];
        _canScroll = NO;
    }else{
        //NSLog(@"离开顶端");
        if (!_canScroll) {
            scrollView.contentOffset = CGPointMake(0, maxOffsetY);
        }
    }
}

// 移除通知
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

```
#####3、为WMPageController创建子控制器。
```
#import "ChildTableViewController.h"

@interface ChildTableViewController ()<UIScrollViewDelegate>
@property (nonatomic, assign) BOOL canScroll;
@end

@implementation ChildTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cellid"];
    // add notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(acceptMsg:) name:kHomeGoTopNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(acceptMsg:) name:kHomeLeaveTopNotification object:nil];//其中一个TAB离开顶部的时候，如果其他几个偏移量不为0的时候，要把他们都置为0
}

#pragma mark - notification

-(void)acceptMsg:(NSNotification *)notification{
    NSString *notificationName = notification.name;
    if ([notificationName isEqualToString:kHomeGoTopNotification]) {
        NSDictionary *userInfo = notification.userInfo;
        NSString *canScroll = userInfo[@"canScroll"];
        if ([canScroll isEqualToString:@"1"]) {
            self.canScroll = YES;
            self.tableView.showsVerticalScrollIndicator = YES;
        }
    }else if([notificationName isEqualToString:kHomeLeaveTopNotification]){
        self.tableView.contentOffset = CGPointZero;
        self.canScroll = NO;
        self.tableView.showsVerticalScrollIndicator = NO;
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (!self.canScroll) {
        [scrollView setContentOffset:CGPointZero];
    }
    CGFloat offsetY = scrollView.contentOffset.y;
    if (offsetY<0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kHomeLeaveTopNotification object:nil userInfo:@{@"canScroll":@"1"}];
    }
}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellid" forIndexPath:indexPath];
    cell.textLabel.text = [NSString stringWithFormat:@"第%ld行",indexPath.row];
    return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

// 移除通知
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
```

#### 总结：
这个方案结合了比较流行的WMPageController实现了悬停菜单的功能，并且使用了通知方式来解耦MainViewController和WMPageController的子控制器，相当于对WMPageController的扩展吧。
###### 1、遇到的坑
>这里面有一个WMPageController的坑，开始本来想的是把WMPageController的view通过约束添加到MainViewController中来，作为MainViewController的子控制器，结果不起作用，原因是WMPageController内部默认将WMPageController视图的frame设置成了相对window，不过可以通过设置WMPageController的viewFrame来设置frame。

###### 2、难点
>难点主要还是对手势的理解和掌握，还有UIScrollVeiw代理的使用。

对iOS手势基本知识还不太理解的可以参考这篇文字[iOS UIGestureRecognizer (手势的基本知识介绍)](http://www.jianshu.com/p/399fb18ad551)



