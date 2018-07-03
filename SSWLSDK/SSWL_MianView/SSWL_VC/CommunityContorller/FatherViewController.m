//
//  FatherViewController.m
//  AYSDK
//
//  Created by 松炎 on 2017/8/2.
//  Copyright © 2017年 SDK. All rights reserved.
//

#import "FatherViewController.h"
#import <WebKit/WebKit.h>
@interface FatherViewController ()

@property (nonatomic, strong)dispatch_source_t time;

@property (nonatomic, assign) int secNum;

@end

@implementation FatherViewController
- (void)dealloc{
    [self.webView removeObserver:self forKeyPath:@"estimatedProgress"];


}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [[SY_SSWL_NetworkTool sharedSY_SSWL_NetworkTool] getManagerBySingleton];
    [self setUpWebView];
    [self initProgressView];
    [self webViewLoadData];
    [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    
}

/*
-(BOOL)shouldAutorotate
{
    if([SS_SDKBasicInfo sharedSS_SDKBasicInfo].directionNumber == 1){
        return NO;
    }
    if([SS_SDKBasicInfo sharedSS_SDKBasicInfo].directionNumber == 0){
        return YES;
    }
    return YES;
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    if ([SS_SDKBasicInfo sharedSS_SDKBasicInfo].directionNumber == 1)    //竖屏有游戏
    {
        return UIInterfaceOrientationMaskPortrait;
    }
    if ([SS_SDKBasicInfo sharedSS_SDKBasicInfo].directionNumber == 0)    //横屏游戏
    {
        return UIInterfaceOrientationMaskLandscape;
    }
    return UIInterfaceOrientationMaskAllButUpsideDown;;
}
*/


- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator
{
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context)
     {
         SYLog(@"转屏前调入");
         //         [self.view updateConstraints];
         
     } completion:^(id<UIViewControllerTransitionCoordinatorContext> context)
     {
         SYLog(@"转屏后调入");
         self.view.frame = [[UIScreen mainScreen] bounds];
         self.webView.frame = CGRectMake(0, 20, self.view.width, self.view.height - 20 - self.tabBarHight);
//
     }];
    
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}


/**
 * 系统方法
 * 是否隐藏
 */
- (BOOL)prefersStatusBarHidden {
    return [self isBarHidden];
}

- (BOOL)isBarHidden{
    /*返回 self.barHidden*/
    return self.barHidden;
}



//自己看.h文件
- (void)setUpWebView{
    
    if (!_webView) {
        self.configuration = [[WKWebViewConfiguration alloc] init];
        
        
        WKPreferences *preferences = [WKPreferences new];
        preferences.javaScriptCanOpenWindowsAutomatically = YES;
        preferences.minimumFontSize = 40.0;
        self.configuration.preferences = preferences;
        
        
        _webView = [[WKWebView alloc] init];
        _webView.frame = CGRectMake(0, 20, self.view.frame.size.width, self.view.height - 20 - self.tabBarHight);
        _webView.UIDelegate = self;
        _webView.navigationDelegate = self;
        
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.requestUrl]]];
        
        _webView.scrollView.bounces = NO;
        //    self.webView.scrollView.decelerationRate = UIScrollViewDecelerationRateNormal;
        [self.view addSubview:self.webView];

    }
    
    [self showHUDForViewIsLoading];

    [self judgeNet];
}

//自己看.h文件
- (void)initProgressView
{
//    CGFloat kScreenWidth = [[UIScreen mainScreen] bounds].size.width;
    UIProgressView *progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 0, Screen_Width, 2)];
    progressView.tintColor = [UIColor colorWithRed:0 green:0.58 blue:1 alpha:1];
    progressView.trackTintColor = [UIColor whiteColor];
    self.progressView = progressView;
    [self.view addSubview:self.progressView];
    [self.progressView setHidden:NO];
}

- (void)showHUDForViewIsLoading{
    
//    UIImageView *customImg = [[UIImageView alloc] initWithImage:[PublicTool getImageFromBundle:[PublicTool getResourceBundle] withName:@"key" withType:@"png"]];
//    customImg.frame = CGRectMake(0, 0, 10, 10);
    self.webHUD = [MBProgressHUD showHUDAddedTo:self.webView animated:YES];
    self.webHUD.mode = MBProgressHUDModeIndeterminate;
//    [self.webHUD setCustomView :customImg];
    self.webHUD.label.text = @"正在加载";
}



/**
 * 自己看.h文件
 * 给你一个提示,判断URL
 */
- (void)webViewLoadData{
    if (self.requestUrl.length < 1) {
        [self.webView removeFromSuperview];
        self.webView = nil;
        [self isLoadData:NO];
    }else{
        [self isLoadData:YES];
    }
}



/*
 * 告诉儿子,load了没有
 */
- (void)isLoadData:(BOOL)isLoad{
    SYLog(@"isLoad-----%d", isLoad);
}

/**
 *  告诉儿子,有没有网络
 */
- (void)isNetWorking:(BOOL)isNetWorking{
    //isNetWorking : NO(儿子改做操作了)
}




