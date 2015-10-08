//
//  ViewController.m
//  ArduPilot Telemetry View
//
//  Created by hersh amin on 3/16/14.
//  Copyright (c) 2014 EmbiDex. All rights reserved.
//

#import "ViewController.h"
#import "MiscUtilities.h"
#import "UIView+Toast.h"

@interface ViewController ()

@end

@implementation ViewController {
    float roll; // Roll in deg.
    float pitch; // Pitch in deg.
    float yaw; // Yaw in deg.
    float lat; // GPS Latitude in deg.
    float lng; // GPS Longitude in deg.
    float groundCourse; // GPS Ground Course in deg.
    float alt; // Altitude
    float airspeed; // Airspeed
    float navBearing; // Bearing Target in deg.
    float altErr; // Altitude Error
    float aspErr; // Airspeed Error
    NSString *mode; // Flying Mode
    float time; // Air Time in Sec.
    float battV; // Battery Voltage
    float battA; // Battery Amp Draw
    float battR; // Battery Remaining
    float battM; // Battery MilliAmpHr Used
    float signalStrength; // Signal Strength;
    NSMutableString *inputStringData;
    GMSMarker *airplaneMarker;
    GMSMutablePath *airplanePath;
}

@synthesize horizonView, airspeedView, altitudeView, compassView, signalStrengthLabel, battMahLabel;
@synthesize battAInd, battVInd, battRInd, flightModeLabel, flightTimeLabel, serialManager;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // Set up serial connection
    serialManager = [[RscMgr alloc] init];
    [serialManager setDelegate:self];
    inputStringData = [[NSMutableString alloc] init];
    inputStringData = [NSMutableString stringWithString:@""];
    
    // Set up battery meters
    // Battery Amps
    battAInd.backgroundColor = [UIColor clearColor];
    battAInd.maxValue = 80.0;
    battAInd.showRangeLabels = YES;
    battAInd.rangeValues = @[@50,@55,@80];
    battAInd.rangeColors = @[[UIColor greenColor],[UIColor yellowColor],[UIColor redColor]];
    battAInd.rangeLabels = @[@"Normal Operating Range",@"Caution",@"Possible Cut-Off"];
    battAInd.unitOfMeasurement = @"Amps";
    battAInd.unitOfMeasurementFont = [UIFont fontWithName:@"Helvetica" size:0.08];
    battAInd.showUnitOfMeasurement = YES;
    battAInd.scaleDivisions = 16;
    battAInd.scaleSubdivisions = 5;
    battAInd.rangeLabelsFontColor = [UIColor blackColor];
    battAInd.rangeLabelsWidth = 0.04;
    battAInd.rangeLabelsFont = [UIFont fontWithName:@"Helvetica" size:0.04];
    // Battery Volts
    battVInd.backgroundColor = [UIColor clearColor];
    battVInd.maxValue = 20.0;
    battVInd.showRangeLabels = YES;
    battVInd.rangeValues = @[@8,@16,@20];
    battVInd.rangeColors = @[[UIColor redColor],[UIColor yellowColor],[UIColor greenColor]];
    battVInd.rangeLabels = @[@"Damaged",@"Normal Range",@"Energized"];
    battVInd.unitOfMeasurement = @"Volts";
    battVInd.unitOfMeasurementFont = [UIFont fontWithName:@"Helvetica" size:0.08];
    battVInd.showUnitOfMeasurement = YES;
    battVInd.scaleDivisions = 10;
    battVInd.scaleSubdivisions = 2;
    battVInd.rangeLabelsFontColor = [UIColor blackColor];
    battVInd.rangeLabelsWidth = 0.04;
    battVInd.rangeLabelsFont = [UIFont fontWithName:@"Helvetica" size:0.04];
    // Battery Remaining
    battRInd.backgroundColor = [UIColor clearColor];
    battRInd.maxValue = 100.0;
    battRInd.showRangeLabels = YES;
    battRInd.rangeValues = @[@20,@30,@100];
    battRInd.rangeColors = @[[UIColor redColor],[UIColor yellowColor],[UIColor greenColor]];
    battRInd.rangeLabels = @[@"Reserve",@"Caution",@"Normal Range"];
    battRInd.unitOfMeasurement = @"% Battery";
    battRInd.unitOfMeasurementFont = [UIFont fontWithName:@"Helvetica" size:0.08];
    battRInd.showUnitOfMeasurement = YES;
    battRInd.scaleDivisions = 20;
    battRInd.scaleSubdivisions = 5;
    battRInd.rangeLabelsFontColor = [UIColor blackColor];
    battRInd.rangeLabelsWidth = 0.04;
    battRInd.rangeLabelsFont = [UIFont fontWithName:@"Helvetica" size:0.04];
    
    // Initialize Variables
    roll = 45; pitch = 15; yaw = 10;
    lat = 30.323531; lng = -97.602936;
    groundCourse = 5; alt = 100; airspeed = 10;
    navBearing = 10; altErr = 20; aspErr = 5;
    mode = @"Manual"; time = 0; signalStrength = 23;
    battV = 5; battA = 21; battR = 45, battM = 9500;
    [horizonView setRoll:(roll*M_PI/180) pitch:(pitch*M_PI/180)];
    [compassView setHeading:groundCourse];
    [compassView setNavBearing:navBearing];
    [airspeedView setValue:airspeed];
    [airspeedView setTargetDelta:aspErr];
    [altitudeView setValue:alt];
    [altitudeView setTargetDelta:altErr];
    battVInd.value = battV;
    battAInd.value = battA;
    battRInd.value = battR;
    
    // Initialize Subviews
    [horizonView setBackgroundColor:[UIColor clearColor]];
    [airspeedView setScale:20];
    [altitudeView setScale:200];
    
    // Setup Mapview
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:30.324086 longitude:-97.603365 zoom:17];
    mapView = [GMSMapView mapWithFrame:CGRectMake(60, 0, 617, 648) camera:camera];
    mapView.settings.rotateGestures = NO;
    mapView.mapType = kGMSTypeHybrid;
    [self.view addSubview:mapView];
    self.view.backgroundColor = [UIColor grayColor];
    
    // Setup Airplane on Mapview
    CLLocationCoordinate2D position = CLLocationCoordinate2DMake(30.324086, -97.603365);
    airplaneMarker = [GMSMarker markerWithPosition:position];
    airplaneMarker.groundAnchor = CGPointMake(0.5, 0.5);
    airplaneMarker.icon = [UIImage imageNamed:@"airplane.png"];
    airplaneMarker.rotation = 45;
    airplaneMarker.map = mapView;
    
    // Setup Flight path
    airplanePath = [GMSMutablePath path];
    GMSPolyline *polyline = [GMSPolyline polylineWithPath:airplanePath];
    polyline.strokeColor = [UIColor redColor];
    polyline.strokeWidth = 2.0f;
    polyline.geodesic = YES;
    polyline.map = mapView;
}

