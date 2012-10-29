//
// various states the game can get into
//
typedef enum {
    kStateStartGame,
    kStatePicker,
    kStateMultiplayer,
    kStateMultiplayerCointoss,
    kStateMultiplayerReconnect
} gameStates;

//
// for the sake of simplicity tank1 is the server and tank2 is the client
//
typedef enum {
    kServer,
    kClient
} gameNetwork;

// strings for game label
#define kStartLabel @"Tap to Start"
#define kBlueLabel  @"You're Blue"
#define kRedLabel   @"You're Red"

// GameKit Session ID for app
#define kTankSessionID @"gktank"

#define kMaxTankPacketSize 1024

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    peerStatus = kServer;
    gamePacketNumber = 0;
    gameSession = nil;
    gamePeerId = nil;
    lastHeartbeatDate = nil;
    
    NSString *uid = [[UIDevice currentDevice] uniqueIdentifier];
    
    levelBlocks = 0;
    gameUniqueID = [uid hash];
    
    NSError *parseError = nil;
    NSBundle *bundle = [NSBundle mainBundle];
    levelBlockH = [UIImage imageNamed:@"blockh.png"];
    levelBlockV = [UIImage imageNamed:@"blockv.png"];
    
    [self parseXMLFileAtURL:[NSURL fileURLWithPath: [bundle pathForResource:@"level1" ofType:@"xml"]] parseError:&parseError];
    
    self.gameState = kStateStartGame; // Setting to kStateStartGame does a reset of players, scores, etc. See -setGameState: below
    
    [NSTimer scheduledTimerWithTimeInterval:0.033 target:self selector:@selector(gameLoop) userInfo:nil repeats:YES];
}


#pragma mark GKPeerPickerControllerDelegate Methods

- (void)peerPickerControllerDidCancel:(GKPeerPickerController *)picker {
    // Peer Picker automatically dismisses on user cancel. No need to programmatically dismiss.
    
    // autorelease the picker.
    picker.delegate = nil;
    [picker autorelease];
    
    // invalidate and release game session if one is around.
    if(self.gameSession != nil) {
        [self invalidateSession:self.gameSession];
        self.gameSession = nil;
    }
    
    // go back to start mode
    self.gameState = kStateStartGame;
}

/*
 *  Note: No need to implement -peerPickerController:didSelectConnectionType: delegate method since this app does not support multiple connection types.
 *      - see reference documentation for this delegate method and the GKPeerPickerController's connectionTypesMask property.
 */

//
// Provide a custom session that has a custom session ID. This is also an opportunity to provide a session with a custom display name.
//
- (GKSession *)peerPickerController:(GKPeerPickerController *)picker sessionForConnectionType:(GKPeerPickerConnectionType)type {
    GKSession *session = [[GKSession alloc] initWithSessionID:kTankSessionID displayName:nil sessionMode:GKSessionModePeer];
    return [session autorelease]; // peer picker retains a reference, so autorelease ours so we don't leak.
}

- (void)peerPickerController:(GKPeerPickerController *)picker didConnectPeer:(NSString *)peerID toSession:(GKSession *)session {
    // Remember the current peer.
    self.gamePeerId = peerID;  // copy
    
    // Make sure we have a reference to the game session and it is set up
    self.gameSession = session; // retain
    self.gameSession.delegate = self;
    [self.gameSession setDataReceiveHandler:self withContext:NULL];
    
    // Done with the Peer Picker so dismiss it.
    [picker dismiss];
    picker.delegate = nil;
    [picker autorelease];
    
    // Start Multiplayer game by entering a cointoss state to determine who is server/client.
    self.gameState = kStateMultiplayerCointoss;
}

#pragma mark -
#pragma mark Session Related Methods

//
// invalidate session
//
- (void)invalidateSession:(GKSession *)session {
    if(session != nil) {
        [session disconnectFromAllPeers];
        session.available = NO;
        [session setDataReceiveHandler: nil withContext: NULL];
        session.delegate = nil;
    }
}

#pragma mark Data Send/Receive Methods

/*
 * Getting a data packet. This is the data receive handler method expected by the GKSession.
 * We set ourselves as the receive data handler in the -peerPickerController:didConnectPeer:toSession: method.
 */
