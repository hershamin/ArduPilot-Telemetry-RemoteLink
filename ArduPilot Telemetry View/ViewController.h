//
//  ViewController.h
//  ArduPilot Telemetry View
//
//  Created by hersh amin on 3/16/14.
//  Copyright (c) 2014 EmbiDex. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "ArtificialHorizonView.h"
#import "CompassView.h"
#import "VerticalScaleView.h"
#import "WMGaugeView.h"
#import "RscMgr.h"
#import <GoogleMaps/GoogleMaps.h>

#define BUFFER_LEN 1024

@interface ViewController : UIViewController <RscMgrDelegate> {
    UInt8 rxBuffer[BUFFER_LEN];
    GMSMapView *mapView;
}

@property (nonatomic, retain) IBOutlet ArtificialHorizonView *horizonView;
@property (nonatomic, retain) IBOutlet CompassView *compassView;
@property (nonatomic, retain) IBOutlet VerticalScaleView *airspeedView;
@property (nonatomic, retain) IBOutlet VerticalScaleView *altitudeView;
@property (nonatomic, retain) IBOutlet WMGaugeView *battAInd;
@property (nonatomic, retain) IBOutlet WMGaugeView *battVInd;
@property (nonatomic, retain) IBOutlet WMGaugeView *battRInd;
@property (nonatomic, retain) IBOutlet UILabel *flightModeLabel;
@property (nonatomic, retain) IBOutlet UILabel *flightTimeLabel;
@property (nonatomic, retain) IBOutlet UILabel *signalStrengthLabel;
@property (nonatomic, retain) IBOutlet UILabel *battMahLabel;
@property (nonatomic, retain) RscMgr *serialManager;

@end
