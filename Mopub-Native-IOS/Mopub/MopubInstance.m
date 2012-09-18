/*
 
 Copyright (c) 2012, Digicrafts
 All rights reserved.
 www.digicrafts.com.hk
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
 
 1. Redistributions of source code must retain the above copyright notice, this
 list of conditions and the following disclaimer.
 2. Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation
 and/or other materials provided with the distribution.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
 ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 
 The views and conclusions contained in the software and documentation are those
 of the authors and should not be interpreted as representing official policies,
 either expressed or implied, of the FreeBSD Project.
 
 
 Created by Tsang Wai Lam on 7/9/12.
 
 */


#import "MopubInstance.h"

@implementation MopubInstance


- (id) initWithAdUnitId:(NSString*)aid
{
    if ((self=[self init])) {

        aid_=aid;
            
        // Instantiate the MPAdView with your ad unit ID.
        adView_ = [[MPAdView alloc] initWithAdUnitId:aid_ size:MOPUB_BANNER_SIZE];
        
        // Register your view controller as the MPAdView's delegate.
        adView_.delegate = self;
        
        // Call for an ad.
        [adView_ loadAd];  
        
        //Set IgnoreAutoRefresh to TRUE, prevents background ad request if create is called without showAd
        [adView_ setIgnoresAutorefresh:YES];

    }
    
    return self;
}

 
- (void) showAdViewWithFrame:(CGRect)frame
{
    if(adView_){
        adView_.frame = frame;
        [[[[UIApplication sharedApplication] keyWindow] rootViewController].view addSubview:adView_];
        //setIgnoresAutorefresh:NO start refreshing ads when visible
        [adView_ setIgnoresAutorefresh:NO];
    }
}

- (void) dismissAdView
{
    if(adView_){
        
        //setIgnoresAutorefresh:YES stops refreshing ads when hidden
        [adView_ setIgnoresAutorefresh:YES];
        [adView_ removeFromSuperview];

    }
}

- (void) setAdUnitId:(NSString*)aid{
    if(adView_ && aid){
        [adView_ setAdUnitId:aid];
    }
}

- (void) loadAd
{
    if(adView_){
        [adView_ loadAd];
    }
}

- (void) refreshAd
{
    if(adView_){
        [adView_ refreshAd];
    }
}

#pragma mark MPAdViewDelegate Methods

// Implement MPAdViewDelegate's required method, -viewControllerForPresentingModalView.
- (UIViewController *)viewControllerForPresentingModalView {

    return [[[UIApplication sharedApplication] keyWindow] rootViewController];

}

- (void) dealloc
{
    if(adView_!=nil)
        [adView_ release];
    [super dealloc];
}

- (void)adViewDidLoadAd:(MPAdView *)view
{
    CGSize size = [view adContentViewSize];
    CGRect newFrame = view.frame;

    newFrame.size = size;
    if([[UIApplication sharedApplication] keyWindow].rootViewController.view)
        newFrame.origin.x = ([[UIApplication sharedApplication] keyWindow].rootViewController.view.frame.size.width - size.width) / 2;
    view.frame = newFrame;
}

- (void)adViewDidFailToLoadAd:(MPAdView *)view
{
    // remove adView if failed to load
    [view removeFromSuperview];
}

- (void)adMobCustomEvent:(MPAdView *)theAdView
{
    
    CGSize size=MOPUB_BANNER_SIZE;
    GADBannerView *admob = [[GADBannerView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    
    // Let the runtime know which UIViewController to restore after taking
    // the user wherever the ad goes and add it to the view hierarchy.
    admob.rootViewController = [[UIApplication sharedApplication] keyWindow].rootViewController;
    
    // Initiate a generic request to load it with an ad.
    [admob loadRequest:[GADRequest request]];
    
}

//- (void)mmCustomEvent:(MPAdView *)theAdView
//{
//    CGSize size=MOPUB_BANNER_SIZE;
//    //MMAdView *adView =
//    [[MMAdView adWithFrame:CGRectMake(0, 0, size.width, size.height)
//                      type:MMBannerAdTop
//                      apid:kDCGameControllerMMbAdsID
//                  delegate:self
//                    loadAd:YES
//                startTimer:YES] retain];
//    
//    
//}

#pragma mark - GADBannerViewDelegate

- (void)adViewDidReceiveAd:(GADBannerView *)bannerView
{
    // Signal to our MPAdView that the custom event successfully loaded an AdMob ad.
    [adView_ customEventDidLoadAd];
    
    // Place the AdMobView into our MPAdView.
    [adView_ setAdContentView:bannerView];
}

- (void)adView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(GADRequestError *)error
{
    // Signal to our MPAdView that the custom event failed to load an AdMob ad.
    [adView_ customEventDidFailToLoadAd];
}

- (void)adViewWillPresentScreen:(GADBannerView *)bannerView
{
    //Signal to our MPAdView that the user interacted with the custom event
    [adView_ customEventActionWillBegin];
}

- (void)adViewDidDismissScreen:(GADBannerView *)bannerView {
    //Signal to our MPAdView that the user is done interacting with the custom event
    [adView_ customEventActionDidEnd];
}

#pragma mark - MMADViewDelegate

- (void)adRequestSucceeded:(MMAdView *) adView{
    
    // Signal to our MPAdView that the custom event successfully loaded an AdMob ad.
    [adView_ customEventDidLoadAd];
    
    // Place the AdMobView into our MPAdView.
    [adView_ setAdContentView:adView];
}

- (void)adRequestFailed:(MMAdView *) adView{
    // Signal to our MPAdView that the custom event failed to load an AdMob ad.
    [adView_ customEventDidFailToLoadAd];
}
- (void)adModalWillAppear{
    //Signal to our MPAdView that the user interacted with the custom event
    [adView_ customEventActionWillBegin];
}
- (void)adModalWasDismissed{
    //Signal to our MPAdView that the user is done interacting with the custom event
    [adView_ customEventActionDidEnd];
}

@end