- (void)receiveData:(NSData *)data fromPeer:(NSString *)peer inSession:(GKSession *)session context:(void *)context {
    static int lastPacketTime = -1;
    unsigned char *incomingPacket = (unsigned char *)[data bytes];
    int *pIntData = (int *)&incomingPacket[0];
    //
    // developer  check the network time and make sure packers are in order
    //
    int packetTime = pIntData[0];
    int packetID = pIntData[1];
    if(packetTime < lastPacketTime && packetID != NETWORK_COINTOSS) {
        return;
    }
    
    lastPacketTime = packetTime;
    switch( packetID ) {
        case NETWORK_COINTOSS:
        {
            // coin toss to determine roles of the two players
            int coinToss = pIntData[2];
            // if other player's coin is higher than ours then that player is the server
            if(coinToss > gameUniqueID) {
                self.peerStatus = kClient;
            }
            
            // notify user of tank color
            self.gameLabel.text = (self.peerStatus == kServer) ? kBlueLabel : kRedLabel; // server is the blue tank, client is red
            self.gameLabel.hidden = NO;
            // after 1 second fire method to hide the label
            [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(hideGameLabel:) userInfo:nil repeats:NO];
        }
            break;
        case NETWORK_MOVE_EVENT:
        {
            // received move event from other player, update other player's position/destination info
            tankInfo *ts = (tankInfo *)&incomingPacket[8];
            int peer = (self.peerStatus == kServer) ? kClient : kServer;
            tankInfo *ds = &tankStats[peer];
            ds->tankDestination = ts->tankDestination;
            ds->tankDirection = ts->tankDirection;
        }
            break;
        case NETWORK_FIRE_EVENT:
        {
            // received a missile fire event from other player, update other player's firing status
            tankInfo *ts = (tankInfo *)&incomingPacket[8];
            int peer = (self.peerStatus == kServer) ? kClient : kServer;
            tankInfo *ds = &tankStats[peer];
            ds->tankMissile = ts->tankMissile;
            ds->tankMissilePosition = ts->tankMissilePosition;
            ds->tankMissileDirection = ts->tankMissileDirection;
        }
            break;
        case NETWORK_HEARTBEAT:
        {
            // Received heartbeat data with other player's position, destination, and firing status.
            
            // update the other player's info from the heartbeat
            tankInfo *ts = (tankInfo *)&incomingPacket[8];      // tank data as seen on other client
            int peer = (self.peerStatus == kServer) ? kClient : kServer;
            tankInfo *ds = &tankStats[peer];                    // same tank, as we see it on this client
            memcpy( ds, ts, sizeof(tankInfo) );
            
            // update heartbeat timestamp
            self.lastHeartbeatDate = [NSDate date];
            
            // if we were trying to reconnect, set the state back to multiplayer as the peer is back
            if(self.gameState == kStateMultiplayerReconnect) {
                if(self.connectionAlert && self.connectionAlert.visible) {
                    [self.connectionAlert dismissWithClickedButtonIndex:-1 animated:YES];
                }
                self.gameState = kStateMultiplayer;
            }
        }
            break;
        default:
            // error
            break;
    }
}

- (void)sendNetworkPacket:(GKSession *)session packetID:(int)packetID withData:(void *)data ofLength:(int)length reliable:(BOOL)howtosend {
    // the packet we'll send is resued
    static unsigned char networkPacket[kMaxTankPacketSize];
    const unsigned int packetHeaderSize = 2 * sizeof(int); // we have two "ints" for our header
    
    if(length < (kMaxTankPacketSize - packetHeaderSize)) { // our networkPacket buffer size minus the size of the header info
        int *pIntData = (int *)&networkPacket[0];
        // header info
        pIntData[0] = gamePacketNumber++;
        pIntData[1] = packetID;
        // copy data in after the header
        memcpy( &networkPacket[packetHeaderSize], data, length );
        
        NSData *packet = [NSData dataWithBytes: networkPacket length: (length+8)];
        if(howtosend == YES) {
            [session sendData:packet toPeers:[NSArray arrayWithObject:gamePeerId] withDataMode:GKSendDataReliable error:nil];
        } else {
            [session sendData:packet toPeers:[NSArray arrayWithObject:gamePeerId] withDataMode:GKSendDataUnreliable error:nil];
        }
    }
}



