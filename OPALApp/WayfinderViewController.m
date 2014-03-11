//
//  WayfinderViewController.m
//  OPALApp
//
//  Created by Alexander Figueroa on 1/22/2014.
//  Copyright (c) 2014 Alexander Figueroa. All rights reserved.
//

#import "WayfinderViewController.h"
#import "BaseTheme.h"
#import "ThemeFactory.h"
#import <Mapbox/Mapbox.h>

@interface WayfinderViewController ()

@end

@implementation WayfinderViewController

- (void)awakeFromNib
{
    // This method is called when the storyboard file is loaded into memory
    [super awakeFromNib];
    
    // Call the applyTheme on initialization of view
    [self applyTheme];
}

- (void)applyTheme
{
    // Ask factory to build <Theme> compliant object to use as our themeSetter
    id <Theme> themeSetter = [[ThemeFactory sharedThemeFactory] buildThemeForSettingsKey];
    
    // Apply the themeSetters methods to apply to the view controller
    [themeSetter themeViewBackground:self.view];
    [themeSetter themeNavigationBar:self.navigationController.navigationBar];
    [themeSetter themeTabBar:self.tabBarController.tabBar];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    RMMapboxSource *tileSource = [[RMMapboxSource alloc] initWithMapID:@"salooma.hfmchk92"];
    RMMapView *mapView = [[RMMapView alloc] initWithFrame:self.view.bounds andTilesource:tileSource];
    mapView.delegate = self;
    mapView.zoom = 16.8;
    mapView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    mapView.adjustTilesForRetinaDisplay = YES; // these tiles aren't designed specifically for retina, so make them legible
    
    RMPointAnnotation *annotation = [[RMPointAnnotation alloc] initWithMapView:mapView
                                                                    coordinate:CLLocationCoordinate2DMake(43.746982947692096, -79.74335610866547)
                                                                      andTitle:@"Main Entrance"];
    RMPointAnnotation *annotation1 = [[RMPointAnnotation alloc] initWithMapView:mapView
                                                                    coordinate:CLLocationCoordinate2DMake(43.746917068276765, -79.74392473697662)
                                                                      andTitle:@"Imaging Centre"];
    RMPointAnnotation *annotation2 = [[RMPointAnnotation alloc] initWithMapView:mapView
                                                                    coordinate:CLLocationCoordinate2DMake(43.74739178597197, -79.7439193725586)
                                                                      andTitle:@"Auditorium"];
    RMPointAnnotation *annotation3 = [[RMPointAnnotation alloc] initWithMapView:mapView
                                                                     coordinate:CLLocationCoordinate2DMake(43.74628345960958, -79.7444236278534)
                                                                       andTitle:@"Emergency Entrance"];
    RMPointAnnotation *annotation4 = [[RMPointAnnotation alloc] initWithMapView:mapView
                                                                    coordinate:CLLocationCoordinate2DMake(43.746990698206794, -79.74516928195952)
                                                                      andTitle:@"Entrance A"];
    RMPointAnnotation *annotation5 = [[RMPointAnnotation alloc] initWithMapView:mapView
                                                                     coordinate:CLLocationCoordinate2DMake(43.74768824041889, -79.74439680576324)
                                                                       andTitle:@"Entrance B"];
    RMPointAnnotation *annotation6 = [[RMPointAnnotation alloc] initWithMapView:mapView
                                                                     coordinate:CLLocationCoordinate2DMake(43.74755648306817, -79.74378526210785)
                                                                       andTitle:@"Volunteers"];
    RMPointAnnotation *annotation7 = [[RMPointAnnotation alloc] initWithMapView:mapView
                                                                     coordinate:CLLocationCoordinate2DMake(43.747217400317346, -79.74345803260802)
                                                                       andTitle:@"Gift Shop"];
    RMPointAnnotation *annotation8 = [[RMPointAnnotation alloc] initWithMapView:mapView
                                                                     coordinate:CLLocationCoordinate2DMake(43.74730846844481, -79.74335074424744)
                                                                       andTitle:@"Cafeteria"];
    RMPointAnnotation *annotation9 = [[RMPointAnnotation alloc] initWithMapView:mapView
                                                                     coordinate:CLLocationCoordinate2DMake(43.74750610518098, -79.74307984113693)
                                                                       andTitle:@"Parking"];
    RMPointAnnotation *annotation10 = [[RMPointAnnotation alloc] initWithMapView:mapView
                                                                     coordinate:CLLocationCoordinate2DMake(43.74675818232971, -79.74427878856659)
                                                                       andTitle:@"X-Ray"];
    RMPointAnnotation *annotation11 = [[RMPointAnnotation alloc] initWithMapView:mapView
                                                                     coordinate:CLLocationCoordinate2DMake(43.74684343825617, -79.7444611787796)
                                                                       andTitle:@"CT & Angiography"];
    RMPointAnnotation *annotation12 = [[RMPointAnnotation alloc] initWithMapView:mapView
                                                                     coordinate:CLLocationCoordinate2DMake(43.74731234368121, -79.74388986825943)
                                                                       andTitle:@"Pharmacy"];
    RMPointAnnotation *annotation13 = [[RMPointAnnotation alloc] initWithMapView:mapView
                                                                     coordinate:CLLocationCoordinate2DMake(43.74718639836999, -79.74407762289047)
                                                                       andTitle:@"MRI"];
    RMPointAnnotation *annotation14 = [[RMPointAnnotation alloc] initWithMapView:mapView
                                                                     coordinate:CLLocationCoordinate2DMake(43.74696744665972, -79.74502980709075)
                                                                       andTitle:@"Rose Elevator"];
    RMPointAnnotation *annotation15 = [[RMPointAnnotation alloc] initWithMapView:mapView
                                                                     coordinate:CLLocationCoordinate2DMake(43.74760298569566, -79.74429219961166)
                                                                       andTitle:@"Sun Elevator"];
    RMPointAnnotation *annotation16 = [[RMPointAnnotation alloc] initWithMapView:mapView
                                                                     coordinate:CLLocationCoordinate2DMake(43.74701976262793, -79.74372088909148)
                                                                       andTitle:@"Leaf Elevator"];
    RMPointAnnotation *annotation17 = [[RMPointAnnotation alloc] initWithMapView:mapView
                                                                     coordinate:CLLocationCoordinate2DMake(43.74647722443985, -79.7443351149559)
                                                                       andTitle:@"Snow Elevator"];
    RMPointAnnotation *annotation18 = [[RMPointAnnotation alloc] initWithMapView:mapView
                                                                      coordinate:CLLocationCoordinate2DMake(43.74632415027596, -79.74482327699661)
                                                                        andTitle:@"Security - Lost & Found"];
    RMPointAnnotation *annotation19 = [[RMPointAnnotation alloc] initWithMapView:mapView
                                                                      coordinate:CLLocationCoordinate2DMake(43.747126332051316, -79.7439193725586)
                                                                        andTitle:@"Ultrasound"];
    RMPointAnnotation *annotation20 = [[RMPointAnnotation alloc] initWithMapView:mapView
                                                                     coordinate:CLLocationCoordinate2DMake(43.74675430705743, -79.7453060746193)
                                                                       andTitle:@"Mental Health Inpatients Uni"];
    RMPointAnnotation *annotation21 = [[RMPointAnnotation alloc] initWithMapView:mapView
                                                                      coordinate:CLLocationCoordinate2DMake(43.74715345878335, -79.74469989538193)
                                                                        andTitle:@"Mental Health Outpatients Unit"];
    RMPointAnnotation *annotation22 = [[RMPointAnnotation alloc] initWithMapView:mapView
                                                                      coordinate:CLLocationCoordinate2DMake(43.74776090059851, -79.74422916769981)
                                                                        andTitle:@"Geriatric Clinic"];
    
    
    [mapView addAnnotation:annotation];
    [mapView addAnnotation:annotation1];
    [mapView addAnnotation:annotation2];
    [mapView addAnnotation:annotation3];
    [mapView addAnnotation:annotation4];
    [mapView addAnnotation:annotation5];
    [mapView addAnnotation:annotation6];
    [mapView addAnnotation:annotation7];
    [mapView addAnnotation:annotation8];
    [mapView addAnnotation:annotation9];
    [mapView addAnnotation:annotation10];
    [mapView addAnnotation:annotation11];
    [mapView addAnnotation:annotation12];
    [mapView addAnnotation:annotation13];
    [mapView addAnnotation:annotation14];
    [mapView addAnnotation:annotation15];
    [mapView addAnnotation:annotation16];
    [mapView addAnnotation:annotation17];
    [mapView addAnnotation:annotation18];
    [mapView addAnnotation:annotation19];
    [mapView addAnnotation:annotation20];
    [mapView addAnnotation:annotation21];
    [mapView addAnnotation:annotation22];

    
    [self.view addSubview:mapView];
}
//- (RMMapLayer *)mapView:(RMMapView *)mapView layerForAnnotation:(RMAnnotation *)annotation
//{
//    if (annotation.isUserLocationAnnotation)
//        return nil;
//    
//    RMMapLayer *layer = nil;
//    
//    if (annotation.isClusterAnnotation)
//    {
//        layer = [[RMMarker alloc] initWithUIImage:[UIImage imageNamed:@"circle.png"]];
//        
//        layer.opacity = 0.75;
//        
//        layer.bounds = CGRectMake(0, 0, 75, 75);
//        
//        [(RMMarker *)layer setTextForegroundColor:[UIColor whiteColor]];
//        
//        [(RMMarker *)layer changeLabelUsingText:[NSString stringWithFormat:@"%i", [annotation.clusteredAnnotations count]]];
//    }
//    else
//    {
//        layer = [[RMMarker alloc] initWithMapboxMarkerImage];
//    }
//    
//    return layer;
//}

@end
