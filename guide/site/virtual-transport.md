---
layout: default
title: Virtual Transport
nav_order: 15
permalink: /virtual-transport
---


# Virtual Transport

The Virtual Transport uses the
[TUN/TAP](https://www.kernel.org/doc/Documentation/networking/tuntap.txt)
interface to create a *virtual interface* (*vif*) as the emulation
boundary entry/exit point.

## Features

The Virtual Transport emulation boundary provides the following set of
features: [Virtual Interface
Management](#virtual-interface-management), [Raw Transport
Interoperability](#raw-transport-interoperability), [Bitrate
Enforcement](#bitrate-enforcement), [Broadcast Only
Mode](#broadcast-only-mode), and [IPv4 and IPv6
Capable](#ipv4-and-ipv6-capable).

## Virtual Interface Management

The Virtual Transport creates a virtual interface for use as the
emulation boundary. IP packets routed to the virtual device are
encapsulated and transmitted to their respective *NEM* for downstream
processing. Packets received over-the-air are processed up the *NEM*
stack and transmitted to the *NEM*'s respective virtual transport for
injection back into the kernel IP stack.

The newly created virtual interface is assigned an Ethernet address
derived from the *NEM Id* associated with the transport using the
following format: `02:02:00:00:XX:XX` , where `XX:XX` is the 16 bit
*NEM Id*. This allows easy mapping of Ethernet MAC addresses to NEM Ids
for unicast frames. Multicast and broadcast frames map to the NEM
broadcast address `0xFFFF`.

A Virtual Transport managed virtual interface can be configured via
configuration parameters or managed externally, for example via DHCP.

## Raw Transport Interoperability

The Virtual Transport supports interoperability with [Raw Transport](raw-transport#raw-transport)
emulation boundaries using ARP caching to learn IP network to *NEM Id*
associations.

### Bitrate Enforcement

The Virtual Transport supports bitrate enforcement for use with models
that do not limit bitrate based on emulation implementation. Set the
configuration parameter `bitrate` to the desired rate in `bps` to
enable bitrate enforcement or 0 to disable.

### Broadcast Only Mode

The Virtual Transport supports forced *NEM* broadcasting of all IP
packet types: unicast, broadcast and multicast. Set the configuration
parameter `broadcastmodeenable` to `true` to enable broadcast only
mode.

### IPv4 and IPv6 Capable

The Virtual Transport supports IPv4 and IPv6 virtual interface address
assignments and packet processing.

## Configuration

1. **`address`**: IPv4 or IPv6 virutal device address.
   
   ```no-highlighting
   Default: no                    Required: no                    Modifiable: no                  
   Type:    inetaddr              Occurrs:  [1,1]               
   ```

2. **`arpcacheenable`**: Enable ARP request/reply monitoring to map
   Ethernet address to NEM.
   
   ```no-highlighting
   Default: yes                   Required: no                    Modifiable: no                  
   Type:    bool                  Occurrs:  [1,1]                 Range:      [false,true]        
   Values:  true
   ```

3. **`arpmodeenable`**: Enable ARP on the virtual device.
   
   ```no-highlighting
   Default: yes                   Required: no                    Modifiable: no                  
   Type:    bool                  Occurrs:  [1,1]                 Range:      [false,true]        
   Values:  true
   ```

4. **`bitrate`**: Transport bitrate in bps. This is the total
   allowable throughput for the transport combined in both directions
   (upstream and downstream). A value of 0 disables the bitrate feature.
   
   ```no-highlighting
   Default: yes                   Required: no                    Modifiable: no                  
   Type:    uint64                Occurrs:  [1,1]                 Range:      [0,max_uint64]      
   Values:  0
   ```

5. **`broadcastmodeenable`**: Broadcast all packets to all NEMs.
   
   ```no-highlighting
   Default: yes                   Required: no                    Modifiable: no                  
   Type:    bool                  Occurrs:  [1,1]                 Range:      [false,true]        
   Values:  false
   ```

6. **`device`**: Virtual device name.
   
   ```no-highlighting
   Default: yes                   Required: no                    Modifiable: no                  
   Type:    string                Occurrs:  [1,1]               
   Values:  emane0
   ```

7. **`devicepath`**: Path to the tuntap device.
   
   ```no-highlighting
   Default: yes                   Required: no                    Modifiable: no                  
   Type:    string                Occurrs:  [1,1]               
   Values:  /dev/net/tun
   ```

8. **`ethernet.type.arp.priority`**: Defines the emulator priority
   value (DSCP used for IP) to use when an ARP Ethernet frame is
   encountered during downstream processing.
   
   ```no-highlighting
   Default: yes                   Required: no                    Modifiable: no                  
   Type:    uint8                 Occurrs:  [1,1]                 Range:      [0,255]             
   Values:  0
   ```

9. **`ethernet.type.unknown.priority`**: Defines the emulator priority
   value (DSCP used for IP) to use when the specified unknown Ethernet
   type is encountered during downstream processing. Uses the following
   format:
   
   `<ethernet type>:<priority>`
   
   ```no-highlighting
   Default: no                    Required: no                    Modifiable: no                  
   Type:    string                Occurrs:  [0,65535]           
   Regex:   ^(0[xX]){0,1}\d+:\d+$
   ```

10. **`flowcontrolenable`**: Enables downstream traffic flow control
    with a corresponding flow control capable NEM layer.
    
    ```no-highlighting
    Default: yes                   Required: no                    Modifiable: no                  
    Type:    bool                  Occurrs:  [1,1]                 Range:      [false,true]        
    Values:  false
    ```

11. **`mask`**: IPv4 or IPv6 virutal device addres network mask.
    
    ```no-highlighting
    Default: no                    Required: no                    Modifiable: no                  
    Type:    inetaddr              Occurrs:  [1,1]               
    ```



## Statistics

1. **`avgDownstreamProcessingDelay`**: Average downstream processing
   delay
   
   ```no-highlighting
   Type: float                 Clearable: yes                 
   ```

2. **`avgProcessAPIQueueDepth`**: Average API queue depth for a
   processUpstreamPacket, processUpstreamControl,
   processDownstreamPacket, processDownstreamControl, processEvent and
   processTimedEvent.
   
   ```no-highlighting
   Type: double                Clearable: yes                 
   ```

3. **`avgProcessAPIQueueWait`**: Average API queue wait for a
   processUpstreamPacket, processUpstreamControl,
   processDownstreamPacket, processDownstreamControl, processEvent and
   processTimedEvent in microseconds.
   
   ```no-highlighting
   Type: double                Clearable: yes                 
   ```

4. **`avgTimedEventLatency`**: Average latency between the scheduled
   timer expiration and the actual firing over the requested duration.
   
   ```no-highlighting
   Type: double                Clearable: yes                 
   ```

5. **`avgTimedEventLatencyRatio`**: Average ratio of the delta between
   the scheduled timer expiration and the actual firing over the
   requested duration. An average ratio approaching 1 indicates that
   timer latencies are large in comparison to the requested durations.
   
   ```no-highlighting
   Type: double                Clearable: yes                 
   ```

6. **`avgUpstreamProcessingDelay`**: Average upstream processing delay
   
   ```no-highlighting
   Type: float                 Clearable: yes                 
   ```

7. **`numAPIQueued`**: The number of queued API events.
   
   ```no-highlighting
   Type: uint64                Clearable: yes                 
   ```

8. **`numDownstreamBytesBroadcastGenerated`**: Number of layer
   generated downstream broadcast bytes
   
   ```no-highlighting
   Type: uint64                Clearable: yes                 
   ```

9. **`numDownstreamBytesBroadcastRx`**: Number of downstream broadcast
   bytes received
   
   ```no-highlighting
   Type: uint64                Clearable: yes                 
   ```

10. **`numDownstreamBytesBroadcastTx`**: Number of downstream
    broadcast bytes transmitted
    
    ```no-highlighting
    Type: uint64                Clearable: yes                 
    ```

11. **`numDownstreamBytesUnicastGenerated`**: Number of layer
    generated downstream unicast bytes
    
    ```no-highlighting
    Type: uint64                Clearable: yes                 
    ```

12. **`numDownstreamBytesUnicastRx`**: Number of downstream unicast
    bytes received
    
    ```no-highlighting
    Type: uint64                Clearable: yes                 
    ```

13. **`numDownstreamBytesUnicastTx`**: Number of downstream unicast
    bytes transmitted
    
    ```no-highlighting
    Type: uint64                Clearable: yes                 
    ```

14. **`numDownstreamPacketsBroadcastDrop`**: Number of downstream
    broadcast packets dropped
    
    ```no-highlighting
    Type: uint64                Clearable: yes                 
    ```

15. **`numDownstreamPacketsBroadcastGenerated`**: Number of layer
    generated downstream broadcast packets
    
    ```no-highlighting
    Type: uint64                Clearable: yes                 
    ```

16. **`numDownstreamPacketsBroadcastRx`**: Number of downstream
    broadcast packets received
    
    ```no-highlighting
    Type: uint64                Clearable: yes                 
    ```

17. **`numDownstreamPacketsBroadcastTx`**: Number of downstream
    broadcast packets transmitted
    
    ```no-highlighting
    Type: uint64                Clearable: yes                 
    ```

18. **`numDownstreamPacketsUnicastDrop`**: Number of downstream
    unicast packets dropped
    
    ```no-highlighting
    Type: uint64                Clearable: yes                 
    ```

19. **`numDownstreamPacketsUnicastGenerated`**: Number of layer
    generated downstream unicast packets
    
    ```no-highlighting
    Type: uint64                Clearable: yes                 
    ```

20. **`numDownstreamPacketsUnicastRx`**: Number of downstream unicast
    packets received
    
    ```no-highlighting
    Type: uint64                Clearable: yes                 
    ```

21. **`numDownstreamPacketsUnicastTx`**: Number of downstream unicast
    packets transmitted
    
    ```no-highlighting
    Type: uint64                Clearable: yes                 
    ```

22. **`numUpstreamBytesBroadcastRx`**: Number of upstream broadcast
    bytes received
    
    ```no-highlighting
    Type: uint64                Clearable: yes                 
    ```

23. **`numUpstreamBytesBroadcastTx`**: Number of updtream broadcast
    bytes transmitted
    
    ```no-highlighting
    Type: uint64                Clearable: yes                 
    ```

24. **`numUpstreamBytesUnicastRx`**: Number upstream unicast bytes
    received
    
    ```no-highlighting
    Type: uint64                Clearable: yes                 
    ```

25. **`numUpstreamBytesUnicastTx`**: Number of upstream unicast bytes
    transmitted
    
    ```no-highlighting
    Type: uint64                Clearable: yes                 
    ```

26. **`numUpstreamPacketsBroadcastDrop`**: Number of upstream
    broadcast packets dropped
    
    ```no-highlighting
    Type: uint64                Clearable: yes                 
    ```

27. **`numUpstreamPacketsBroadcastRx`**: Number of upstream broadcast
    packets received
    
    ```no-highlighting
    Type: uint64                Clearable: yes                 
    ```

28. **`numUpstreamPacketsBroadcastTx`**: Number of upstream broadcast
    packets transmitted
    
    ```no-highlighting
    Type: uint64                Clearable: yes                 
    ```

29. **`numUpstreamPacketsUnicastDrop`**: Number of upstream unicast
    packets dropped
    
    ```no-highlighting
    Type: uint64                Clearable: yes                 
    ```

30. **`numUpstreamPacketsUnicastRx`**: Number upstream unicast packets
    received
    
    ```no-highlighting
    Type: uint64                Clearable: yes                 
    ```

31. **`numUpstreamPacketsUnicastTx`**: Number of upstream unicast
    packets transmitted
    
    ```no-highlighting
    Type: uint64                Clearable: yes                 
    ```

32. **`processedConfiguration`**: The number of processed
    configuration.
    
    ```no-highlighting
    Type: uint64                Clearable: yes                 
    ```

33. **`processedDownstreamControl`**: The number of processed
    downstream control.
    
    ```no-highlighting
    Type: uint64                Clearable: yes                 
    ```

34. **`processedDownstreamPackets`**: The number of processed
    downstream packets.
    
    ```no-highlighting
    Type: uint64                Clearable: yes                 
    ```

35. **`processedEvents`**: The number of processed events.
    
    ```no-highlighting
    Type: uint64                Clearable: yes                 
    ```

36. **`processedTimedEvents`**: The number of processed timed events.
    
    ```no-highlighting
    Type: uint64                Clearable: yes                 
    ```

37. **`processedUpstreamControl`**: The number of processed upstream
    control.
    
    ```no-highlighting
    Type: uint64                Clearable: yes                 
    ```

38. **`processedUpstreamPackets`**: The number of processed upstream
    packets.
    
    ```no-highlighting
    Type: uint64                Clearable: yes                 
    ```



## Statistic Tables

1. **`BroadcastPacketAcceptTable`**: Broadcast packets accepted
   
   ```no-highlighting
   Clearable:  yes
   ```

2. **`BroadcastPacketDropTable`**: Broadcast packets dropped by reason
   code
   
   ```no-highlighting
   Clearable:  yes
   ```

3. **`EventReceptionTable`**: Received event counts
   
   ```no-highlighting
   Clearable:  yes
   ```

4. **`UnicastPacketAcceptTable`**: Unicast packets accepted
   
   ```no-highlighting
   Clearable:  yes
   ```

5. **`UnicastPacketDropTable`**: Unicast packets dropped by reason
   code
   
   ```no-highlighting
   Clearable:  yes
   ```