//
// Game loop runs at regular interval to update game based on current game state
//
- (void)gameLoop {
    static int counter = 0;
    switch (self.gameState) {
        case kStatePicker:
        case kStateStartGame:
            break;
        case kStateMultiplayerCointoss:
            [self sendNetworkPacket:self.gameSession packetID:NETWORK_COINTOSS withData:&gameUniqueID ofLength:sizeof(int) reliable:YES];
            self.gameState = kStateMultiplayer; // we only want to be in the cointoss state for one loop
            break;
        case kStateMultiplayer:
            [self updateTanks];
            counter++;
            if(!(counter&7)) { // once every 8 updates check if we have a recent heartbeat from the other player, and send a heartbeat packet with current state
                if(self.lastHeartbeatDate == nil) {
                    // we haven't received a hearbeat yet, so set one (in case we never receive a single heartbeat)
                    self.lastHeartbeatDate = [NSDate date];
                }
                else if(fabs([self.lastHeartbeatDate timeIntervalSinceNow]) >= kHeartbeatTimeMaxDelay) { // see if the last heartbeat is too old
                    // seems we've lost connection, notify user that we are trying to reconnect (until GKSession actually disconnects)
                    NSString *message = [NSString stringWithFormat:@"Trying to reconnect...\nMake sure you are within range of %@.", [self.gameSession displayNameForPeer:self.gamePeerId]];
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Lost Connection" message:message delegate:self cancelButtonTitle:@"End Game" otherButtonTitles:nil];
                    self.connectionAlert = alert;
                    [alert show];
                    [alert release];
                    self.gameState = kStateMultiplayerReconnect;
                }
                
                // send a new heartbeat to other player
                tankInfo *ts = &tankStats[self.peerStatus];
                [self sendNetworkPacket:gameSession packetID:NETWORK_HEARTBEAT withData:ts ofLength:sizeof(tankInfo) reliable:NO];
            }
            break;
        case kStateMultiplayerReconnect:
            // we have lost a heartbeat for too long, so pause game and notify user while we wait for next heartbeat or session disconnect.
            counter++;
            if(!(counter&7)) { // keep sending heartbeats to the other player in case it returns
                tankInfo *ts = &tankStats[self.peerStatus];
                [self sendNetworkPacket:gameSession packetID:NETWORK_HEARTBEAT withData:ts ofLength:sizeof(tankInfo) reliable:NO];
            }
            break;
        default:
            break;
    }
}


//
// load a game level
//
-(BOOL)parseXMLFileAtURL:(NSURL *)file parseError:(NSError **)error {
    NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL:file];
    // we'll do the parsing
    [parser setDelegate:self];
    [parser setShouldProcessNamespaces:NO];
    [parser setShouldReportNamespacePrefixes:NO];
    [parser setShouldResolveExternalEntities:NO];
    [parser parse];
    
    NSError *parseError = [parser parserError];
    if(parseError && error) {
        *error = parseError;
    }
    
    [parser release];
    
    return (parseError) ? YES : NO;
}

//
// the XML parser calls here with all the elements for the level
//
-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    if(qName) {
        elementName = qName;
    }
    
    if([elementName isEqualToString:@"vblock"]) {
        float x = [[attributeDict valueForKey:@"x"] floatValue];
        float y = [[attributeDict valueForKey:@"y"] floatValue];
        [self addToLevel: BLOCK_VERTICAL atX: x atY: y width: 8 height: 32];
    }
    else if([elementName isEqualToString:@"hblock"]) {
        float x = [[attributeDict valueForKey:@"x"] floatValue];
        float y = [[attributeDict valueForKey:@"y"] floatValue];
        [self addToLevel: BLOCK_HORIZONTAL atX: x atY: y width: 64 height: 8];
    }
    else if([elementName isEqualToString:@"player1"]) {
        tank1Start.x = [[attributeDict valueForKey:@"x"] floatValue];
        tank1Start.y = [[attributeDict valueForKey:@"y"] floatValue];
    }
    else if([elementName isEqualToString:@"player2"]) {
        tank2Start.x = [[attributeDict valueForKey:@"x"] floatValue];
        tank2Start.y = [[attributeDict valueForKey:@"y"] floatValue];
    }
}

//
// the level did not load, file not found, etc.
//
-(void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError{
    NSLog(@"Error on XML Parse: %@", [parseError localizedDescription] );
}

#pragma mark -
#pragma mark UIAlertViewDelegate Methods

// Called when an alert button is tapped.
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    // 0 index is "End Game" button
    if(buttonIndex == 0) {
        self.gameState = kStateStartGame;
    }
}

@end