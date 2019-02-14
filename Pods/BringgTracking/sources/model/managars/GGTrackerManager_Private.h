//
//  GGTrackerManager_Private.h
//  BringgTracking
//
//  Created by Matan on 01/11/2015.
//  Copyright © 2015 Matan Poreh. All rights reserved.
//

#import "GGTrackerManager.h"
#import "BringgGlobals.h"
#import "GGRealTimeMontior+Private.h"
#import "GGHTTPClientManager_Private.h"
#import "BringgPrivates.h"


#define MAX_CONNECTION_RETRIES 5

@interface GGTrackerManager()

@property (nonatomic, getter=isSecuredConnection) BOOL  useSSL;
@property (nonatomic, assign) BOOL shouldReconnect;

@property (nonatomic, strong) NSString * _Nullable customerToken;

@property (nonatomic, strong) NSMutableSet * _Nonnull polledOrders;
@property (nonatomic, strong) NSMutableSet * _Nonnull polledLocations;
@property (nonatomic, strong) NSTimer * _Nullable orderPollingTimer;
@property (nonatomic, strong) NSTimer * _Nullable locationPollingTimer;
@property (nonatomic, strong) NSTimer * _Nullable eventPollingTimer;


@property (nullable, nonatomic, weak) id<RealTimeDelegate> trackerRealtimeDelegate;
@property (nullable, nonatomic, weak) id<PrivateClientConnectionDelegate> connectionDelegate;

@property (nullable, nonatomic, weak) GGHTTPClientManager *httpManager;

@property (nonatomic, assign) NSUInteger numConnectionAttempts;

@property (nonatomic, readwrite) GGRealTimeMontior * _Nullable liveMonitor;


/**
 *  creates if needed an Bringg Tracker object
 *  @warning call this method only when obtained valid customer access token and developer access token
 *  @param devToken      a valid developer access token
 *  @param httpManager   an http manager that will do the polling for the tracker
 *  @param realTimeDelegate      a delegate object to recive notification from the Bringg tracker object

 *
 *  @return the Bringg Tracker
 */
- (nonnull instancetype)initWithDeveloperToken:(NSString *_Nullable)devToken HTTPManager:(GGHTTPClientManager * _Nullable)httpManager realTimeDelegate:(id <RealTimeDelegate> _Nullable)realTimeDelegate;





/**
 *  uses REST api to start watching an order
 *
 *  @param orderUUID         uuid of order
 *  @param completionHandler handle response callback
 */
- (void)startRESTWatchingOrderByOrderUUID:(NSString * _Nonnull)orderUUID
                    accessControlParamKey:(nonnull NSString *)accessControlParamKey
                  accessControlParamValue:(nonnull NSString *)accessControlParamValue
                    withCompletionHandler:(nullable GGOrderResponseHandler)completionHandler;



/**
 uses rest api to get the a watched order by shared location and an access controll param (order uuid, customer access token, etc)

 @param shareUUID share uuid
 @param accessControlParamKey access control key
 @param accessControlParamValue access control value
 @param completionHandler handle response callback
 */
- (void)getWatchedOrderByShareUUID:(NSString * _Nonnull)shareUUID
             accessControlParamKey:(nonnull NSString *)accessControlParamKey
           accessControlParamValue:(nonnull NSString *)accessControlParamValue
             withCompletionHandler:(nullable GGOrderResponseHandler)completionHandler;




/**
 *  the timer event handler to check if too much time passed between realtime events
 *
 *  @param timer the timer
 */
- (void)eventPolling:(NSTimer *_Nonnull)timer;

/**
 *  the timer event handler for order polling
 *
 *  @param timer the timer
 */
- (void)orderPolling:(NSTimer *_Nonnull)timer;

/**
 *  the timer event handler for location polling
 *
 *  @param timer the timer
 */
- (void)locationPolling:(NSTimer *_Nonnull)timer;


/**
 *  tries to poll information for a specific order
 *
 *  @param activeOrder the order to poll data for
 */
- (void)pollForOrder:(nonnull GGOrder * )activeOrder;


/**
 *  tries to poll location for a specific order
 *
 *  @param activeOrder the order to poll data for
 */
- (void)pollForLocation:(nonnull GGOrder *)activeOrder;

/**
 *  due to REST polling notify order delegates that an order has updated
 *
 *  @param orderUUID uuid of updated order
 */
- (void)notifyRESTUpdateForOrderWithUUID:(NSString * _Nonnull)orderUUID;
/**
 *  due to REST polling notify driver delegates that a driver location has updated
 *
 *  @param driverUUID uuid of updated driver
 *  @param shareUUID  shared uuid of updated related location
 */
- (void)notifyRESTUpdateForDriverWithUUID:(NSString *_Nonnull)driverUUID andSharedUUID:(NSString *_Nonnull)shareUUID;


/**
 *  notifies a change in the find me configuration for a specific order
 *
 *  @param orderUUID uuid of order
 */
- (void)notifyRESTFindMeUpdatedForOrderWithUUID:(NSString * _Nonnull)orderUUID;


/**
 *  disconnectes the real time
 */
- (void)disconnectFromRealTimeUpdates;


/**
 *  restarts the real time socket connection and also reviceves all watched objects
 */
- (void)restartLiveMonitor;

/**
 *  configures all polling timers
 */
- (void)configurePollingTimers;


/**
 *  restart all polling timers
 */
- (void)resetPollingTimers;

/**
 *  stops any polling actions
 */
- (void)stopPolling;


/**
 *  tries tp revive any previously watched orders
 */
- (void)reviveWatchedOrders;

/**
 *  tries tp revive any previously watched drivers
 */
- (void)reviveWatchedDrivers;


/**
 *  tries tp revive any previously watched waypoints
 */
- (void)reviveWatchedWaypoints;

/**
 *  startes order polling
 */
- (void)startOrderPolling;

/**
 *  starts location polling
 */
- (void)startLocationPolling;


/**
 *  check if tracker can/allowed to poll for orders
 *
 *  @return BOOL
 */
- (BOOL)canPollForOrders;

/**
 *  check if tracker can/allowed to poll for locations
 *
 *  @return BOOL
 */
- (BOOL)canPollForLocations;





@end