// 判断网络
- (void)judgeNet
{

    Weak_Self;
    [[SY_SSWL_NetworkTool sharedSY_SSWL_NetworkTool] getNetWorkStateBlock:^(NSInteger netStatus) {
        switch (netStatus) {
            case 0:{
                [weakSelf webViewDidLoadFail];
                self.isNetWorking = NO;
            }
                break;
                
            case 1:{
                self.isNetWorking = YES;
                [weakSelf isNetWorking:YES];

            }
                break;
                
            case 2:{
                [weakSelf isNetWorking:YES];
                self.isNetWorking = YES;
            }
                break;
                
            case 3:{
                [weakSelf webViewDidLoadFail];
                self.isNetWorking = NO;
            }
                break;
                
            default:
                break;
        }
    }];
}




- (void)reloadWebViewForRequestUrl:(NSString *)requestUrl{
    SYLog(@"子类实现部分");
//    if (requestUrl.length > 1) {
//        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:requestUrl]]];
//        [self.webView reload];
//    }

}


- (void)webViewDidLoadFail{
    [self.webView stopLoading];
    self.webHUD.mode = MBProgressHUDModeText;
    self.webHUD.label.text = @"网速不给力";
    [self.webHUD hideAnimated:YES afterDelay:0.5f];
//    self.webHUD = nil;
    [self isNetWorking:NO];
    
}


- (BOOL)getShareContext{
    self.infoContextDict = [NSDictionary new];
    Weak_Self;
    
    
    [self getShareContextCompletion:^(BOOL isSuccess, id  _Nullable dict) {
        if (isSuccess) {
            
                weakSelf.infoContextDict = dict[@"data"];
            
        }else{
            
            
        }
    } failure:^(NSError * _Nullable error) {

        dispatch_async(dispatch_get_main_queue(), ^{
        });
    }];
    
    return YES;
   
}

- (void)getShareContextCompletion:(void (^)(BOOL, id _Nullable))completion failure:(void (^)(NSError * _Nullable))failure{
    Weak_Self;
    [[SY_SSWL_NetworkTool sharedSY_SSWL_NetworkTool] getManagerBySingleton];
    [[SY_SSWL_NetworkTool sharedSY_SSWL_NetworkTool] shareTheGameGiftInfoCompletion:^(BOOL isSuccess, id _Nullable response) {
        if (completion) {
            completion(isSuccess, response);
        }
    } failure:^(NSError * _Nullable error) {
        if (failure) {
            failure(error);
        }
    }];
}

- (void)ifWebViewLoadFailToGoBack{
    if (self.WebBlock) {
        self.WebBlock();
    }
}





#pragma mark - KVO
// 计算wkWebView进度条
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == self.webView && [keyPath isEqualToString:@"estimatedProgress"]) {
        CGFloat newprogress = [[change objectForKey:NSKeyValueChangeNewKey] doubleValue];
        if (newprogress == 1) {
            [self.progressView setProgress:1.0 animated:YES];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.7 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.progressView.hidden = YES;
                [self.progressView setProgress:0 animated:NO];
            });
            
        }else {
            self.progressView.hidden = NO;
            [self.progressView setProgress:newprogress animated:YES];
        }
    }
}




#pragma mark - WKUIDelegate And WKNavigationDelegate

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    SYLog(@"%s",__FUNCTION__);

    [self.webHUD hideAnimated:YES afterDelay:0.3f];

  
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation{
   
    [self judgeNet];

}

- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation{
    [self judgeNet];

}


- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error{
    SYLog(@"%s",__FUNCTION__);

    [self webViewDidLoadFail];

}

// 页面加载失败时调用
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation{
    SYLog(@"%s",__FUNCTION__);
    [self webViewDidLoadFail];

}




#pragma mark WKWebView终止
- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView {
    SYLog(@"%s",__FUNCTION__);
    [self webViewDidLoadFail];

}






- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler
{
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提醒" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

// 在收到响应后，决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler{
    
    //    NSLog(@"%@",navigationResponse.response.URL.absoluteString);
    //允许跳转
    decisionHandler(WKNavigationResponsePolicyAllow);
    //不允许跳转
    //decisionHandler(WKNavigationResponsePolicyCancel);
}
// 在发送请求之前，决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{
    
    //    NSLog(@"%@",navigationAction.request.URL.absoluteString);
    //允许跳转
    decisionHandler(WKNavigationActionPolicyAllow);
    //不允许跳转
    //decisionHandler(WKNavigationActionPolicyCancel);
}

#pragma mark - WKScriptMessageHandler
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message{
    
    
    
}

/*
- (WKWebView *)webView{
    if (!_webView) {
        self.configuration = [[WKWebViewConfiguration alloc] init];
        
        
        WKPreferences *preferences = [WKPreferences new];
        preferences.javaScriptCanOpenWindowsAutomatically = YES;
        preferences.minimumFontSize = 40.0;
        self.configuration.preferences = preferences;
        
        
        _webView = [[WKWebView alloc] init];
        _webView.frame = CGRectMake(0, 20, self.view.frame.size.width, self.view.height - 20 - self.tabBarHight);
        _webView.UIDelegate = self;
        _webView.navigationDelegate = self;
        
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.requestUrl]]];
        
        _webView.scrollView.bounces = NO;
        //    self.webView.scrollView.decelerationRate = UIScrollViewDecelerationRateNormal;
        
    }
    return _webView;
}
*/



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
