---
layout: default
title: Raw Transport
nav_order: 16
permalink: /raw-transport
---



# Raw Transport

The Raw Transport uses a specified network interface as the emulation
boundary entry/exit point.

## Features

The Raw Transport emulation boundary provides the following set of
features: [Network Interface Raw
Read/Write](#network-interface-raw-readwrite), [Virtual Transport
Interoperability](#virtual-transport-interoperability), [Bitrate
Enforcement](#bitrate-enforcement), [Broadcast Only
Mode](#broadcast-only-mode), and [IPv4 and IPv6
Capable](#ipv4-and-ipv6-capable).

## Network Interface Raw Read/Write

The Raw Transport uses a specific network interface as the emulation
boundary entry/exit point. The network interface can be a physical
interface, virtual interface, tunnel, etc. The interface is managed
external to the Raw Transport.

Any traffic read from the interface will
be delivered to the Raw Transport's respective *NEM* for emulation
processing.

## Virtual Transport Interoperability

The Raw Transport supports interoperability with [Virtual Transport](virtual-transport#virtual-transport)
emulation boundaries using ARP caching to learn IP network to *NEM Id*
associations.

### Bitrate Enforcement

The Raw Transport supports bitrate enforcement for use with models
that do not limit bitrate based on emulation implementation. Set the
configuration parameter `bitrate` to the desired rate in `bps` to
enable bitrate enforcement or 0 to disable.

### Broadcast Only Mode

The Raw Transport supports forced *NEM* broadcasting of all IP
packet types: unicast, broadcast and multicast. Set the configuration
parameter `broadcastmodeenable` to `true` to enable broadcast only
mode.

### IPv4 and IPv6 Capable

The Raw Transport supports IPv4 and IPv6 packet processing.

## Configuration

1. **`arpcacheenable`**: Enable ARP request/reply monitoring to map
   Ethernet address to NEM.
   
   ```no-highlighting
   Default: yes                   Required: no                    Modifiable: no                  
   Type:    bool                  Occurrs:  [1,1]                 Range:      [false,true]        
   Values:  true
   ```

2. **`bitrate`**: Transport bitrate in bps. This is the total
   allowable throughput for the transport combined in both directions
   (upstream and downstream). A value of 0 disables the bitrate feature.
   
   ```no-highlighting
   Default: yes                   Required: no                    Modifiable: no                  
   Type:    uint64                Occurrs:  [1,1]                 Range:      [0,max_uint64]      
   Values:  0
   ```

3. **`broadcastmodeenable`**: Broadcast all packets to all NEMs.
   
   ```no-highlighting
   Default: yes                   Required: no                    Modifiable: no                  
   Type:    bool                  Occurrs:  [1,1]                 Range:      [false,true]        
   Values:  false
   ```

4. **`device`**: Device to use as the raw packet entry point.
   
   ```no-highlighting
   Default: no                    Required: no                    Modifiable: no                  
   Type:    string                Occurrs:  [1,1]               
   ```

5. **`ethernet.type.arp.priority`**: Defines the emulator priority
   value (DSCP used for IP) to use when an ARP Ethernet frame is
   encountered during downstream processing.
   
   ```no-highlighting
   Default: yes                   Required: no                    Modifiable: no                  
   Type:    uint8                 Occurrs:  [1,1]                 Range:      [0,255]             
   Values:  0
   ```

6. **`ethernet.type.unknown.priority`**: Defines the emulator priority
   value (DSCP used for IP) to use when the specified unknown Ethernet
   type is encountered during downstream processing. Uses the following
   format:
   
   `<ethernet type>:<priority>`
   
   ```no-highlighting
   Default: no                    Required: no                    Modifiable: no                  
   Type:    string                Occurrs:  [0,65535]           
   Regex:   ^(0[xX]){0,1}\d+:\d+$
   ```



## Statistics

1. **`avgProcessAPIQueueDepth`**: Average API queue depth for a
   processUpstreamPacket, processUpstreamControl,
   processDownstreamPacket, processDownstreamControl, processEvent and
   processTimedEvent.
   
   ```no-highlighting
   Type: double                Clearable: yes                 
   ```

2. **`avgProcessAPIQueueWait`**: Average API queue wait for a
   processUpstreamPacket, processUpstreamControl,
   processDownstreamPacket, processDownstreamControl, processEvent and
   processTimedEvent in microseconds.
   
   ```no-highlighting
   Type: double                Clearable: yes                 
   ```

3. **`avgTimedEventLatency`**: Average latency between the scheduled
   timer expiration and the actual firing over the requested duration.
   
   ```no-highlighting
   Type: double                Clearable: yes                 
   ```

4. **`avgTimedEventLatencyRatio`**: Average ratio of the delta between
   the scheduled timer expiration and the actual firing over the
   requested duration. An average ratio approaching 1 indicates that
   timer latencies are large in comparison to the requested durations.
   
   ```no-highlighting
   Type: double                Clearable: yes                 
   ```

5. **`numAPIQueued`**: The number of queued API events.
   
   ```no-highlighting
   Type: uint64                Clearable: yes                 
   ```

6. **`processedConfiguration`**: The number of processed
   configuration.
   
   ```no-highlighting
   Type: uint64                Clearable: yes                 
   ```

7. **`processedDownstreamControl`**: The number of processed
   downstream control.
   
   ```no-highlighting
   Type: uint64                Clearable: yes                 
   ```

8. **`processedDownstreamPackets`**: The number of processed
   downstream packets.
   
   ```no-highlighting
   Type: uint64                Clearable: yes                 
   ```

9. **`processedEvents`**: The number of processed events.
   
   ```no-highlighting
   Type: uint64                Clearable: yes                 
   ```

10. **`processedTimedEvents`**: The number of processed timed events.
    
    ```no-highlighting
    Type: uint64                Clearable: yes                 
    ```

11. **`processedUpstreamControl`**: The number of processed upstream
    control.
    
    ```no-highlighting
    Type: uint64                Clearable: yes                 
    ```

12. **`processedUpstreamPackets`**: The number of processed upstream
    packets.
    
    ```no-highlighting
    Type: uint64                Clearable: yes                 
    ```



## Statistic Tables

1. **`EventReceptionTable`**: Received event counts
   
   ```no-highlighting
   Clearable:  yes
   ```



