---
layout: default
title: Comm Effect Utility Model
nav_order: 14
permalink: /comm-effect-utility-model
---


# Comm Effect Utility Model

The Comm Effect Utility Model allows emane to function and an IPv4
network impairment tool.

## Features

The Comm Effect utility model provides the following features:
[Network Impairments](#network-impairments) and [Static
Filters](#static-filters).

### Network Impairments

The Comm Effect Utility Model supports the following network
impairments controlled via [`CommEffectEvents`](comm-effect-utility-model#commeffectevent) or
[static filter](#static-filters):

1. Loss: The percentage of packets that will be dropped utilizing a
   uniform distribution model.

2. Latency: The average delay for a packet to traverse the
   network. The total delay is composed of a fixed and variable
   component. The fixed amount of the delay is defined via a latency
   parameter and the variable amount via a jitter parameter. Both
   parameters are defined via [`CommEffectEvent`](comm-effect-utility-model#commeffectevent)
   or [static filter](#static-filters). The jitter component to
   latency is determined randomly by applying a value pulled from a
   uniform random distribution of +/- the jitter parameter value. The
   randomly generated jitter value is then added to the fixed latency
   to determine the total delay.

3. Duplicates: The percentage of packets that will be duplicated at
   the receiver.

4. Unicast Bitrate: The bitrate for packets destined for the *NEM* or
   handled in promiscuous mode.

5. Broadcast Bitrate: The bitrate for packets destined for the *NEM*
   broadcast address.

## Static Filters

The Comm Effect Utility Model supports the ability to define static
filters to control network impairments. Filters are defined via an XML
configuration file and have the following characteristics:

1. The filter file used by a given *NEM* within the emulation is
   identified at initialization time via the *NEM*'s `filterfile`
   configuration parameter. Each filter defined in the `filterfile` is
   characterized by one or more target elements and a single effect
   element.

2. Currently only IPv4 Ethernet packet filter targets are
   supported. The target element has the following format within the
   filter XML file:

   ```xml
   <target>
     <ipv4 src='0.0.0.0' dst='0.0.0.0' len='0' ttl='0' tos='0'>
       <udp sport='0' dport='0'/>
       <protocol type='0'/>
     </ipv4>
   </target>
   ```

3. All of the `<ipv4>`  attributes are optional:

   1. `src`: Source address in IPv4 header. Valid range 0.0.0.0 -
      255.255.255.255, where 0.0.0.0 implies don't care.
   
   2. `dst`: Destination address in IPv4 header. Valid range 0.0.0.0 -
      255.255.255.255, where 0.0.0.0 implies don't care.

   3. `len`: Total length in IPv4 header. Valid range 0 - 65535, where
      0 implies don't care.
   
   4. `ttl`: Time to live in IPv4 header. Valid range 0 - 255, where 0
      implies don't care.
   
   5. `tos`: Type of Service/Differentiated Services in IPv4
   header. Valid range 0-255, where 0 implies don't care.

   In addition, a filter can be defined via the IPv4 protocol field in
   the header. The communication protocol can be defined by name or
   numerical value. Currently, udp is the only protocol that can be
   defined by name. All other protocols must be identified via
   numerical value.

    1. `<udp>`: Used to identify UDP protocol by name. When using this
       mechanism to define the udp protocol, sport and/or dport can
       also be identified for the udp protocol header. The valid range
       for sport and dport are 0 to 65535, where 0 implies don't care.

       ```xml
        <target>
          <ipv4 dst='224.1.2.3'>
            <udp sport='12345' dport='12346'/>
          </ipv4>
        </target>
        ```

    2. `<protocol>`: Used when identifying the communication protocol
       based on numerical value. The type attribute identifies the
       numerical value for the IPv4 communication protocol with a
       valid range from 0 to 255.

       ```xml
        <target>
          <ipv4 dst='224.1.2.3'>
            <protocol type='89'/>
          </ipv4>
        </target>
        ```

4. Each filter is assigned static network impairments (loss, latency,
   jitter, duplicates, unicastbitrate and broadcastbitrate).

   ```xml
   <effect>
     <loss>20</loss>
     <duplicate>0</duplicate>
     <latency sec='0' usec='200000'/>
     <jitter sec='0' usec='0'/>
     <broadcastbitrate>1024</broadcastbitrate>
     <unicastbitrate>8096</unicastbitrate>
   </effect>
   ```

   The effect element has the following format:

   1. `<loss>`: The loss 0 to 100 in percentage to be applied to the
      packets that match the associated target.
    
   2. `<duplicate>`: The duplicates 0 to 100 in percentage to be applied
      to the packets that match the associated target.
    
   3. `<latency>`: The fixed average delay to be applied to the packets
      that match the associated target.
      
      *sec*: Seconds have a valid range 0 to 65535.  
      *usec*: Microseconds have a valid range 0 to 999999.  

   4. `<jitter>`: The random variation applied to the packets that match
      the associated target.

      *sec*: Seconds have a valid range 0 to 65535.  
      *usec*: Microseconds have a valid range 0 to 999999.  
       
   5. `<unicastbitrate>`: The bitrate (bps) applied to packets
      addressed to the *NEM* or received in promiscuous mode matching
      the associated target. The bitrate has a valid range from 0,
      meaning unused, to max unsigned 64 bit number.
    
   6. `<broadcastbitrate>`: The bitrate (bps) applied to packets
      addressed to the *NEM* broadcast address matching the associated
      target. The bitrate has a valid range from 0, meaning unused, to
      max unsigned 64 bit number.

   The filters and their associated impairments are defined at
   initialization and cannot be altered during emulation.

6. Filter ordering determines the network impairment, and as such,
   more specific filters should be defined first. Each received packet
   is evaluated against the defined filters in order and the first
   match determines the impairment to be applied. In the below
   example, a packet as it is received by a node will be evaluated
   against each of the four filters (OSPF, TOS, UDP, DEFAULT) in order
   and the respective effect will be applied based on the first
   match.

   It should be noted that the inclusion of the DEFAULT filter should
   only be used when [`CommEffectEvents`](comm-effect-utility-model#commeffectevent)
   are not being utilized since the filters take precedence. When
   filters are used in conjunction with [`CommEffectEvents`](comm-effect-utility-model#commeffectevent), the event driven impairments serve
   as the default effect for all packets that do not match a filter
   target.

   ```xml
   <!DOCTYPE commeffect SYSTEM "file:///usr/share/emane/dtd/commeffectfilters.dtd">
   <commeffect>
     <filter>
       <description>OSPF Packets</description>
       <target>
         <ipv4>
           <protocol type="89"/>
         </ipv4>
       </target>
       <effect>
         <loss>0</loss>
         <duplicate>0</duplicate>
         <latency sec='0' usec='0'/>
         <jitter sec='0' usec='0'/>
       </effect>
     </filter>
     <filter>
       <description>TOS (Type of Service) = 192</description>
       <target>
         <ipv4 tos='192'>
         </ipv4>
       </target>
       <effect>
         <loss>10</loss>
         <duplicate>150</duplicate>
         <latency sec='0' usec='100000'/>
         <jitter sec='0' usec='0'/>
       </effect>
     </filter>
     <filter>
       <description>UDP Multicast (destination address = 224.1.2.3 and destination port = 12345)</description>
       <target>
         <ipv4 dst='224.1.2.3'>
           <udp dport='12345'/>
         </ipv4>
       </target>
       <effect>
         <loss>20</loss>
         <duplicate>0</duplicate>
         <latency sec='0' usec='200000'/>
         <jitter sec='0' usec='0'/>
       </effect>
     </filter>
     <filter>
       <description>DEFAULT:  All Other Packets</description>
       <target/>
       <effect>
         <loss>40</loss>
         <duplicate>30</duplicate>
         <latency sec='0' usec='600000'/>
         <jitter sec='0' usec='100000'/>
         <broadcastbitrate>8096</broadcastbitrate>
         <unicastbitrate>8096</unicastbitrate>
       </effect>
     </filter>
   </commeffect>
   ```

## `CommEffectEvent`

```protobuf
package EMANEMessage;
option optimize_for = SPEED;
message CommEffectEvent
{
  message CommEffect
  {
    required uint32 nemId = 1;
    required float latencySeconds = 2;
    required float jitterSeconds = 3;
    required float probabilityLoss = 4;
    required float probabilityDuplicate = 5;
    required uint64 unicastBitRatebps = 6;
    required uint64 broadcastBitRatebps = 7;
  }
  repeated CommEffect commEffects = 1;
}
```
<p style="float:right;font-family:courier;font-size:75%">emane/src/libemane/commeffectevent.proto</p><br>

## NEM XML Structure

The Comm Effect utility model is not a radio model and does not use a
physical layer. It is a special class of plugin called a
*shim*. *Shims* follow all the same paradigms found in [EMANE Paradigms](paradigms#emane-paradigms), and it is possible to build an *NEM*
that contains one or more shims. In practice, this is usually never
necessary.

The *NEM* XML definition for a Comm Effect utility model instance only
contains a `<shim>` and `<transport>` element.  In order to be
accepted by the emulator as valid, the `<nem>` `type` attribute must
be set to `unstructured` in order to relax checks that aim to prevent
incorrect *NEM* configuration.

```xml
<!DOCTYPE nem SYSTEM "file:///usr/share/emane/dtd/nem.dtd">
<nem type="unstructured">
  <transport definition="emane-transraw.xml"/>
  <shim definition="emane-commeffect-utilitymodel.xml"/>
</nem>
```
<p style="float:right;font-family:courier;font-size:75%">emane-guide/examples/commeffect-01/node-1/emane-commeffect-nem.xml</p><br>

## Configuration

1. **`defaultconnectivitymode`**: Defines the default connectivity
   mode for Comm Effects. When set to on, full connectivity will be
   engaged until a valid Comm Effect event is received.
   
   ```no-highlighting
   Default: yes                   Required: no                    Modifiable: no                  
   Type:    bool                  Occurrs:  [1,1]                 Range:      [false,true]        
   Values:  true
   ```

2. **`enablepromiscuousmode`**: Defines whether promiscuous mode is
   enabled or not. If promiscuous mode is enabled, all received packets
   (intended for the given node or not) that pass the receive test are
   sent upstream to the transport.
   
   ```no-highlighting
   Default: yes                   Required: no                    Modifiable: no                  
   Type:    bool                  Occurrs:  [1,1]                 Range:      [false,true]        
   Values:  false
   ```

3. **`filterfile`**: Defines the absolute URI of the effects filter
   XML file which contains static filters to control network impairments.
   
   ```no-highlighting
   Default: no                    Required: no                    Modifiable: no                  
   Type:    string                Occurrs:  [1,1]               
   ```

4. **`groupid`**: Defines the Comm Effect Group Id.  Only NEMs in the
   same Comm Effect Group can communicate.
   
   ```no-highlighting
   Default: yes                   Required: no                    Modifiable: no                  
   Type:    uint32                Occurrs:  [1,1]                 Range:      [0,4294967295]      
   Values:  0
   ```

5. **`receivebufferperiod`**: Defines the max buffering time in
   seconds for packets received from an NEM. The buffering interval for a
   given packet is determined by the bitrate for the source NEM and the
   packet size. Packets are then placed in a timed queue based on this
   interval and all packets that would cause the receive buffer period to
   be exceeded are discarded. A value of 0.0 disables the limit and
   allows all received packets to stack up in the queue.
   
   ```no-highlighting
   Default: yes                   Required: no                    Modifiable: no                  
   Type:    double                Occurrs:  [1,1]                 Range:      [min_double,max_double]
   Values:  1.000000
   ```



## Statistics

1. **`avgDownstreamProcessingDelay0`**: Average downstream processing
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

6. **`avgUpstreamProcessingDelay0`**: Average upstream processing
   delay
   
   ```no-highlighting
   Type: float                 Clearable: yes                 
   ```

7. **`numAPIQueued`**: The number of queued API events.
   
   ```no-highlighting
   Type: uint64                Clearable: yes                 
   ```

8. **`numDownstreamBytesBroadcastGenerated0`**: Number of layer
   generated downstream broadcast bytes
   
   ```no-highlighting
   Type: uint64                Clearable: yes                 
   ```

9. **`numDownstreamBytesBroadcastRx0`**: Number of downstream
   broadcast bytes received
   
   ```no-highlighting
   Type: uint64                Clearable: yes                 
   ```

10. **`numDownstreamBytesBroadcastTx0`**: Number of downstream
    broadcast bytes transmitted
    
    ```no-highlighting
    Type: uint64                Clearable: yes                 
    ```

11. **`numDownstreamBytesUnicastGenerated0`**: Number of layer
    generated downstream unicast bytes
    
    ```no-highlighting
    Type: uint64                Clearable: yes                 
    ```

12. **`numDownstreamBytesUnicastRx0`**: Number of downstream unicast
    bytes received
    
    ```no-highlighting
    Type: uint64                Clearable: yes                 
    ```

13. **`numDownstreamBytesUnicastTx0`**: Number of downstream unicast
    bytes transmitted
    
    ```no-highlighting
    Type: uint64                Clearable: yes                 
    ```

14. **`numDownstreamPacketsBroadcastDrop0`**: Number of downstream
    broadcast packets dropped
    
    ```no-highlighting
    Type: uint64                Clearable: yes                 
    ```

15. **`numDownstreamPacketsBroadcastGenerated0`**: Number of layer
    generated downstream broadcast packets
    
    ```no-highlighting
    Type: uint64                Clearable: yes                 
    ```

16. **`numDownstreamPacketsBroadcastRx0`**: Number of downstream
    broadcast packets received
    
    ```no-highlighting
    Type: uint64                Clearable: yes                 
    ```

17. **`numDownstreamPacketsBroadcastTx0`**: Number of downstream
    broadcast packets transmitted
    
    ```no-highlighting
    Type: uint64                Clearable: yes                 
    ```

18. **`numDownstreamPacketsUnicastDrop0`**: Number of downstream
    unicast packets dropped
    
    ```no-highlighting
    Type: uint64                Clearable: yes                 
    ```

19. **`numDownstreamPacketsUnicastGenerated0`**: Number of layer
    generated downstream unicast packets
    
    ```no-highlighting
    Type: uint64                Clearable: yes                 
    ```

20. **`numDownstreamPacketsUnicastRx0`**: Number of downstream unicast
    packets received
    
    ```no-highlighting
    Type: uint64                Clearable: yes                 
    ```

21. **`numDownstreamPacketsUnicastTx0`**: Number of downstream unicast
    packets transmitted
    
    ```no-highlighting
    Type: uint64                Clearable: yes                 
    ```

22. **`numUpstreamBytesBroadcastRx0`**: Number of upstream broadcast
    bytes received
    
    ```no-highlighting
    Type: uint64                Clearable: yes                 
    ```

23. **`numUpstreamBytesBroadcastTx0`**: Number of updtream broadcast
    bytes transmitted
    
    ```no-highlighting
    Type: uint64                Clearable: yes                 
    ```

24. **`numUpstreamBytesUnicastRx0`**: Number upstream unicast bytes
    received
    
    ```no-highlighting
    Type: uint64                Clearable: yes                 
    ```

25. **`numUpstreamBytesUnicastTx0`**: Number of upstream unicast bytes
    transmitted
    
    ```no-highlighting
    Type: uint64                Clearable: yes                 
    ```

26. **`numUpstreamPacketsBroadcastDrop0`**: Number of upstream
    broadcast packets dropped
    
    ```no-highlighting
    Type: uint64                Clearable: yes                 
    ```

27. **`numUpstreamPacketsBroadcastRx0`**: Number of upstream broadcast
    packets received
    
    ```no-highlighting
    Type: uint64                Clearable: yes                 
    ```

28. **`numUpstreamPacketsBroadcastTx0`**: Number of upstream broadcast
    packets transmitted
    
    ```no-highlighting
    Type: uint64                Clearable: yes                 
    ```

29. **`numUpstreamPacketsUnicastDrop0`**: Number of upstream unicast
    packets dropped
    
    ```no-highlighting
    Type: uint64                Clearable: yes                 
    ```

30. **`numUpstreamPacketsUnicastRx0`**: Number upstream unicast
    packets received
    
    ```no-highlighting
    Type: uint64                Clearable: yes                 
    ```

31. **`numUpstreamPacketsUnicastTx0`**: Number of upstream unicast
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

1. **`BroadcastPacketAcceptTable0`**: Broadcast packets accepted
   
   ```no-highlighting
   Clearable:  yes
   ```

2. **`BroadcastPacketDropTable0`**: Broadcast packets dropped by
   reason code
   
   ```no-highlighting
   Clearable:  yes
   ```

3. **`EventReceptionTable`**: Received event counts
   
   ```no-highlighting
   Clearable:  yes
   ```

4. **`UnicastPacketAcceptTable0`**: Unicast packets accepted
   
   ```no-highlighting
   Clearable:  yes
   ```

5. **`UnicastPacketDropTable0`**: Unicast packets dropped by reason
   code
   
   ```no-highlighting
   Clearable:  yes
   ```



## Examples

This guide includes the IEEE 802.11abg example:

1. `commeffect-01`: A five host example where each host is configured
on a flat 10.98.0.0/16 network and connected via `lan0` to an *NEM*
using a [Raw Transport](raw-transport#raw-transport).

### commeffect-01


![](images/auto-generated-topology-commeffect-01.png){: width="65%"; .centered}
<p style="text-align:center;font-size:75%">commeffect-01 experiment components</p><br>


The `commeffect-01` example experiment contains five hosts configured
on a flat 10.98.0.0/16 network and connected via `lan0` to an *NEM*
using a [Raw Transport](raw-transport#raw-transport). This configuration illustrates how you
can connect physical or virtual network appliances to *EMANE*, in a
manner in which the appliance is unaware of the emulator's presence,
whether using a physical interface, tunnel, vif, etc. Here, the
network appliances are LXCs but they can just as easily be physical
devices connected to an *EMANE* server.

Each host has a `lan0` interface that is monitored by a host
corresponding *NEM*. All outbound host `lan0` traffic is routed into
the emulation and if successfully received by the *NEM* associated
with the destination(s), will be written the destination(s)'s
corresponding `lan0`.

All Comm Effect utility model instance are initialized with network
impairments via the `emaneeventservice` which publishes [`CommEffectEvents`](comm-effect-utility-model#commeffectevent) using values in `scenario.eel`.

```text
0.0  nem:1 commeffect nem:2,0,0,0,0,1000000,1000000
0.0  nem:1 commeffect nem:3,0,0,0,0,1000000,1000000
0.0  nem:1 commeffect nem:4,0,0,0,0,1000000,1000000
0.0  nem:1 commeffect nem:5,0,0,0,0,1000000,1000000

0.0  nem:2 commeffect nem:1,0,0,0,0,1000000,1000000
0.0  nem:2 commeffect nem:3,0,0,0,0,1000000,1000000
0.0  nem:2 commeffect nem:4,0,0,0,0,1000000,1000000
0.0  nem:2 commeffect nem:5,0,0,0,0,1000000,1000000

0.0  nem:3 commeffect nem:1,0,0,0,0,1000000,1000000
0.0  nem:3 commeffect nem:2,0,0,0,0,1000000,1000000
0.0  nem:3 commeffect nem:4,0,0,0,0,1000000,1000000
0.0  nem:3 commeffect nem:5,0,0,0,0,1000000,1000000

0.0  nem:4 commeffect nem:1,0,0,0,0,1000000,1000000
0.0  nem:4 commeffect nem:2,0,0,0,0,1000000,1000000
0.0  nem:4 commeffect nem:3,0,0,0,0,1000000,1000000
0.0  nem:4 commeffect nem:5,0,0,0,0,1000000,1000000

0.0  nem:5 commeffect nem:1,0,0,0,0,1000000,1000000
0.0  nem:5 commeffect nem:2,0,0,0,0,1000000,1000000
0.0  nem:5 commeffect nem:3,0,0,0,0,1000000,1000000
0.0  nem:5 commeffect nem:4,0,0,0,0,1000000,1000000
```
<p style="float:right;font-family:courier;font-size:75%">emane-guide/examples/commeffect-01/host/scenario.eel</p><br>

![](images/auto-generated-run-commeffect-01.png){:width="75%"; .centered}

All hosts are configured similarly, taking a look at `host-1`
interfaces we can see the `lan0` interface is configured as
10.98.1.2/16.

```text
$ ssh host-1 ip addr show dev lan0
3: lan0@if102: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    link/ether 7e:9a:ba:30:f0:90 brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 10.98.1.2/16 brd 10.98.255.255 scope global lan0
       valid_lft forever preferred_lft forever
    inet6 fe80::7c9a:baff:fe30:f090/64 scope link
       valid_lft forever preferred_lft forever
```

Looking at `host-1` routes shows a flat network which is different
than the host configuration in previous experiments which used a
tiered topology with radio nodes acting as gateways for hosts.

```text
$ ssh host-1 ip route show
10.98.0.0/16 dev lan0 proto kernel scope link src 10.98.1.2
10.99.0.0/16 dev backchan0 proto kernel scope link src 10.99.1.1
```

Pinging from `host-1` to all other hosts over the `lan0` interface
shows 100% completion and minimal latency.

```text
$ ssh host-1 fping host-2-lan host-3-lan host-4-lan host-5-lan -C 2
host-2-lan : [0], 64 bytes, 2.42 ms (2.42 avg, 0% loss)
host-3-lan : [0], 64 bytes, 2.70 ms (2.70 avg, 0% loss)
host-4-lan : [0], 64 bytes, 2.61 ms (2.61 avg, 0% loss)
host-5-lan : [0], 64 bytes, 2.70 ms (2.70 avg, 0% loss)
host-2-lan : [1], 64 bytes, 3.37 ms (2.90 avg, 0% loss)
host-3-lan : [1], 64 bytes, 3.35 ms (3.03 avg, 0% loss)
host-4-lan : [1], 64 bytes, 3.28 ms (2.95 avg, 0% loss)
host-5-lan : [1], 64 bytes, 3.11 ms (2.90 avg, 0% loss)

host-2-lan : 2.42 3.37
host-3-lan : 2.70 3.35
host-4-lan : 2.61 3.28
host-5-lan : 2.70 3.11
```

Using the `emaneevent-commeffect` utility, we can set the latency of
all links to 100ms.

```text
$ emaneevent-commeffect 1:5 latency=.1 -i letce0
```

Reissuing the same `ping` command verifies 100ms of latency in each
directions.

```text
$ ssh host-1 fping host-2-lan host-3-lan host-4-lan host-5-lan -C 2
host-2-lan : [0], 64 bytes, 201 ms (201 avg, 0% loss)
host-3-lan : [0], 64 bytes, 201 ms (201 avg, 0% loss)
host-4-lan : [0], 64 bytes, 201 ms (201 avg, 0% loss)
host-5-lan : [0], 64 bytes, 201 ms (201 avg, 0% loss)
host-2-lan : [1], 64 bytes, 202 ms (202 avg, 0% loss)
host-3-lan : [1], 64 bytes, 202 ms (201 avg, 0% loss)
host-4-lan : [1], 64 bytes, 201 ms (201 avg, 0% loss)
host-5-lan : [1], 64 bytes, 201 ms (201 avg, 0% loss)

host-2-lan : 201 202
host-3-lan : 201 202
host-4-lan : 201 201
host-5-lan : 201 201
```