-(void)updateUIwithNewData {
    // Update Attitude
    [horizonView setRoll:(roll*M_PI/180) pitch:(pitch*M_PI/180)];
    // Update Compass
    [compassView setHeading:groundCourse];
    [compassView setNavBearing:navBearing];
    // Update Map
    [airplanePath addCoordinate:CLLocationCoordinate2DMake(lat, lng)];
    [airplaneMarker setRotation:yaw];
    [airplaneMarker setPosition:CLLocationCoordinate2DMake(lat, lng)];
    // Update Battery Parameters
    [battVInd setValue:battV];
    [battAInd setValue:battA];
    [battRInd setValue:battR];
    // Update Flight Mode
    [flightModeLabel setText:mode];
    // Update Airspeed
    [airspeedView setValue:airspeed];
    [airspeedView setTargetDelta:aspErr];
    // Update Altitude
    [altitudeView setValue:alt];
    [altitudeView setTargetDelta:altErr];
    // Update Flight Time
    int minutes = (int)time / 60;
    int seconds = (int)time % 60;
    [flightTimeLabel setText:[NSString stringWithFormat:@"%d:%02d",minutes,seconds]];
    // Redraw
    [horizonView requestRedraw];
    [compassView requestRedraw];
    [airspeedView requestRedraw];
    [altitudeView requestRedraw];
    [signalStrengthLabel setText:[NSString stringWithFormat:@"%2.1f %%",signalStrength]];
    [battMahLabel setText:[NSString stringWithFormat:@"%4.0f",battM]];
}

// Serial Cable Delegate
-(void)cableConnected:(NSString *)protocol {
    [serialManager setBaud:4800];
    [serialManager open];
    [self.view makeToast:@"External Antenna Connected"];
}

-(void)cableDisconnected {
    [self.view makeToast:@"External Antenna Disconnected"];
}

-(void)readBytesAvailable:(UInt32)length {
    // Get Data & update UI
    [serialManager read:rxBuffer Length:length];
    NSString *string = nil;
    BOOL readyForProcessing = NO;
    for (int i=0; i<length; i++) {
        char *received = ((char *)rxBuffer[i]);
        if (received == '\n') {
            string = inputStringData;
            inputStringData = [NSMutableString stringWithString:@""];
            readyForProcessing = YES;
        } else {
            [inputStringData insertString:[NSString stringWithFormat:@"%c",received] atIndex:[inputStringData length]];
        }
    }
    
    if (readyForProcessing) {
        // look for parameters & update accordingly
        NSArray *array = [string componentsSeparatedByString:@","];
        
        if ([array count] == 2) {
            // Good Data
            NSString *check = [array objectAtIndex:0];
            NSString *value = [array objectAtIndex:1];
            if ([check isEqualToString:@"roll"]) {
                roll = [value floatValue];
            } else if ([check isEqualToString:@"pitch"]) {
                pitch = [value floatValue];
            } else if ([check isEqualToString:@"yaw"]) {
                yaw = [value floatValue];
            } else if ([check isEqualToString:@"groundcourse"]) {
                groundCourse = [value floatValue];
            } else if ([check isEqualToString:@"lat"]) {
                lat = [value floatValue];
            } else if ([check isEqualToString:@"lng"]) {
                lng = [value floatValue];
            } else if ([check isEqualToString:@"alt"]) {
                alt = [value floatValue];
            } else if ([check isEqualToString:@"airspeed"]) {
                airspeed = [value floatValue];
            } else if ([check isEqualToString:@"timeInAir"]) {
                time = [value floatValue];
            } else if ([check isEqualToString:@"battery_voltage"]) {
                battV = [value floatValue];
            } else if ([check isEqualToString:@"battery_remaining"]) {
                battR = [value floatValue];
            } else if ([check isEqualToString:@"current"]) {
                battA = [value floatValue];
            } else if ([check isEqualToString:@"battery_usedmah"]) {
                battM = [value floatValue];
            } else if ([check isEqualToString:@"linkquality"]) {
                signalStrength = [value floatValue];
            } else if ([check isEqualToString:@"alt_error"]) {
                altErr = [value floatValue];
            } else if ([check isEqualToString:@"aspd_error"]) {
                aspErr = [value floatValue];
            } else if ([check isEqualToString:@"mode"]) {
                mode = value;
            } else if ([check isEqualToString:@"nav_bearing"]) {
                navBearing = [value floatValue];
            }
            [self updateUIwithNewData];
        } else {
            // Create Toast
            [self.view makeToast:string];
        }
    }
}

-(void)portStatusChanged {
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

@end
