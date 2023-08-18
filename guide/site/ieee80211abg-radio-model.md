---
layout: default
title: IEEE 802.11abg Radio Model
nav_order: 11
permalink: /ieee80211abg-radio-model
---


# IEEE 802.11abg Radio Model

The IEEE 802.11abg radio model is a behavioral representation of an
IEEE 802.11abg radio.

## Features

The IEEE 802.11abg radio model provides the following set of features:
[DSS and OFDM Modes and Rates](#dss-and-ofdm-modes-and-rates), [DCF
Channel Access](#dcf-channel-access), and [Packet Completion Rate
Curves](#packet-completion-rate-curves).

### DSS and OFDM Modes and Rates

The IEEE 802.11abg radio supports the following waveform modes and
data rates with the appropriate timing:

   1. 802.11b (DSS rates: 1, 2, 5.5 and 11 Mbps)
  
   2. 802.11a/g (OFDM rates: 6, 9, 12, 18, 24, 36, 48 and 54 Mbps)
  
   3. 802.11b/g (DSS and OFDM rates)

### DCF Channel Access

The IEEE 802.11abg radio model supports Distributed Coordination
Function (DCF) channel access.

### Unicast and Broadcast Transmissions

The IEEE 802.11abg radio model supports both unicast and broadcast
transmissions. Unicast transmissions include the ability to emulate
control message (RTS/CTS) behavior as well as retries without actually
transmitting the control messages or the re-transmission of the data
message. The emulation of unicast does not replicate exponential
growth of the contention window as a result of detected failures.

###  Wi-Fi Multimedia

The IEEE 802.11abg radio model supports Wi-Fi multimedia (WMM)
capabilities with the ability to classify four different traffic
classes: Background, Best Effort, Video, and Voice, where the higher
priority classes (Voice and Video) are serviced first.

### Packet Completion Rate Curves

The IEEE 802.11abg Packet Completion Rate is specified as curves
defined via XML. Each curve definition comprises a series SINR values
along with their corresponding probability of reception for a given
data rate index. A curve definition must contain a minimum of two
points with one SINR representing *POR = 0* and one SINR representing
*POR = 100*. Linear interpolation is preformed when an exact SINR
match is not found.

The IEEE 802.11abg radio model does adjust the interference on a
per packet basis based on detected collisions and as such supports
negative SINR values.

Specifying a packet size (`<table>` attribute `pktsize`) in the
curve file will adjust the POR based on received packet
size. Specifying a `pktsize` of 0 disregards received packet size when
computing the POR.

The POR is obtained using the following calculation when a non-zero
`pktsize` is specified:

$$POR = POR_0 ^ {S_1/S_0}$$

Where,

$$POR_0$$ is the POR value determined from the PCR curve for
the given SINR value

$$S_0$$ is the packet size specified in the curve file
`pktsize`

$$S_1$$ is the received packet size

The below default PCR curves are provided for each of the supported
802.11 modulation and data rate combinations based on theoretical
equations for determining Bit Error Rate (BER) in an Additive White
Gaussian Noise (AWGN) channel.

```xml
<!DOCTYPE pcr SYSTEM "file:///usr/share/emane/dtd/ieee80211pcr.dtd">
<pcr>
  <table pktsize="128">
    <!-- 1Mpbs -->
    <datarate index="1">
      <row sinr="-9.0"  por="0.0"/>
      <row sinr="-8.0"  por="1.4"/>
      <row sinr="-7.0"  por="21.0"/>
      <row sinr="-6.0"  por="63.5"/>
      <row sinr="-5.0"  por="90.7"/>
      <row sinr="-4.0"  por="98.6"/>
      <row sinr="-3.0"  por="99.9"/>
      <row sinr="-2.0"  por="100.0"/>
    </datarate>
    <!-- 2Mpbs -->
    <datarate index="2">
      <row sinr="-6.0"  por="0"/>
      <row sinr="-5.0"  por="1.4"/>
      <row sinr="-4.0"  por="20.6"/>
      <row sinr="-3.0"  por="63.1"/>
      <row sinr="-2.0"  por="90.5"/>
      <row sinr="-1.0"  por="98.5"/>
      <row sinr="0.0"   por="99.9"/>
      <row sinr="1.0"   por="100.0"/>
    </datarate>
    <!-- 5.5Mpbs -->

<... snippet: only 26 lines shown...>
```
<p style="float:right;font-family:courier;font-size:75%">emane-guide/examples/ieee80211abg-01/node-1/emane-ieee80211abg-pcr.xml</p><br>

![](images/ieee80211pcr.png){:width="90%"; .centered}
<p style="text-align:center;font-size:75%">IEEE 802.11b DSS (left). IEEE 802.11ag OFDM (right).</p><br>

## Limitations

1. The IEEE 802.11abg radio model does not support Point Coordination
Function (PCF) channel access or the concept of beacons to discover
and join an access point.

2. The IEEE 802.11abg uses a radio model specific
[`OneHopNeighborsEvent`](#onehopneighborsevent) to communicate one-hop
neighbors to behaviorally emulate the csma/ca channel access protocol
without actual transmission of RTS and CTS packets. The neighbor
information in the event allows each node to estimate channel activity
associated from one and two hop neighbors to emulate collisions not
only from immediate neighbors but also from 2-hop hidden neighbors.

If the emulator is oversubscribed and can no longer process IEEE
802.11abg radio model transmissions as fast as they are received, the
radio model channel activity estimator will estimate less activity
within the estimation period, leading to a failure condition with
better network performance then would be experienced with real radios.

## `OneHopNeighborsEvent`

A `OneHopNeighborsEvent` is used to communicate one-hop neighbors to
other IEEE 802.11abg radio model instances running in an emulation in
order to behaviorally emulate the csma/ca channel access protocol
without actual transmission of RTS and CTS packets

```protobuf
package EMANEEventMessage;
option optimize_for = SPEED;
message OneHopNeighborsEvent
{
  required uint32 eventSource = 1;
  message Neighbor
  {
    required uint32 nemId = 1;
  }
  repeated Neighbor neighbors = 2;
}
```
<p style="float:right;font-family:courier;font-size:75%">emane/src/models/mac/ieee80211abg/onehopneighborsevent.proto</p><br>

## Configuration

1. **`aifs0`**: Defines the arbitration inter frame spacing time for
   category 0 and contributes to the calculation of channel access
   overhead when transmitting category 0 packets.  If WMM is disabled,
   aifs0 is used for all traffic.
   
   ```no-highlighting
   Default: yes                   Required: no                    Modifiable: no                  
   Type:    float                 Occurrs:  [1,1]                 Range:      [0.000000,0.000255] 
   Values:  0.000002
   ```

2. **`aifs1`**: Defines the arbitration inter frame spacing time for
   category 1 and contributes to the calculation of channel access
   overhead when transmitting category 1 packets.
   
   ```no-highlighting
   Default: yes                   Required: no                    Modifiable: no                  
   Type:    float                 Occurrs:  [1,1]                 Range:      [0.000000,0.000255] 
   Values:  0.000002
   ```

3. **`aifs2`**: Defines the arbitration inter frame spacing time for
   category 2 and contributes to the calculation of channel access
   overhead when transmitting category 2 packets.
   
   ```no-highlighting
   Default: yes                   Required: no                    Modifiable: no                  
   Type:    float                 Occurrs:  [1,1]                 Range:      [0.000000,0.000255] 
   Values:  0.000002
   ```

4. **`aifs3`**: Defines the arbitration inter frame spacing time for
   category 3 and contributes to the calculation of channel access
   overhead when transmitting category 3 packets.
   
   ```no-highlighting
   Default: yes                   Required: no                    Modifiable: no                  
   Type:    float                 Occurrs:  [1,1]                 Range:      [0.000000,0.000255] 
   Values:  0.000001
   ```

5. **`channelactivityestimationtimer`**: Defines the channel activity
   estimation timer in seconds. The timer determines the lag associated
   with the statistical model used to estimate number of transmitting
   common and hidden neighbors based on channel activity.
   
   ```no-highlighting
   Default: yes                   Required: no                    Modifiable: no                  
   Type:    float                 Occurrs:  [1,1]                 Range:      [0.001000,1.000000] 
   Values:  0.100000
   ```

6. **`cwmax0`**: Defines the maximum contention window size in slots
   for category 0.
   
   ```no-highlighting
   Default: yes                   Required: no                    Modifiable: yes                 
   Type:    uint16                Occurrs:  [1,1]                 Range:      [1,65535]           
   Values:  1024
   ```

7. **`cwmax1`**: Defines the maximum contention window size in slots
   for category 1.
   
   ```no-highlighting
   Default: yes                   Required: no                    Modifiable: yes                 
   Type:    uint16                Occurrs:  [1,1]                 Range:      [1,65535]           
   Values:  1024
   ```

8. **`cwmax2`**: Defines the maximum contention window size in slots
   for category 2.
   
   ```no-highlighting
   Default: yes                   Required: no                    Modifiable: yes                 
   Type:    uint16                Occurrs:  [1,1]                 Range:      [1,65535]           
   Values:  64
   ```

9. **`cwmax3`**: Defines the maximum contention window size in slots
   for category 3.
   
   ```no-highlighting
   Default: yes                   Required: no                    Modifiable: yes                 
   Type:    uint16                Occurrs:  [1,1]                 Range:      [1,65535]           
   Values:  16
   ```

10. **`cwmin0`**: Defines the minimum contention window size in slots
    for category 0.
    
    ```no-highlighting
    Default: yes                   Required: no                    Modifiable: yes                 
    Type:    uint16                Occurrs:  [1,1]                 Range:      [1,65535]           
    Values:  32
    ```

11. **`cwmin1`**: Defines the minimum contention window size in slots
    for category 1.
    
    ```no-highlighting
    Default: yes                   Required: no                    Modifiable: yes                 
    Type:    uint16                Occurrs:  [1,1]                 Range:      [1,65535]           
    Values:  32
    ```

12. **`cwmin2`**: Defines the minimum contention window size in slots
    for category 2.
    
    ```no-highlighting
    Default: yes                   Required: no                    Modifiable: yes                 
    Type:    uint16                Occurrs:  [1,1]                 Range:      [1,65535]           
    Values:  16
    ```

13. **`cwmin3`**: Defines the minimum contention window size in slots
    for category 3.
    
    ```no-highlighting
    Default: yes                   Required: no                    Modifiable: yes                 
    Type:    uint16                Occurrs:  [1,1]                 Range:      [1,65535]           
    Values:  8
    ```

14. **`distance`**: Defines the max propagation distance in meters
    used to compute slot size.
    
    ```no-highlighting
    Default: yes                   Required: no                    Modifiable: no                  
    Type:    uint32                Occurrs:  [1,1]                 Range:      [0,4294967295]      
    Values:  1000
    ```

15. **`enablepromiscuousmode`**: Defines whether promiscuous mode is
    enabled or not. If promiscuous mode is enabled, all received packets
    (intended for the given node or not) that pass the probability of
    reception check are sent upstream to the transport.
    
    ```no-highlighting
    Default: yes                   Required: no                    Modifiable: yes                 
    Type:    bool                  Occurrs:  [1,1]                 Range:      [false,true]        
    Values:  false
    ```

16. **`flowcontrolenable`**: Defines whether flow control is enabled.
    Flow control only works with the virtual transport and the setting
    must match the setting within the virtual transport configuration.
    
    ```no-highlighting
    Default: yes                   Required: no                    Modifiable: no                  
    Type:    bool                  Occurrs:  [1,1]                 Range:      [false,true]        
    Values:  false
    ```

17. **`flowcontroltokens`**: Defines the maximum number of flow
    control tokens (packet transmission units) that can be processed from
    the virtual transport without being refreshed. The number of available
    tokens at any given time is coordinated with the virtual transport and
    when the token count reaches zero, no further packets are transmitted
    causing application socket queues to backup.
    
    ```no-highlighting
    Default: yes                   Required: no                    Modifiable: no                  
    Type:    uint16                Occurrs:  [1,1]                 Range:      [1,65535]           
    Values:  10
    ```

18. **`mode`**: Defines the 802.11abg mode of operation.  0|2 =
    802.11b (DSS), 1 = 802.11a/g (OFDM), and 3 = 802.11b/g (mixed mode).
    
    ```no-highlighting
    Default: yes                   Required: no                    Modifiable: no                  
    Type:    uint8                 Occurrs:  [1,1]                 Range:      [0,3]               
    Values:  0
    ```

19. **`msdu0`**: MSDU category 0
    
    ```no-highlighting
    Default: yes                   Required: no                    Modifiable: no                  
    Type:    uint16                Occurrs:  [1,1]                 Range:      [0,65535]           
    Values:  65535
    ```

20. **`msdu1`**: MSDU category 1
    
    ```no-highlighting
    Default: yes                   Required: no                    Modifiable: no                  
    Type:    uint16                Occurrs:  [1,1]                 Range:      [0,65535]           
    Values:  65535
    ```

21. **`msdu2`**: MSDU category 2
    
    ```no-highlighting
    Default: yes                   Required: no                    Modifiable: no                  
    Type:    uint16                Occurrs:  [1,1]                 Range:      [0,65535]           
    Values:  65535
    ```

22. **`msdu3`**: MSDU category 3
    
    ```no-highlighting
    Default: yes                   Required: no                    Modifiable: no                  
    Type:    uint16                Occurrs:  [1,1]                 Range:      [0,65535]           
    Values:  65535
    ```

23. **`multicastrate`**: Defines the data rate to be used when
    transmitting broadcast/multicast packets. The index (1 through 12) to
    rate (Mbps) mapping is as follows: [1 2 5.5 11 6 9 12 18 24 36 48 54].
    DSS rates [1 2 5.5 11] Mbps are valid when mode is set to 802.11b or
    802.11b/g.  OFDM rates [6 9 12 18 24 36 48 54] Mbps are valid when
    mode is set to 802.11a/g or 802.11b/g.
    
    ```no-highlighting
    Default: yes                   Required: no                    Modifiable: yes                 
    Type:    uint8                 Occurrs:  [1,1]                 Range:      [1,12]              
    Values:  1
    ```

24. **`neighbormetricdeletetime`**: Defines the time in seconds of no
    RF receptions from a given neighbor before it is removed from the
    neighbor table.
    
    ```no-highlighting
    Default: yes                   Required: no                    Modifiable: no                  
    Type:    float                 Occurrs:  [1,1]                 Range:      [1.000000,3660.000000]
    Values:  60.000000
    ```

25. **`neighbortimeout`**: Defines the neighbor timeout in seconds for
    the neighbor estimation algorithm.
    
    ```no-highlighting
    Default: yes                   Required: no                    Modifiable: no                  
    Type:    float                 Occurrs:  [1,1]                 Range:      [0.000000,3600.000000]
    Values:  30.000000
    ```

26. **`pcrcurveuri`**: Defines the URI of the Packet Completion Rate
    (PCR) curve file. The PCR curve file contains probability of reception
    curves as a function of Signal to Interference plus Noise Ratio (SINR)
    for each data rate.
    
    ```no-highlighting
    Default: no                    Required: yes                   Modifiable: no                  
    Type:    string                Occurrs:  [1,1]               
    ```

27. **`queuesize0`**: Defines the queue size for category 0.
    
    ```no-highlighting
    Default: yes                   Required: no                    Modifiable: no                  
    Type:    uint8                 Occurrs:  [1,1]                 Range:      [0,255]             
    Values:  255
    ```

28. **`queuesize1`**: Defines the queue size for category 1.
    
    ```no-highlighting
    Default: yes                   Required: no                    Modifiable: no                  
    Type:    uint8                 Occurrs:  [1,1]                 Range:      [0,255]             
    Values:  255
    ```

29. **`queuesize2`**: Defines the queue size for category 2.
    
    ```no-highlighting
    Default: yes                   Required: no                    Modifiable: no                  
    Type:    uint8                 Occurrs:  [1,1]                 Range:      [0,255]             
    Values:  255
    ```

30. **`queuesize3`**: Defines the queue size for category 3.
    
    ```no-highlighting
    Default: yes                   Required: no                    Modifiable: no                  
    Type:    uint8                 Occurrs:  [1,1]                 Range:      [0,255]             
    Values:  255
    ```

31. **`radiometricenable`**: Defines if radio metrics will be reported
    up via the Radio to Router Interface (R2RI).
    
    ```no-highlighting
    Default: yes                   Required: no                    Modifiable: no                  
    Type:    bool                  Occurrs:  [1,1]                 Range:      [false,true]        
    Values:  false
    ```

32. **`radiometricreportinterval`**: Defines the  metric report
    interval in seconds in support of the R2RI feature.
    
    ```no-highlighting
    Default: yes                   Required: no                    Modifiable: no                  
    Type:    float                 Occurrs:  [1,1]                 Range:      [0.100000,60.000000]
    Values:  1.000000
    ```

33. **`retrylimit0`**: Defines the maximum number of retries attempted
    for category 0.
    
    ```no-highlighting
    Default: yes                   Required: no                    Modifiable: no                  
    Type:    uint8                 Occurrs:  [1,1]                 Range:      [0,255]             
    Values:  2
    ```

34. **`retrylimit1`**: Defines the maximum number of retries attempted
    for category 1.
    
    ```no-highlighting
    Default: yes                   Required: no                    Modifiable: no                  
    Type:    uint8                 Occurrs:  [1,1]                 Range:      [0,255]             
    Values:  2
    ```

35. **`retrylimit2`**: Defines the maximum number of retries attempted
    for category 2.
    
    ```no-highlighting
    Default: yes                   Required: no                    Modifiable: no                  
    Type:    uint8                 Occurrs:  [1,1]                 Range:      [0,255]             
    Values:  2
    ```

36. **`retrylimit3`**: Defines the maximum number of retries attempted
    for category 3.
    
    ```no-highlighting
    Default: yes                   Required: no                    Modifiable: no                  
    Type:    uint8                 Occurrs:  [1,1]                 Range:      [0,255]             
    Values:  2
    ```

37. **`rtsthreshold`**: Defines a threshold in bytes for when RTS/CTS
    is used as part of the carrier sensing channel access protocol when
    transmitting unicast packets.
    
    ```no-highlighting
    Default: yes                   Required: no                    Modifiable: no                  
    Type:    uint16                Occurrs:  [1,1]                 Range:      [0,65535]           
    Values:  255
    ```

38. **`txop0`**: Defines the transmit opportunity time for category 0.
    
    ```no-highlighting
    Default: yes                   Required: no                    Modifiable: no                  
    Type:    float                 Occurrs:  [1,1]                 Range:      [0.000000,1.000000] 
    Values:  0.000000
    ```

39. **`txop1`**: Defines the transmit opportunity time for category 1.
    
    ```no-highlighting
    Default: yes                   Required: no                    Modifiable: no                  
    Type:    float                 Occurrs:  [1,1]                 Range:      [0.000000,1.000000] 
    Values:  0.000000
    ```

40. **`txop2`**: Defines the transmit opportunity time for category 2.
    
    ```no-highlighting
    Default: yes                   Required: no                    Modifiable: no                  
    Type:    float                 Occurrs:  [1,1]                 Range:      [0.000000,1.000000] 
    Values:  0.000000
    ```

41. **`txop3`**: Defines the transmit opportunity time for category 3.
    
    ```no-highlighting
    Default: yes                   Required: no                    Modifiable: no                  
    Type:    float                 Occurrs:  [1,1]                 Range:      [0.000000,1.000000] 
    Values:  0.000000
    ```

42. **`unicastrate`**: Defines the data rate to be used when
    transmitting unicast packets. The index (1 through 12) to rate (Mbps)
    mapping is as follows: [1 2 5.5 11 6 9 12 18 24 36 48 54]. DSS rates
    [1 2 5.5 11] Mbps are valid when mode is set to 802.11b or 802.11b/g.
    OFDM rates [6 9 12 18 24 36 48 54] Mbps are valid when mode is set to
    802.11a/g or 802.11b/g.
    
    ```no-highlighting
    Default: yes                   Required: no                    Modifiable: yes                 
    Type:    uint8                 Occurrs:  [1,1]                 Range:      [1,12]              
    Values:  4
    ```

43. **`wmmenable`**: Defines if wireless multimedia mode (WMM) is
    enabled.
    
    ```no-highlighting
    Default: yes                   Required: no                    Modifiable: no                  
    Type:    bool                  Occurrs:  [1,1]                 Range:      [false,true]        
    Values:  false
    ```




## Statistics

1. **`avgDownstreamProcessingDelay0`**: Average downstream processing
   delay
   
   ```no-highlighting
   Type: float                 Clearable: yes                 
   ```

2. **`avgDownstreamProcessingDelay1`**: Average downstream processing
   delay
   
   ```no-highlighting
   Type: float                 Clearable: yes                 
   ```

3. **`avgDownstreamProcessingDelay2`**: Average downstream processing
   delay
   
   ```no-highlighting
   Type: float                 Clearable: yes                 
   ```

4. **`avgDownstreamProcessingDelay3`**: Average downstream processing
   delay
   
   ```no-highlighting
   Type: float                 Clearable: yes                 
   ```

5. **`avgProcessAPIQueueDepth`**: Average API queue depth for a
   processUpstreamPacket, processUpstreamControl,
   processDownstreamPacket, processDownstreamControl, processEvent and
   processTimedEvent.
   
   ```no-highlighting
   Type: double                Clearable: yes                 
   ```

6. **`avgProcessAPIQueueWait`**: Average API queue wait for a
   processUpstreamPacket, processUpstreamControl,
   processDownstreamPacket, processDownstreamControl, processEvent and
   processTimedEvent in microseconds.
   
   ```no-highlighting
   Type: double                Clearable: yes                 
   ```

7. **`avgTimedEventLatency`**: Average latency between the scheduled
   timer expiration and the actual firing over the requested duration.
   
   ```no-highlighting
   Type: double                Clearable: yes                 
   ```

8. **`avgTimedEventLatencyRatio`**: Average ratio of the delta between
   the scheduled timer expiration and the actual firing over the
   requested duration. An average ratio approaching 1 indicates that
   timer latencies are large in comparison to the requested durations.
   
   ```no-highlighting
   Type: double                Clearable: yes                 
   ```

9. **`avgUpstreamProcessingDelay0`**: Average upstream processing
   delay
   
   ```no-highlighting
   Type: float                 Clearable: yes                 
   ```

10. **`avgUpstreamProcessingDelay1`**: Average upstream processing
    delay
    
    ```no-highlighting
    Type: float                 Clearable: yes                 
    ```

11. **`avgUpstreamProcessingDelay2`**: Average upstream processing
    delay
    
    ```no-highlighting
    Type: float                 Clearable: yes                 
    ```

12. **`avgUpstreamProcessingDelay3`**: Average upstream processing
    delay
    
    ```no-highlighting
    Type: float                 Clearable: yes                 
    ```

13. **`numAPIQueued`**: The number of queued API events.
    
    ```no-highlighting
    Type: uint64                Clearable: yes                 
    ```

14. **`numBroadcastBytesTooLarge0`**:
    
    ```no-highlighting
    Type: uint32                Clearable: yes                 
    ```

15. **`numBroadcastBytesTooLarge1`**:
    
    ```no-highlighting
    Type: uint32                Clearable: yes                 
    ```

16. **`numBroadcastBytesTooLarge2`**:
    
    ```no-highlighting
    Type: uint32                Clearable: yes                 
    ```

17. **`numBroadcastBytesTooLarge3`**:
    
    ```no-highlighting
    Type: uint32                Clearable: yes                 
    ```

18. **`numBroadcastBytesUnsupported`**:
    
    ```no-highlighting
    Type: uint32                Clearable: yes                 
    ```

19. **`numBroadcastPacketsTooLarge0`**:
    
    ```no-highlighting
    Type: uint32                Clearable: yes                 
    ```

20. **`numBroadcastPacketsTooLarge1`**:
    
    ```no-highlighting
    Type: uint32                Clearable: yes                 
    ```

21. **`numBroadcastPacketsTooLarge2`**:
    
    ```no-highlighting
    Type: uint32                Clearable: yes                 
    ```

22. **`numBroadcastPacketsTooLarge3`**:
    
    ```no-highlighting
    Type: uint32                Clearable: yes                 
    ```

23. **`numBroadcastPacketsUnsupported`**:
    
    ```no-highlighting
    Type: uint32                Clearable: yes                 
    ```

24. **`numDownstreamBroadcastDataDiscardDueToTxop`**:
    
    ```no-highlighting
    Type: uint32                Clearable: yes                 
    ```

25. **`numDownstreamBytesBroadcastGenerated0`**: Number of layer
    generated downstream broadcast bytes
    
    ```no-highlighting
    Type: uint64                Clearable: yes                 
    ```

26. **`numDownstreamBytesBroadcastGenerated1`**: Number of layer
    generated downstream broadcast bytes
    
    ```no-highlighting
    Type: uint64                Clearable: yes                 
    ```

27. **`numDownstreamBytesBroadcastGenerated2`**: Number of layer
    generated downstream broadcast bytes
    
    ```no-highlighting
    Type: uint64                Clearable: yes                 
    ```

28. **`numDownstreamBytesBroadcastGenerated3`**: Number of layer
    generated downstream broadcast bytes
    
    ```no-highlighting
    Type: uint64                Clearable: yes                 
    ```

29. **`numDownstreamBytesBroadcastRx0`**: Number of downstream
    broadcast bytes received
    
    ```no-highlighting
    Type: uint64                Clearable: yes                 
    ```

30. **`numDownstreamBytesBroadcastRx1`**: Number of downstream
    broadcast bytes received
    
    ```no-highlighting
    Type: uint64                Clearable: yes                 
    ```

31. **`numDownstreamBytesBroadcastRx2`**: Number of downstream
    broadcast bytes received
    
    ```no-highlighting
    Type: uint64                Clearable: yes                 
    ```

32. **`numDownstreamBytesBroadcastRx3`**: Number of downstream
    broadcast bytes received
    
    ```no-highlighting
    Type: uint64                Clearable: yes                 
    ```

33. **`numDownstreamBytesBroadcastTx0`**: Number of downstream
    broadcast bytes transmitted
    
    ```no-highlighting
    Type: uint64                Clearable: yes                 
    ```

34. **`numDownstreamBytesBroadcastTx1`**: Number of downstream
    broadcast bytes transmitted
    
    ```no-highlighting
    Type: uint64                Clearable: yes                 
    ```

35. **`numDownstreamBytesBroadcastTx2`**: Number of downstream
    broadcast bytes transmitted
    
    ```no-highlighting
    Type: uint64                Clearable: yes                 
    ```

36. **`numDownstreamBytesBroadcastTx3`**: Number of downstream
    broadcast bytes transmitted
    
    ```no-highlighting
    Type: uint64                Clearable: yes                 
    ```

37. **`numDownstreamBytesUnicastGenerated0`**: Number of layer
    generated downstream unicast bytes
    
    ```no-highlighting
    Type: uint64                Clearable: yes                 
    ```

38. **`numDownstreamBytesUnicastGenerated1`**: Number of layer
    generated downstream unicast bytes
    
    ```no-highlighting
    Type: uint64                Clearable: yes                 
    ```

39. **`numDownstreamBytesUnicastGenerated2`**: Number of layer
    generated downstream unicast bytes
    
    ```no-highlighting
    Type: uint64                Clearable: yes                 
    ```

40. **`numDownstreamBytesUnicastGenerated3`**: Number of layer
    generated downstream unicast bytes
    
    ```no-highlighting
    Type: uint64                Clearable: yes                 
    ```

41. **`numDownstreamBytesUnicastRx0`**: Number of downstream unicast
    bytes received
    
    ```no-highlighting
    Type: uint64                Clearable: yes                 
    ```

42. **`numDownstreamBytesUnicastRx1`**: Number of downstream unicast
    bytes received
    
    ```no-highlighting
    Type: uint64                Clearable: yes                 
    ```

43. **`numDownstreamBytesUnicastRx2`**: Number of downstream unicast
    bytes received
    
    ```no-highlighting
    Type: uint64                Clearable: yes                 
    ```

44. **`numDownstreamBytesUnicastRx3`**: Number of downstream unicast
    bytes received
    
    ```no-highlighting
    Type: uint64                Clearable: yes                 
    ```

45. **`numDownstreamBytesUnicastTx0`**: Number of downstream unicast
    bytes transmitted
    
    ```no-highlighting
    Type: uint64                Clearable: yes                 
    ```

46. **`numDownstreamBytesUnicastTx1`**: Number of downstream unicast
    bytes transmitted
    
    ```no-highlighting
    Type: uint64                Clearable: yes                 
    ```

47. **`numDownstreamBytesUnicastTx2`**: Number of downstream unicast
    bytes transmitted
    
    ```no-highlighting
    Type: uint64                Clearable: yes                 
    ```

48. **`numDownstreamBytesUnicastTx3`**: Number of downstream unicast
    bytes transmitted
    
    ```no-highlighting
    Type: uint64                Clearable: yes                 
    ```

49. **`numDownstreamPacketsBroadcastDrop0`**: Number of downstream
    broadcast packets dropped
    
    ```no-highlighting
    Type: uint64                Clearable: yes                 
    ```

50. **`numDownstreamPacketsBroadcastDrop1`**: Number of downstream
    broadcast packets dropped
    
    ```no-highlighting
    Type: uint64                Clearable: yes                 
    ```

51. **`numDownstreamPacketsBroadcastDrop2`**: Number of downstream
    broadcast packets dropped
    
    ```no-highlighting
    Type: uint64                Clearable: yes                 
    ```

52. **`numDownstreamPacketsBroadcastDrop3`**: Number of downstream
    broadcast packets dropped
    
    ```no-highlighting
    Type: uint64                Clearable: yes                 
    ```

53. **`numDownstreamPacketsBroadcastGenerated0`**: Number of layer
    generated downstream broadcast packets
    
    ```no-highlighting
    Type: uint64                Clearable: yes                 
    ```

54. **`numDownstreamPacketsBroadcastGenerated1`**: Number of layer
    generated downstream broadcast packets
    
    ```no-highlighting
    Type: uint64                Clearable: yes                 
    ```

55. **`numDownstreamPacketsBroadcastGenerated2`**: Number of layer
    generated downstream broadcast packets
    
    ```no-highlighting
    Type: uint64                Clearable: yes                 
    ```

56. **`numDownstreamPacketsBroadcastGenerated3`**: Number of layer
    generated downstream broadcast packets
    
    ```no-highlighting
    Type: uint64                Clearable: yes                 
    ```

57. **`numDownstreamPacketsBroadcastRx0`**: Number of downstream
    broadcast packets received
    
    ```no-highlighting
    Type: uint64                Clearable: yes                 
    ```

58. **`numDownstreamPacketsBroadcastRx1`**: Number of downstream
    broadcast packets received
    
    ```no-highlighting
    Type: uint64                Clearable: yes                 
    ```

59. **`numDownstreamPacketsBroadcastRx2`**: Number of downstream
    broadcast packets received
    
    ```no-highlighting
    Type: uint64                Clearable: yes                 
    ```

60. **`numDownstreamPacketsBroadcastRx3`**: Number of downstream
    broadcast packets received
    
    ```no-highlighting
    Type: uint64                Clearable: yes                 
    ```

61. **`numDownstreamPacketsBroadcastTx0`**: Number of downstream
    broadcast packets transmitted
    
    ```no-highlighting
    Type: uint64                Clearable: yes                 
    ```

62. **`numDownstreamPacketsBroadcastTx1`**: Number of downstream
    broadcast packets transmitted
    
    ```no-highlighting
    Type: uint64                Clearable: yes                 
    ```

63. **`numDownstreamPacketsBroadcastTx2`**: Number of downstream
    broadcast packets transmitted
    
    ```no-highlighting
    Type: uint64                Clearable: yes                 
    ```

64. **`numDownstreamPacketsBroadcastTx3`**: Number of downstream
    broadcast packets transmitted
    
    ```no-highlighting
    Type: uint64                Clearable: yes                 
    ```

65. **`numDownstreamPacketsUnicastDrop0`**: Number of downstream
    unicast packets dropped
    
    ```no-highlighting
    Type: uint64                Clearable: yes                 
    ```

66. **`numDownstreamPacketsUnicastDrop1`**: Number of downstream
    unicast packets dropped
    
    ```no-highlighting
    Type: uint64                Clearable: yes                 
    ```

67. **`numDownstreamPacketsUnicastDrop2`**: Number of downstream
    unicast packets dropped
    
    ```no-highlighting
    Type: uint64                Clearable: yes                 
    ```

68. **`numDownstreamPacketsUnicastDrop3`**: Number of downstream
    unicast packets dropped
    
    ```no-highlighting
    Type: uint64                Clearable: yes                 
    ```

69. **`numDownstreamPacketsUnicastGenerated0`**: Number of layer
    generated downstream unicast packets
    
    ```no-highlighting
    Type: uint64                Clearable: yes                 
    ```

70. **`numDownstreamPacketsUnicastGenerated1`**: Number of layer
    generated downstream unicast packets
    
    ```no-highlighting
    Type: uint64                Clearable: yes                 
    ```

71. **`numDownstreamPacketsUnicastGenerated2`**: Number of layer
    generated downstream unicast packets
    
    ```no-highlighting
    Type: uint64                Clearable: yes                 
    ```

72. **`numDownstreamPacketsUnicastGenerated3`**: Number of layer
    generated downstream unicast packets
    
    ```no-highlighting
    Type: uint64                Clearable: yes                 
    ```

73. **`numDownstreamPacketsUnicastRx0`**: Number of downstream unicast
    packets received
    
    ```no-highlighting
    Type: uint64                Clearable: yes                 
    ```

74. **`numDownstreamPacketsUnicastRx1`**: Number of downstream unicast
    packets received
    
    ```no-highlighting
    Type: uint64                Clearable: yes                 
    ```

75. **`numDownstreamPacketsUnicastRx2`**: Number of downstream unicast
    packets received
    
    ```no-highlighting
    Type: uint64                Clearable: yes                 
    ```

76. **`numDownstreamPacketsUnicastRx3`**: Number of downstream unicast
    packets received
    
    ```no-highlighting
    Type: uint64                Clearable: yes                 
    ```

77. **`numDownstreamPacketsUnicastTx0`**: Number of downstream unicast
    packets transmitted
    
    ```no-highlighting
    Type: uint64                Clearable: yes                 
    ```

78. **`numDownstreamPacketsUnicastTx1`**: Number of downstream unicast
    packets transmitted
    
    ```no-highlighting
    Type: uint64                Clearable: yes                 
    ```

79. **`numDownstreamPacketsUnicastTx2`**: Number of downstream unicast
    packets transmitted
    
    ```no-highlighting
    Type: uint64                Clearable: yes                 
    ```

80. **`numDownstreamPacketsUnicastTx3`**: Number of downstream unicast
    packets transmitted
    
    ```no-highlighting
    Type: uint64                Clearable: yes                 
    ```

81. **`numDownstreamUnicastDataDiscardDueToRetries`**:
    
    ```no-highlighting
    Type: uint32                Clearable: yes                 
    ```

82. **`numDownstreamUnicastDataDiscardDueToTxop`**:
    
    ```no-highlighting
    Type: uint32                Clearable: yes                 
    ```

83. **`numDownstreamUnicastRtsCtsDataDiscardDueToRetries`**:
    
    ```no-highlighting
    Type: uint32                Clearable: yes                 
    ```

84. **`numHighWaterMark0`**:
    
    ```no-highlighting
    Type: uint32                Clearable: yes                 
    ```

85. **`numHighWaterMark1`**:
    
    ```no-highlighting
    Type: uint32                Clearable: yes                 
    ```

86. **`numHighWaterMark2`**:
    
    ```no-highlighting
    Type: uint32                Clearable: yes                 
    ```

87. **`numHighWaterMark3`**:
    
    ```no-highlighting
    Type: uint32                Clearable: yes                 
    ```

88. **`numHighWaterMax0`**:
    
    ```no-highlighting
    Type: uint32                Clearable: yes                 
    ```

89. **`numHighWaterMax1`**:
    
    ```no-highlighting
    Type: uint32                Clearable: yes                 
    ```

90. **`numHighWaterMax2`**:
    
    ```no-highlighting
    Type: uint32                Clearable: yes                 
    ```

91. **`numHighWaterMax3`**:
    
    ```no-highlighting
    Type: uint32                Clearable: yes                 
    ```

92. **`numOneHopNbrHighWaterMark`**:
    
    ```no-highlighting
    Type: uint32                Clearable: yes                 
    ```

93. **`numRxOneHopNbrListEvents`**:
    
    ```no-highlighting
    Type: uint32                Clearable: yes                 
    ```

94. **`numRxOneHopNbrListInvalidEvents`**:
    
    ```no-highlighting
    Type: uint32                Clearable: yes                 
    ```

95. **`numTwoHopNbrHighWaterMark`**:
    
    ```no-highlighting
    Type: uint32                Clearable: yes                 
    ```

96. **`numTxOneHopNbrListEvents`**:
    
    ```no-highlighting
    Type: uint32                Clearable: yes                 
    ```

97. **`numUnicastBytesTooLarge0`**:
    
    ```no-highlighting
    Type: uint32                Clearable: yes                 
    ```

98. **`numUnicastBytesTooLarge1`**:
    
    ```no-highlighting
    Type: uint32                Clearable: yes                 
    ```

99. **`numUnicastBytesTooLarge2`**:
    
    ```no-highlighting
    Type: uint32                Clearable: yes                 
    ```

100. **`numUnicastBytesTooLarge3`**:
     
     ```no-highlighting
     Type: uint32                Clearable: yes                 
     ```

101. **`numUnicastBytesUnsupported`**:
     
     ```no-highlighting
     Type: uint32                Clearable: yes                 
     ```

102. **`numUnicastPacketsTooLarge0`**:
     
     ```no-highlighting
     Type: uint32                Clearable: yes                 
     ```

103. **`numUnicastPacketsTooLarge1`**:
     
     ```no-highlighting
     Type: uint32                Clearable: yes                 
     ```

104. **`numUnicastPacketsTooLarge2`**:
     
     ```no-highlighting
     Type: uint32                Clearable: yes                 
     ```

105. **`numUnicastPacketsTooLarge3`**:
     
     ```no-highlighting
     Type: uint32                Clearable: yes                 
     ```

106. **`numUnicastPacketsUnsupported`**:
     
     ```no-highlighting
     Type: uint32                Clearable: yes                 
     ```

107. **`numUpstreamBroadcastDataDiscardDueToClobberRxDuringTx`**:
     
     ```no-highlighting
     Type: uint32                Clearable: yes                 
     ```

108. **`numUpstreamBroadcastDataDiscardDueToClobberRxHiddenBusy`**:
     
     ```no-highlighting
     Type: uint32                Clearable: yes                 
     ```

109. **`numUpstreamBroadcastDataDiscardDueToSinr`**:
     
     ```no-highlighting
     Type: uint32                Clearable: yes                 
     ```

110. **`numUpstreamBroadcastDataNoiseHiddenRx`**:
     
     ```no-highlighting
     Type: uint32                Clearable: yes                 
     ```

111. **`numUpstreamBroadcastDataNoiseRxCommon`**:
     
     ```no-highlighting
     Type: uint32                Clearable: yes                 
     ```

112. **`numUpstreamBytesBroadcastRx0`**: Number of upstream broadcast
     bytes received
     
     ```no-highlighting
     Type: uint64                Clearable: yes                 
     ```

113. **`numUpstreamBytesBroadcastRx1`**: Number of upstream broadcast
     bytes received
     
     ```no-highlighting
     Type: uint64                Clearable: yes                 
     ```

114. **`numUpstreamBytesBroadcastRx2`**: Number of upstream broadcast
     bytes received
     
     ```no-highlighting
     Type: uint64                Clearable: yes                 
     ```

115. **`numUpstreamBytesBroadcastRx3`**: Number of upstream broadcast
     bytes received
     
     ```no-highlighting
     Type: uint64                Clearable: yes                 
     ```

116. **`numUpstreamBytesBroadcastTx0`**: Number of updtream broadcast
     bytes transmitted
     
     ```no-highlighting
     Type: uint64                Clearable: yes                 
     ```

117. **`numUpstreamBytesBroadcastTx1`**: Number of updtream broadcast
     bytes transmitted
     
     ```no-highlighting
     Type: uint64                Clearable: yes                 
     ```

118. **`numUpstreamBytesBroadcastTx2`**: Number of updtream broadcast
     bytes transmitted
     
     ```no-highlighting
     Type: uint64                Clearable: yes                 
     ```

119. **`numUpstreamBytesBroadcastTx3`**: Number of updtream broadcast
     bytes transmitted
     
     ```no-highlighting
     Type: uint64                Clearable: yes                 
     ```

120. **`numUpstreamBytesUnicastRx0`**: Number upstream unicast bytes
     received
     
     ```no-highlighting
     Type: uint64                Clearable: yes                 
     ```

121. **`numUpstreamBytesUnicastRx1`**: Number upstream unicast bytes
     received
     
     ```no-highlighting
     Type: uint64                Clearable: yes                 
     ```

122. **`numUpstreamBytesUnicastRx2`**: Number upstream unicast bytes
     received
     
     ```no-highlighting
     Type: uint64                Clearable: yes                 
     ```

123. **`numUpstreamBytesUnicastRx3`**: Number upstream unicast bytes
     received
     
     ```no-highlighting
     Type: uint64                Clearable: yes                 
     ```

124. **`numUpstreamBytesUnicastTx0`**: Number of upstream unicast
     bytes transmitted
     
     ```no-highlighting
     Type: uint64                Clearable: yes                 
     ```

125. **`numUpstreamBytesUnicastTx1`**: Number of upstream unicast
     bytes transmitted
     
     ```no-highlighting
     Type: uint64                Clearable: yes                 
     ```

126. **`numUpstreamBytesUnicastTx2`**: Number of upstream unicast
     bytes transmitted
     
     ```no-highlighting
     Type: uint64                Clearable: yes                 
     ```

127. **`numUpstreamBytesUnicastTx3`**: Number of upstream unicast
     bytes transmitted
     
     ```no-highlighting
     Type: uint64                Clearable: yes                 
     ```

128. **`numUpstreamPacketsBroadcastDrop0`**: Number of upstream
     broadcast packets dropped
     
     ```no-highlighting
     Type: uint64                Clearable: yes                 
     ```

129. **`numUpstreamPacketsBroadcastDrop1`**: Number of upstream
     broadcast packets dropped
     
     ```no-highlighting
     Type: uint64                Clearable: yes                 
     ```

130. **`numUpstreamPacketsBroadcastDrop2`**: Number of upstream
     broadcast packets dropped
     
     ```no-highlighting
     Type: uint64                Clearable: yes                 
     ```

131. **`numUpstreamPacketsBroadcastDrop3`**: Number of upstream
     broadcast packets dropped
     
     ```no-highlighting
     Type: uint64                Clearable: yes                 
     ```

132. **`numUpstreamPacketsBroadcastRx0`**: Number of upstream
     broadcast packets received
     
     ```no-highlighting
     Type: uint64                Clearable: yes                 
     ```

133. **`numUpstreamPacketsBroadcastRx1`**: Number of upstream
     broadcast packets received
     
     ```no-highlighting
     Type: uint64                Clearable: yes                 
     ```

134. **`numUpstreamPacketsBroadcastRx2`**: Number of upstream
     broadcast packets received
     
     ```no-highlighting
     Type: uint64                Clearable: yes                 
     ```

135. **`numUpstreamPacketsBroadcastRx3`**: Number of upstream
     broadcast packets received
     
     ```no-highlighting
     Type: uint64                Clearable: yes                 
     ```

136. **`numUpstreamPacketsBroadcastTx0`**: Number of upstream
     broadcast packets transmitted
     
     ```no-highlighting
     Type: uint64                Clearable: yes                 
     ```

137. **`numUpstreamPacketsBroadcastTx1`**: Number of upstream
     broadcast packets transmitted
     
     ```no-highlighting
     Type: uint64                Clearable: yes                 
     ```

138. **`numUpstreamPacketsBroadcastTx2`**: Number of upstream
     broadcast packets transmitted
     
     ```no-highlighting
     Type: uint64                Clearable: yes                 
     ```

139. **`numUpstreamPacketsBroadcastTx3`**: Number of upstream
     broadcast packets transmitted
     
     ```no-highlighting
     Type: uint64                Clearable: yes                 
     ```

140. **`numUpstreamPacketsUnicastDrop0`**: Number of upstream unicast
     packets dropped
     
     ```no-highlighting
     Type: uint64                Clearable: yes                 
     ```

141. **`numUpstreamPacketsUnicastDrop1`**: Number of upstream unicast
     packets dropped
     
     ```no-highlighting
     Type: uint64                Clearable: yes                 
     ```

142. **`numUpstreamPacketsUnicastDrop2`**: Number of upstream unicast
     packets dropped
     
     ```no-highlighting
     Type: uint64                Clearable: yes                 
     ```

143. **`numUpstreamPacketsUnicastDrop3`**: Number of upstream unicast
     packets dropped
     
     ```no-highlighting
     Type: uint64                Clearable: yes                 
     ```

144. **`numUpstreamPacketsUnicastRx0`**: Number upstream unicast
     packets received
     
     ```no-highlighting
     Type: uint64                Clearable: yes                 
     ```

145. **`numUpstreamPacketsUnicastRx1`**: Number upstream unicast
     packets received
     
     ```no-highlighting
     Type: uint64                Clearable: yes                 
     ```

146. **`numUpstreamPacketsUnicastRx2`**: Number upstream unicast
     packets received
     
     ```no-highlighting
     Type: uint64                Clearable: yes                 
     ```

147. **`numUpstreamPacketsUnicastRx3`**: Number upstream unicast
     packets received
     
     ```no-highlighting
     Type: uint64                Clearable: yes                 
     ```

148. **`numUpstreamPacketsUnicastTx0`**: Number of upstream unicast
     packets transmitted
     
     ```no-highlighting
     Type: uint64                Clearable: yes                 
     ```

149. **`numUpstreamPacketsUnicastTx1`**: Number of upstream unicast
     packets transmitted
     
     ```no-highlighting
     Type: uint64                Clearable: yes                 
     ```

150. **`numUpstreamPacketsUnicastTx2`**: Number of upstream unicast
     packets transmitted
     
     ```no-highlighting
     Type: uint64                Clearable: yes                 
     ```

151. **`numUpstreamPacketsUnicastTx3`**: Number of upstream unicast
     packets transmitted
     
     ```no-highlighting
     Type: uint64                Clearable: yes                 
     ```

152. **`numUpstreamUnicastDataDiscardDueToClobberRxDuringTx`**:
     
     ```no-highlighting
     Type: uint32                Clearable: yes                 
     ```

153. **`numUpstreamUnicastDataDiscardDueToClobberRxHiddenBusy`**:
     
     ```no-highlighting
     Type: uint32                Clearable: yes                 
     ```

154. **`numUpstreamUnicastDataDiscardDueToSinr`**:
     
     ```no-highlighting
     Type: uint32                Clearable: yes                 
     ```

155. **`numUpstreamUnicastDataNoiseHiddenRx`**:
     
     ```no-highlighting
     Type: uint32                Clearable: yes                 
     ```

156. **`numUpstreamUnicastDataNoiseRxCommon`**:
     
     ```no-highlighting
     Type: uint32                Clearable: yes                 
     ```

157. **`numUpstreamUnicastRtsCtsDataRxFromPhy`**:
     
     ```no-highlighting
     Type: uint32                Clearable: yes                 
     ```

158. **`numUpstreamUnicastRtsCtsRxFromPhy`**:
     
     ```no-highlighting
     Type: uint32                Clearable: yes                 
     ```

159. **`processedConfiguration`**: The number of processed
     configuration.
     
     ```no-highlighting
     Type: uint64                Clearable: yes                 
     ```

160. **`processedDownstreamControl`**: The number of processed
     downstream control.
     
     ```no-highlighting
     Type: uint64                Clearable: yes                 
     ```

161. **`processedDownstreamPackets`**: The number of processed
     downstream packets.
     
     ```no-highlighting
     Type: uint64                Clearable: yes                 
     ```

162. **`processedEvents`**: The number of processed events.
     
     ```no-highlighting
     Type: uint64                Clearable: yes                 
     ```

163. **`processedTimedEvents`**: The number of processed timed events.
     
     ```no-highlighting
     Type: uint64                Clearable: yes                 
     ```

164. **`processedUpstreamControl`**: The number of processed upstream
     control.
     
     ```no-highlighting
     Type: uint64                Clearable: yes                 
     ```

165. **`processedUpstreamPackets`**: The number of processed upstream
     packets.
     
     ```no-highlighting
     Type: uint64                Clearable: yes                 
     ```




## Statistic Tables

1. **`BroadcastPacketAcceptTable0`**: Broadcast packets accepted
   
   ```no-highlighting
   Clearable:  yes
   ```

2. **`BroadcastPacketAcceptTable1`**: Broadcast packets accepted
   
   ```no-highlighting
   Clearable:  yes
   ```

3. **`BroadcastPacketAcceptTable2`**: Broadcast packets accepted
   
   ```no-highlighting
   Clearable:  yes
   ```

4. **`BroadcastPacketAcceptTable3`**: Broadcast packets accepted
   
   ```no-highlighting
   Clearable:  yes
   ```

5. **`BroadcastPacketDropTable0`**: Broadcast packets dropped by
   reason code
   
   ```no-highlighting
   Clearable:  yes
   ```

6. **`BroadcastPacketDropTable1`**: Broadcast packets dropped by
   reason code
   
   ```no-highlighting
   Clearable:  yes
   ```

7. **`BroadcastPacketDropTable2`**: Broadcast packets dropped by
   reason code
   
   ```no-highlighting
   Clearable:  yes
   ```

8. **`BroadcastPacketDropTable3`**: Broadcast packets dropped by
   reason code
   
   ```no-highlighting
   Clearable:  yes
   ```

9. **`EventReceptionTable`**: Received event counts
   
   ```no-highlighting
   Clearable:  yes
   ```

10. **`NeighborMetricTable`**: Neighbor Metric Table
    
    ```no-highlighting
    Clearable:  no
    ```

11. **`NeighborStatusTable`**: Neighbor Status Table
    
    ```no-highlighting
    Clearable:  no
    ```

12. **`OneHopNeighborTable`**: Current One Hop Neighbors
    
    ```no-highlighting
    Clearable:  no
    ```

13. **`TwoHopNeighborTable`**: Current Two Hop Neighbors
    
    ```no-highlighting
    Clearable:  no
    ```

14. **`UnicastPacketAcceptTable0`**: Unicast packets accepted
    
    ```no-highlighting
    Clearable:  yes
    ```

15. **`UnicastPacketAcceptTable1`**: Unicast packets accepted
    
    ```no-highlighting
    Clearable:  yes
    ```

16. **`UnicastPacketAcceptTable2`**: Unicast packets accepted
    
    ```no-highlighting
    Clearable:  yes
    ```

17. **`UnicastPacketAcceptTable3`**: Unicast packets accepted
    
    ```no-highlighting
    Clearable:  yes
    ```

18. **`UnicastPacketDropTable0`**: Unicast packets dropped by reason
    code
    
    ```no-highlighting
    Clearable:  yes
    ```

19. **`UnicastPacketDropTable1`**: Unicast packets dropped by reason
    code
    
    ```no-highlighting
    Clearable:  yes
    ```

20. **`UnicastPacketDropTable2`**: Unicast packets dropped by reason
    code
    
    ```no-highlighting
    Clearable:  yes
    ```

21. **`UnicastPacketDropTable3`**: Unicast packets dropped by reason
    code
    
    ```no-highlighting
    Clearable:  yes
    ```



## Examples

This guide includes the IEEE 802.11abg example:

1. `ieee80211abg-01`: A three node example using precomputed pathloss and
   running the B.A.T.M.A.N manet protocol with a jammer and monitor node.

### ieee80211abg-01

![](images/auto-generated-topology-ieee80211abg-01.png){: width="65%"; .centered}
<p style="text-align:center;font-size:75%">ieee80211abg-01 experiment components: Three nodes with one host each, monitor node, and jammer node.</p><br>

The `ieee80211abg-01` example contains three nodes, each with a host
hanging off their respective `lan0` interface, a jammer node, and
monitor node.

All physical layers are configured to use the `precomputed` propagation
model and `emaneeventservice` publishes [`PathlossEvents`](events#pathlossevent)
using the values in `pathloss.eel`.

```text
0.0  nem:1 pathloss nem:2,70
0.0  nem:1 pathloss nem:3,75
0.0  nem:1 pathloss nem:4,70
0.0  nem:1 pathloss nem:5,70

0.0  nem:2 pathloss nem:3,70
0.0  nem:2 pathloss nem:4,70
0.0  nem:2 pathloss nem:5,70

0.0  nem:3 pathloss nem:4,70
0.0  nem:3 pathloss nem:5,70

0.0  nem:4 pathloss nem:5,70
```
<p style="float:right;font-family:courier;font-size:75%">emane-guide/examples/ieee80211abg-01/pathloss.eel</p><br>

![](images/auto-generated-run-ieee80211abg-01.png){: width="75%"; .centered}

With `emane-guide/examples/ieee80211abg-01` running, we can use
`otestpoint-labtools-mtabletool` to subscribe to all
`EMANE.IEEE80211abg.Tables.Neighbor` probes, and build a combined
Neighbor interval average SINR table showing the number of received
packets in each measurement interval and the measurement interval
average computed from long running averages of SINR.

```text
$ otestpoint-labtools-mtabletool \
   localhost:9002 \
   Measurement_emane_ieee80211abg_tables_neighbor@neighbormetrictable \
   EMANE.IEEE80211abg.Tables.Neighbor \
   --actions \
   "pass(c=(0));" \
   "delta(c=(1))=>|{}_intvl|;" \
   "iavg(c=(7),n=(1))=>|{}_intvl|;"
```

The displayed combined neighbor interval average SINR table shows a
lower SINR between `node-1` and `node-3` due to the higher pathloss
between the nodes, 75dB, as compared to 70dB between all other nodes.

```text
 Measurement_emane_ieee80211abg_tables_neighbor@neighbormetrictable
   _Publisher    NEM  Rx Pkts_intvl  SINR Avg_intvl
0     node-1      2             29         26.9897
1     node-1      3             29         21.9897
2     node-1  65535              0             NaN
3     node-2      1             29         26.9897
4     node-2      3             29         26.9897
5     node-2  65535              0             NaN
6     node-3      1             29         21.9897
7     node-3      2             29         26.9897
8     node-3  65535              0             NaN
 ```

We can monitor the B.A.T.M.A.N. Next Hop Matrix using
`batman-nexthop-monitor.py`.

```text
$ ~/dev/emane-guide/examples/scripts/batman-nexthop-monitor.py 3
```

The displayed matrix shows the node reporting it's next hops
(`Reporter`) followed by column for each final destination, where '`--`'
indicates the self-identify entry, '`*`' indicates the final destination
is the next hop, and a *node id* indicates the next hop to the
destination.

```text
== B.A.T.M.A.N. Next Hop Matrix ==
+----------------+----------+----------+----------+
|    Reporter    |    1     |    2     |    3     |
+----------------+----------+----------+----------+
|       1        |    --    |    *     |    *     |
|       2        |    *     |    --    |    *     |
|       3        |    *     |    *     |    --    |
+----------------+----------+----------+----------+
```

As shown, the network is fully informed with all nodes a single hop
from each other.

Using `emane-jammer-simple-control`, we can instruct the jammer,
`node-4`, to create a continuous tone centered at 2.39GHz with a 20MHz
(default) bandwidth, and -20dBm transmit power.

```text
$ emane-jammer-simple-control -v node-4:45715 on 4 2390000000,-20 -a omni
```

The resulting tone can be viewed using the monitor, `node-5`, and
`emane-spectrum-analyzer`.

```text
$ emane-spectrum-analyzer \
    10.99.0.5:8883 \
    -100 \
    --with-waveforms \
    --hz-min 2350000000 \
    --hz-max 2500000000 \
    --subid-name 1,IEEE802.11
```

![](images/ieee80211abg-01-emane-spectrum-monitor.png){:width="75%"; .centered}
<p style="text-align:center;font-size:75%">Monitor view of spectrum during jamming activity.</p><br>

From the combined neighbor interval average SINR table, we can see
that the SINR between all nodes drops by ~4dB.

```text
  _Publisher    NEM  Rx Pkts_intvl  SINR Avg_intvl
0     node-1      2             30         23.0103
1     node-1      3             29         18.0103
2     node-1  65535              0             NaN
3     node-2      1             30         23.0103
4     node-2      3             29         23.0103
5     node-2  65535              0             NaN
6     node-3      1             30         18.0103
7     node-3      2             30         23.0103
8     node-3  65535              0             NaN
  ```

For `node-1` and `node-3` this drop in SINR has big implications when
running at 54Mbps.

```text
$ emanesh node-1 get config nems mac mode unicastrate multicastrate
nem 1   mac  mode = 3
nem 1   mac  multicastrate = 12
nem 1   mac  unicastrate = 12
```

Since the bidirectional link between `node-1` and `node-3` started at
a higher pathloss, the change in SINR from 21.9dB to 18.01dB results
in a probability of reception of almost 0. This can be verified by
consulting
`emane-guide/examples/rfpipe-01/node-1/emane-ieee80211abg-pcr.xml`.

All nodes in this example are using the same PCR definitions. For
54Mbps, an SINR of 21dB results in 71.3% probability of reception and an
SINR of 18dB results in 0.2% probability of reception.

This can be seen in the B.A.T.M.A.N. Next Hop Matrix, where now
`node-1` and `node-3` must hop through `node-2` in order to complete
traffic.



```text
== B.A.T.M.A.N. Next Hop Matrix ==
+----------------+----------+----------+----------+
|    Reporter    |    1     |    2     |    3     |
+----------------+----------+----------+----------+
|       1        |    --    |    *     |    2     |
|       2        |    *     |    --    |    *     |
|       3        |    2     |    *     |    --    |
+----------------+----------+----------+----------+
```

One way to restore single hop connectivity between `node-1` and
`node-3` is to reduce their data rate, which causes a different PCR
curve to be used. Setting both nodes to 36Mbps will result in 100%
probability of reception for SINR greater than or equal to 18dB.

```text
$ emanesh node-1 set config nems mac unicastrate=10 multicastrate=10 && \
   emanesh node-3 set config nems mac unicastrate=10 multicastrate=10
```

The B.A.T.M.A.N. Next Hop Matrix now shows `node-1` and `node-3`
directly connected.

```text
== B.A.T.M.A.N. Next Hop Matrix ==
+----------------+----------+----------+----------+
|    Reporter    |    1     |    2     |    3     |
+----------------+----------+----------+----------+
|       1        |    --    |    *     |    *     |
|       2        |    *     |    --    |    *     |
|       3        |    *     |    *     |    --    |
+----------------+----------+----------+----------+
```

