//
//  ViewController.m
//  ScrollView嵌套悬停Demo
//
//  Created by 谭高丰 on 2017/5/9.
//  Copyright © 2017年 谭高丰. All rights reserved.
//

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

-(void)acceptMsg : (NSNotification *)notification{
    NSDictionary *userInfo = notification.userInfo;
    NSString *canScroll = userInfo[@"canScroll"];
    if ([canScroll isEqualToString:@"1"]) {
        _canScroll = YES;
    }
}

#pragma mark - UIScrollViewDelegate

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    CGFloat maxOffsetY = 136;
    CGFloat offsetY = scrollView.contentOffset.y;
    self.navigationController.navigationBar.alpha = offsetY/136;
    if (offsetY>=maxOffsetY) {
        scrollView.contentOffset = CGPointMake(0, maxOffsetY);
        //NSLog(@"滑动到顶端");
        [[NSNotificationCenter defaultCenter] postNotificationName:kHomeGoTopNotification object:nil userInfo:@{@"canScroll":@"1"}];
        _canScroll = NO;
    } else {
        //NSLog(@"离开顶端");
        if (!_canScroll) {
            scrollView.contentOffset = CGPointMake(0, maxOffsetY);
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
