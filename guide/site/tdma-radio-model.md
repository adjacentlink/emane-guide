---
layout: default
title: TDMA Radio Model
nav_order: 12
permalink: /tdma-radio-model
---


# TDMA Radio Model

The TDMA radio model implements a generic TDMA scheme that supports
[TDMA schedule](#tdma-schedule) distribution and updates in real-time
using [`TDMAScheduleEvents`](tdma-radio-model#tdmascheduleevent).

## Features

The TDMA radio model provides the following set of features: [Priority
Queues](#priority-queues), [Fragmentation](#fragmentation),
[Aggregation](#aggregation), [Reassembly](#reassembly), [TDMA
Schedule](#tdma-schedule), and [Packet Completion Rate
Curves](#packet-completion-rate-curves).

### Priority Queues

The TDMA radio model supports priority queues which map to user
traffic based priority levels assigned by emulation boundary
components. Outbound messages are dequeued First in First Out (FIFO)
based on slot service class queue mapping and a highest to lowest
priority queue search, if necessary.

The TDMA radio model classifies user traffic into four categories
which map to four queues. Traffic is assigned to a queue based on
downstream packet priority. The `queue.depth` configuration parameter
controls the queue depth for all queues. All queues will overflow,
dropping the oldest packet when an enqueue operation occurs on a queue
at max queue depth. The packet selected for discard will be the oldest
packet where no portion of the packet has been transmitted due to
[fragmentation](#fragmentation). If all packets in the queue have had
a portion transmitted, then the oldest packet is discarded regardless
of fragmentation state.

The [Virtual Transport](virtual-transport#virtual-transport) and [Raw Transport](raw-transport#raw-transport) use DSCP as
downstream packet priority.

|Queue ID| DSCP (6 MSBs of IP TOS Field)| Queue Priority|
|--------|------------------------------|---------------|
|0       | 0 - 7, 24 - 31               |0  (*lowest*)  |
|1       | 8 - 23                       |1              |
|2       | 32 - 47                      |2              |
|3       | 48 - 63                      |3              |
|4       | Reserved Control             |4  (*highest*) |

All transmit slots have a class or service assigned. This class
represents one of the four traffic queues or a fifth reserved
scheduler control queue. If the `queue.stricttxdequeue` configuration
parameter is enabled, only the queue matching the transmit slot class
is used to dequeue traffic. If `queue.stricttxdequeue` is disabled, an
attempt is made to dequeue traffic from the slot class matching queue,
followed by all other queues in highest to lowest priority order.

Queues can be dequeued in one of two ways depending on whether the
current transmit slot has a destination *NEM* assigned. If a destination
is assigned, only packets matching the destination are dequeued
(FIFO). If no destination match is found, no transmission occurs. If a
destination is not assigned, packets are dequeued (FIFO) regardless of
their destination.

Each slot has the same size and overhead, which is assigned using a
 [`TDMAScheduleEvent`](tdma-radio-model#tdmascheduleevent). Transmit slots may be assigned
 different data rates, making it possible for slots to have different
 maximum byte limits. The TDMA radio model supports both fragmentation
 and aggregation and allows either to be enabled or disabled
 independently.

### Fragmentation

The TDMA radio model supports fragmentation and reassembly of large
outbound messages based on per slot data rates. If fragmentation is
enabled with the `queue.fragmentationenable` configuration parameter,
a large packet that is too big to fit in a given transmit slot is
fragmented into two or more message components. The actual number of
message components required cannot be determined beforehand since
each slot may vary in allowable size and destination assignment. If
fragmentation is disabled, packets that are too large to fit in a
transmit slot are discarded until one is found that fits. If none are
found in the slot class matching queue and `queue.stricttxdequeue` is
disabled, other queues will be searched but no packets will be
discarded due to length. In this case, as soon as a packet is found to
be too large for a given slot, the search ends in that queue and
continues in the next lowest priority queue.

### Aggregation

The TDMA radio model supports aggregation of smaller outbound
messages into larger over-the-air messages. If aggregation is enabled
with the `queue.aggregationenable` configuration parameter, one or
more message components for the same or different destinations
(unicast or broadcast) can be transmitted in a single slot. If all the
message components contained in a single slot transmission are for the
same *NEM* destination, that destination is used as the downstream
(outbound) packet destination. Otherwise, the *NEM* broadcast address is
used as the downstream packet destination. The latter case does not
imply the TDMA radio model treats these messages as broadcast. The TDMA
model handles each message component contained in a single
transmission as a separate message. However, when examining physical
layer statistics, the notion of unicast and broadcast transmission is
a bit fuzzy.

If fragmentation is enabled, one or more message components in an
aggregate transmission may be a fragment. The
`queue.aggregationslotthreshold` configuration parameter controls the
percentage of a slot that must be filled in order to satisfy the
aggregation function and prevent further searching and/or fragmenting
of packets to fill the slot.

### Reassembly

If fragmentation and/or aggregation are disabled, the TDMA radio model will
still process upstream (inbound) aggregate messages and resemble
packet fragments. The TDMA radio model will attempt fragment reassembly on
one or more packets from one or more sources at the same time. Two
configuration parameters are used to control when individual fragment
reassembly efforts should be abandoned:
`fragmentcheckthreshold` and
`fragmenttimeoutthreshold`. The
`fragmentcheckthreshold` configuration
parameter controls how often the model checks to see if any active
reassembly efforts should be abandoned. The
`fragmenttimeoutthreshold` configuration
parameter is the amount of time that must pass since receiving a
fragment for a specific reassembly effort in order for that effort to
be considered timed out and subsequently abandoned.

The radio model does not handle out of order fragments. As soon as a
non-consecutive fragment is received the reassembly effort for that
packet is abandoned.

### TDMA Schedule

The TDMA radio model supports TDMA schedule definition including [slot
size](#timing-and-slot-size), slot overhead, frame size as well as per
slot data rate, frequency, power, service class and optional
destination.

The TDMA radio model uses three units to describe time allocation: *slot*,
*frame* and *multiframe*.  A slot is the smallest unit of time and is
defined in microseconds. A slot supports the transmission of a single
burst of a maximum length accounting for payload and overhead
(preamble, headers, guard times, propagation delay, etc.).  A frame
contains a number of slots.  A multiframe contains a number of frames.

The TDMA radio model receives a schedule via a [`TDMAScheduleEvent`](tdma-radio-model#tdmascheduleevent). There are two types of TDMA
 schedules: *full* and *update*. A full TDMA schedule defines the TDMA
 structure in use along with assigning per *NEM* transmit, receive and
 idle slots. The TDMA structure defines:

   * Slot size in microseconds
   
   * Slot overhead in microseconds
   
   * Number of slots per frame
   
   * Number of frames per multiframe
   
   * Transceiver bandwidth in Hz


Slot overhead should be set to account for the various waveform
overhead parameters such as synchronization, waveform headers,
turnaround time, propagation delay, etc.  At a minimum, the
*slotoverhead* should be set to the maximum propagation you expect the
signal to travel when using location events within your emulation.
For example, if you expect to support ranges out to 10km with the TDMA
model, the overhead in the schedule should be set to at least 34
microseconds.  This will ensure the *max amount of data packed in each
frame* + *the max propagation delay* will always be less than the
*slot size*.  Failure to do so, can result in frames being discarded
by the receiver when end of reception crosses the slot boundary.

An update TDMA schedule changes slot assignment information for an *NEM*
but does not change the TDMA structure.

TDMA slots can be assigned as transmit, receive and idle. A transmit
slot is assigned a frequency (Hz), power (dBm), class ([0,4]),
data rate (bps) and an optional destination *NEM*. A receive slot is
assigned a frequency (Hz). An idle slot has no assignments and
indicates an *NEM* is neither transmitting nor receiving.

When a TDMA radio model instance receives its schedule, it will take affect
at the start of the next multiframe boundary which is referenced from
the epoch: 00:00:00 UTC January 1, 1970.

### Packet Completion Rate Curves

The TDMA Model Packet Completion Rate is specified as curves defined
via XML. . Each curve definition comprises a series SINR values along
with their corresponding probability of reception for a given data rate
specified in *bps*. A curve definition must contain a minimum of two
points with one SINR representing *POR = 0* and one SINR representing
*POR = 100*. Linear interpolation is preformed when an exact SINR
match is not found. If a POR is requested for a data rate whose curve
was not defined, the first curve in the file is used regardless of its
associated data rate.

Specifying a packet size (`<tdmabasemodel-pcr>` attribute
`packetsize`) in the curve file will adjust the POR based on received
packet size. Specifying a `packetsize` of 0 disregards received packet
size when computing the POR.

The POR is obtained using the following calculation when a non-zero
*pktsize* is specified:

$$POR = POR_0 ^ {S_1/S_0}$$

Where,

$$POR_0$$ is the POR value determined from the PCR curve for
the given SINR value

$$S_0$$ is the packet size specified in the curve file
`pktsize`

$$S_1$$ is the received packet size

The below PCR curve file is used by all nodes in the `tdma-01`
example. These curves are the same as the ones used for the
IEEE802.11abg radio model based on theoretical equations for
determining Bit Error Rate (BER) in an Additive White Gaussian Noise
(AWGN) channel and are for illustrative purposes only. Packet
Completion Rate curves should be representative of the waveform being
emulated.

```xml
<tdmabasemodel-pcr packetsize="128">
  <datarate bps="1M">
    <entry sinr="-9.0"  por="0.0"/>
    <entry sinr="-8.0"  por="1.4"/>
    <entry sinr="-7.0"  por="21.0"/>
    <entry sinr="-6.0"  por="63.5"/>
    <entry sinr="-5.0"  por="90.7"/>
    <entry sinr="-4.0"  por="98.6"/>
    <entry sinr="-3.0"  por="99.9"/>
    <entry sinr="-2.0"  por="100.0"/>
  </datarate>
  <datarate bps="2M">
    <entry sinr="-6.0"  por="0"/>
    <entry sinr="-5.0"  por="1.4"/>
    <entry sinr="-4.0"  por="20.6"/>
    <entry sinr="-3.0"  por="63.1"/>
    <entry sinr="-2.0"  por="90.5"/>
    <entry sinr="-1.0"  por="98.5"/>
    <entry sinr="0.0"   por="99.9"/>
    <entry sinr="1.0"   por="100.0"/>

<... snippet: only 20 lines shown...>
```
<p style="float:right;font-family:courier;font-size:75%">emane-guide/examples/tdma-01/node-1/emane-tdma-pcr.xml</p><br>

{: .warning }
> Packet Completion Rate (PCR) curves should be
representative of the waveform being emulated. The curves used for the
TDMA radio model example are the same as the IEEE 802.11abg example
and are for illustrative purposes only.

## Working with TDMA Schedules

A TDMA Schedule is defined using XML. The XML
[schema](https://github.com/adjacentlink/emane/blob/master/src/python/emane/events/schema/tdmaschedule.xsd)
documents the details involved in authoring a schedule. Some important
items to consider:

1. A schedule that contains a `<structure>` element is a full schedule
   and one without is an update schedule.
 
2. A multiframe can define a default frequency, power, data rate and
   class. A frame can define the same defaults, overriding all or some
   of those defined in the multiframe. A transmit slot can override
   all or some frame or multiframe defaults, plus add an optional
   destination *NEM*. A receive slot can only override frequency.
 
3. For a full schedule, any frame not defined will be idle for all
   *NEMs* referenced in the schedule.
 
4. For a full schedule, any slot not defined in a frame will be a
   receive slot for all *NEMs* referenced in the schedule.  The frame
   default frequency will be used, if specified. Otherwise, the
   multiframe default frequency will be used.
 
5. For an update schedule, only those slots assigned for specified
   *NEMs* are modified. No receive slot or idle frame auto-fill occurs.
 
6. For a full schedule, the set of frequencies used by an *NEM* are sent
   to the physical layer to configure the frequency of interest list
   monitored by the spectrum monitor.
 
7. For an update schedule, any additional frequencies used by an *NEM*
   are added to the FOI frequency set cached since the last full
   schedule and sent to the physical layer.
 
8. Reception of a full schedule resets all TDMA schedule information.

9. TDMA radio model instances can reject schedules that contains
   errors. Acceptance and rejection of a schedule is conveyed using
   the following statistics:
 
    * `scheduler.scheduleAcceptFull`
    
    * `scheduler.scheduleAcceptUpdate`
    
    * `scheduler.scheduleRejectFrameIndexRange`
    
    * `scheduler.scheduleRejectSlotIndexRange`
    
    * `scheduler.scheduleRejectUpdateBeforeFull`
    
    * `scheduler.scheduleRejectOther`
    
10. Only *NEMs* referenced within a schedule XML file receive events
    when using `emaneevent-tdmaschedule`. As such, all *NEMs* within
    the scenario utilizing the TDMA radio model must be referenced
    within a full schedule.
 
11. Reception of a full or update schedule containing one or more
    errors will cause a TDMA radio model instance to flush all
    schedule information, resetting to its initial state of having no
    schedule.

Below is a complex example of a TDMA XML Schedule.

```xml
<emane-tdma-schedule >
  <structure frames='4' slots='10' slotoverhead='0' slotduration='1000' bandwidth='1M'/>
  <multiframe frequency='2.4G' power='0' class='0' datarate='1M'>
    <frame index='0'>
      <slot index='0,5' nodes='1'>
        <tx/>
      </slot>
      <slot index='1,6' nodes='2'>
        <tx/>
      </slot>
      <slot index='2,7' nodes='3'>
        <tx/>
      </slot>
      <slot index='3,8' nodes='4'>
        <tx power='30'/>
      </slot>
      <slot index='4,9' nodes='5'>
        <tx/>
      </slot>
    </frame>
    <frame index='1' datarate='11M'>
      <slot index='0:4' nodes='1'>
        <tx/>
      </slot>
      <slot index='5' nodes='2'>
        <tx/>
      </slot>
      <slot index='6' nodes='3'>
        <tx/>
      </slot>
      <slot index='7' nodes='4'>
        <tx/>
      </slot>
      <slot index='8' nodes='5'>
        <tx destination='2'/>
      </slot>
    </frame>
    <frame index='2'>
      <slot index='0:9' nodes='1'>
        <tx frequency='2G' class='3'/>
      </slot>
      <slot index='0:9' nodes='2:10'>
        <rx frequency='2G'/>
      </slot>
    </frame>
  </multiframe>
</emane-tdma-schedule>
```

### Sending a Schedule

A TDMA schedule is sent to a TDMA radio model instance using a [`TDMAScheduleEvent`](tdma-radio-model#tdmascheduleevent). The `emaneevent-tdmaschedule` script
 can be used to process a TDMA Schedule XML file. A schedule event is
 sent to each *NEM* referenced in the schedule XML. Each event contains
 only schedule information for the recipient *NEM*.

```text
$ emaneevent-tdmaschedule your-desired-schedule.xml -i lo
```

### Verifying a Schedule

TDMA radio model instances contain statistics to indicate the number
of full and update schedules accepted and rejected.

```text
$ emanesh localhost get stat 1 mac | grep scheduler

nem 1   mac  scheduler.scheduleAcceptFull = 4
nem 1   mac  scheduler.scheduleAcceptUpdate = 0
nem 1   mac  scheduler.scheduleRejectFrameIndexRange = 0
nem 1   mac  scheduler.scheduleRejectSlotIndexRange = 0
nem 1   mac  scheduler.scheduleRejectUpdateBeforeFull = 0
```

TDMA radio model instances maintain a schedule and structure table that
indicates the current schedule and slot structure.

```text
$ emanesh localhost get table 1 mac scheduler.ScheduleInfoTable scheduler.StructureInfoTable

nem 1   mac scheduler.ScheduleInfoTable
| Index | Frame | Slot | Type | Frequency  | Data Rate | Power | Class | Destination |
| 0     | 0     | 0    | TX   | 2400000000 | 1000000   | 0.0   | 0     | 0           |
| 1     | 0     | 1    | RX   | 2400000000 |           |       |       |             |
| 2     | 0     | 2    | RX   | 2400000000 |           |       |       |             |
| 3     | 0     | 3    | RX   | 2400000000 |           |       |       |             |
| 4     | 0     | 4    | RX   | 2400000000 |           |       |       |             |
| 5     | 0     | 5    | TX   | 2400000000 | 1000000   | 0.0   | 0     | 0           |
| 6     | 0     | 6    | RX   | 2400000000 |           |       |       |             |
| 7     | 0     | 7    | RX   | 2400000000 |           |       |       |             |
| 8     | 0     | 8    | RX   | 2400000000 |           |       |       |             |
| 9     | 0     | 9    | RX   | 2400000000 |           |       |       |             |
| 10    | 1     | 0    | TX   | 2400000000 | 11000000  | 0.0   | 0     | 0           |
| 11    | 1     | 1    | TX   | 2400000000 | 11000000  | 0.0   | 0     | 0           |
| 12    | 1     | 2    | TX   | 2400000000 | 11000000  | 0.0   | 0     | 0           |
| 13    | 1     | 3    | TX   | 2400000000 | 11000000  | 0.0   | 0     | 0           |
| 14    | 1     | 4    | TX   | 2400000000 | 11000000  | 0.0   | 0     | 0           |
| 15    | 1     | 5    | RX   | 2400000000 |           |       |       |             |
| 16    | 1     | 6    | RX   | 2400000000 |           |       |       |             |
| 17    | 1     | 7    | RX   | 2400000000 |           |       |       |             |
| 18    | 1     | 8    | RX   | 2400000000 |           |       |       |             |
| 19    | 1     | 9    | RX   | 2400000000 |           |       |       |             |
| 20    | 2     | 0    | TX   | 2000000000 | 1000000   | 0.0   | 3     | 0           |
| 21    | 2     | 1    | TX   | 2000000000 | 1000000   | 0.0   | 3     | 0           |
| 22    | 2     | 2    | TX   | 2000000000 | 1000000   | 0.0   | 3     | 0           |
| 23    | 2     | 3    | TX   | 2000000000 | 1000000   | 0.0   | 3     | 0           |
| 24    | 2     | 4    | TX   | 2000000000 | 1000000   | 0.0   | 3     | 0           |
| 25    | 2     | 5    | TX   | 2000000000 | 1000000   | 0.0   | 3     | 0           |
| 26    | 2     | 6    | TX   | 2000000000 | 1000000   | 0.0   | 3     | 0           |
| 27    | 2     | 7    | TX   | 2000000000 | 1000000   | 0.0   | 3     | 0           |
| 28    | 2     | 8    | TX   | 2000000000 | 1000000   | 0.0   | 3     | 0           |
| 29    | 2     | 9    | TX   | 2000000000 | 1000000   | 0.0   | 3     | 0           |
| 30    | 3     | 0    | IDLE |            |           |       |       |             |
| 31    | 3     | 1    | IDLE |            |           |       |       |             |
| 32    | 3     | 2    | IDLE |            |           |       |       |             |
| 33    | 3     | 3    | IDLE |            |           |       |       |             |
| 34    | 3     | 4    | IDLE |            |           |       |       |             |
| 35    | 3     | 5    | IDLE |            |           |       |       |             |
| 36    | 3     | 6    | IDLE |            |           |       |       |             |
| 37    | 3     | 7    | IDLE |            |           |       |       |             |
| 38    | 3     | 8    | IDLE |            |           |       |       |             |
| 39    | 3     | 9    | IDLE |            |           |       |       |             |

nem 1   mac scheduler.StructureInfoTable
| Name         | Value   |
| bandwidth    | 1000000 |
| frames       | 4       |
| slotduration | 1000    |
| slotoverhead | 0       |
| slots        | 10      |
```

## `TDMAScheduleEvent`

An `TDMAScheduleEvent` is used to set a TDMA radio model *NEM's*
schedule.

```protobuf
package EMANEMessage;
option optimize_for = SPEED;
message TDMAScheduleEvent
{
  message Frame
  {
    message Slot
    {
      enum Type
      {
        SLOT_TX = 1;
        SLOT_RX = 2;
        SLOT_IDLE = 3;
      }
      message Tx
      {
        optional uint64 frequencyHz = 1;
        optional uint64 dataRatebps = 2;
        optional uint32 serviceClass = 3;
        optional double powerdBm = 4;
        optional uint32 destination = 5;
      }
      message Rx
      {
        optional uint64 frequencyHz = 1;
      }
      required uint32 index = 1;
      required Type type = 2;
      optional Tx tx = 3;
      optional Rx rx = 4;
    }
    required uint32 index = 1;
    optional uint64 frequencyHz = 2;
    optional uint64 dataRatebps = 3;
    optional uint32 serviceClass = 4;
    optional double powerdBm = 5;
    repeated Slot slots = 6;
  }
  message Structure
  {
    required uint32 slotsPerFrame = 1;
    required uint32 framesPerMultiFrame = 2;
    required uint64 slotDurationMicroseconds = 3;
    required uint64 slotOverheadMicroseconds = 4;
    required uint64 bandwidthHz = 5;
  }
  repeated Frame frames = 1;
  optional Structure structure = 2;
  optional uint64 frequencyHz = 3;
  optional uint64 dataRatebps = 4;
  optional uint32 serviceClass = 5;
  optional double powerdBm = 6;
}
```
<p style="float:right;font-family:courier;font-size:75%">emane/src/libemane/tdmascheduleevent.proto</p><br>


## Timing and Slot Size

Proper time synchronization is required for the TDMA radio model. The
required tightness of the time synchronization is a function of the
slot size configured using [`TDMAScheduleEvents`](tdma-radio-model#tdmascheduleevent).  System
configuration, number of emulated nodes, traffic scenario and general
resource availability, are all factors in determining achievable slot
sizes.

## Configuration

1. **`enablepromiscuousmode`**: Defines whether promiscuous mode is
   enabled or not. If promiscuous mode is enabled, all received packets
   (intended for the given node or not) that pass the probability of
   reception check are sent upstream to the transport.
   
   ```no-highlighting
   Default: yes                   Required: no                    Modifiable: yes                 
   Type:    bool                  Occurrs:  [1,1]                 Range:      [false,true]        
   Values:  false
   ```

2. **`flowcontrolenable`**: Defines whether flow control is enabled.
   Flow control only works with the virtual transport and the setting
   must match the setting within the virtual transport configuration.
   
   ```no-highlighting
   Default: yes                   Required: no                    Modifiable: no                  
   Type:    bool                  Occurrs:  [1,1]                 Range:      [false,true]        
   Values:  false
   ```

3. **`flowcontroltokens`**: Defines the maximum number of flow control
   tokens (packet transmission units) that can be processed from the
   virtual transport without being refreshed. The number of available
   tokens at any given time is coordinated with the virtual transport and
   when the token count reaches zero, no further packets are transmitted
   causing application socket queues to backup.
   
   ```no-highlighting
   Default: yes                   Required: no                    Modifiable: no                  
   Type:    uint16                Occurrs:  [1,1]                 Range:      [0,65535]           
   Values:  10
   ```

4. **`fragmentcheckthreshold`**: Defines the rate in seconds a check
   is performed to see if any packet fragment reassembly efforts should
   be abandoned.
   
   ```no-highlighting
   Default: yes                   Required: no                    Modifiable: no                  
   Type:    uint16                Occurrs:  [1,1]                 Range:      [0,65535]           
   Values:  2
   ```

5. **`fragmenttimeoutthreshold`**: Defines the threshold in seconds to
   wait for another packet fragment for an existing reassembly effort
   before abandoning the effort.
   
   ```no-highlighting
   Default: yes                   Required: no                    Modifiable: no                  
   Type:    uint16                Occurrs:  [1,1]                 Range:      [0,65535]           
   Values:  5
   ```

6. **`neighbormetricdeletetime`**: Defines the time in seconds of no
   RF receptions from a given neighbor before it is removed from the
   neighbor table.
   
   ```no-highlighting
   Default: yes                   Required: no                    Modifiable: yes                 
   Type:    float                 Occurrs:  [1,1]                 Range:      [1.000000,3660.000000]
   Values:  60.000000
   ```

7. **`neighbormetricupdateinterval`**: Defines the neighbor table
   update interval in seconds.
   
   ```no-highlighting
   Default: yes                   Required: no                    Modifiable: no                  
   Type:    float                 Occurrs:  [1,1]                 Range:      [0.100000,60.000000]
   Values:  1.000000
   ```

8. **`pcrcurveuri`**: Defines the URI of the Packet Completion Rate
   (PCR) curve file. The PCR curve file contains probability of reception
   curves as a function of Signal to Interference plus Noise Ratio
   (SINR).
   
   ```no-highlighting
   Default: no                    Required: yes                   Modifiable: no                  
   Type:    string                Occurrs:  [1,1]               
   ```

9. **`queue.aggregationenable`**: Defines whether packet aggregation
   is enabled for transmission. When enabled, multiple packets can be
   sent in the same transmission when there is additional room within the
   slot.
   
   ```no-highlighting
   Default: yes                   Required: no                    Modifiable: no                  
   Type:    bool                  Occurrs:  [1,1]                 Range:      [false,true]        
   Values:  true
   ```

10. **`queue.aggregationslotthreshold`**: Defines the percentage of a
    slot that must be filled in order to conclude aggregation when
    queue.aggregationenable is enabled.
    
    ```no-highlighting
    Default: yes                   Required: no                    Modifiable: no                  
    Type:    double                Occurrs:  [1,1]                 Range:      [0.000000,100.000000]
    Values:  90.000000
    ```

11. **`queue.depth`**: Defines the size of the per service class
    downstream packet queues (in packets). Each of the 5 queues (control +
    4 service classes) will be 'queuedepth' size.
    
    ```no-highlighting
    Default: yes                   Required: no                    Modifiable: no                  
    Type:    uint16                Occurrs:  [1,1]                 Range:      [0,65535]           
    Values:  256
    ```

12. **`queue.fragmentationenable`**: Defines whether packet
    fragmentation is enabled. When enabled, a single packet will be
    fragmented into multiple message components to be sent over multiple
    transmissions when the slot is too small.  When disabled and the
    packet matches the traffic class for the transmit slot as defined in
    the TDMA schedule, the packet will be discarded.
    
    ```no-highlighting
    Default: yes                   Required: no                    Modifiable: no                  
    Type:    bool                  Occurrs:  [1,1]                 Range:      [false,true]        
    Values:  true
    ```

13. **`queue.strictdequeueenable`**: Defines whether packets will be
    dequeued from a queue other than what has been specified when there
    are no eligible packets for dequeue in the specified queue. Queues are
    dequeued highest priority first.
    
    ```no-highlighting
    Default: yes                   Required: no                    Modifiable: no                  
    Type:    bool                  Occurrs:  [1,1]                 Range:      [false,true]        
    Values:  false
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

5. **`highWaterMarkQueue0`**: High water mark queue 0
   
   ```no-highlighting
   Type: uint64                Clearable: yes                 
   ```

6. **`highWaterMarkQueue1`**: High water mark queue 1
   
   ```no-highlighting
   Type: uint64                Clearable: yes                 
   ```

7. **`highWaterMarkQueue2`**: High water mark queue 2
   
   ```no-highlighting
   Type: uint64                Clearable: yes                 
   ```

8. **`highWaterMarkQueue3`**: High water mark queue 3
   
   ```no-highlighting
   Type: uint64                Clearable: yes                 
   ```

9. **`highWaterMarkQueue4`**: High water mark queue 4
   
   ```no-highlighting
   Type: uint64                Clearable: yes                 
   ```

10. **`numAPIQueued`**: The number of queued API events.
    
    ```no-highlighting
    Type: uint64                Clearable: yes                 
    ```

11. **`numRxSlotErrorMissed`**: Number of Rx slot missed errors.
    
    ```no-highlighting
    Type: uint64                Clearable: no                  
    ```

12. **`numRxSlotErrorRxDuringIdle`**: Number of Rx slot rx during idle
    errors.
    
    ```no-highlighting
    Type: uint64                Clearable: no                  
    ```

13. **`numRxSlotErrorRxDuringTx`**: Number of Rx slot during tx
    errors.
    
    ```no-highlighting
    Type: uint64                Clearable: no                  
    ```

14. **`numRxSlotErrorRxLock`**: Number of Rx slot rx lock errors.
    
    ```no-highlighting
    Type: uint64                Clearable: no                  
    ```

15. **`numRxSlotErrorRxTooLong`**: Number of Rx slot rx too long
    errors.
    
    ```no-highlighting
    Type: uint64                Clearable: no                  
    ```

16. **`numRxSlotErrorRxWrongFrequency`**: Number of Rx slot rx wrong
    frequency errors.
    
    ```no-highlighting
    Type: uint64                Clearable: no                  
    ```

17. **`numRxSlotValid`**: Number of valid Rx slots
    
    ```no-highlighting
    Type: uint64                Clearable: no                  
    ```

18. **`numTxSlotErrorMissed`**: Number of Tx slot missed errors.
    
    ```no-highlighting
    Type: uint64                Clearable: no                  
    ```

19. **`numTxSlotErrorTooBig`**: Number of Tx slot too big errors.
    
    ```no-highlighting
    Type: uint64                Clearable: no                  
    ```

20. **`numTxSlotValid`**: Number of valid Tx slots
    
    ```no-highlighting
    Type: uint64                Clearable: no                  
    ```

21. **`processedConfiguration`**: The number of processed
    configuration.
    
    ```no-highlighting
    Type: uint64                Clearable: yes                 
    ```

22. **`processedDownstreamControl`**: The number of processed
    downstream control.
    
    ```no-highlighting
    Type: uint64                Clearable: yes                 
    ```

23. **`processedDownstreamPackets`**: The number of processed
    downstream packets.
    
    ```no-highlighting
    Type: uint64                Clearable: yes                 
    ```

24. **`processedEvents`**: The number of processed events.
    
    ```no-highlighting
    Type: uint64                Clearable: yes                 
    ```

25. **`processedTimedEvents`**: The number of processed timed events.
    
    ```no-highlighting
    Type: uint64                Clearable: yes                 
    ```

26. **`processedUpstreamControl`**: The number of processed upstream
    control.
    
    ```no-highlighting
    Type: uint64                Clearable: yes                 
    ```

27. **`processedUpstreamPackets`**: The number of processed upstream
    packets.
    
    ```no-highlighting
    Type: uint64                Clearable: yes                 
    ```

28. **`scheduler.scheduleAcceptFull`**: Number of full schedules
    accepted.
    
    ```no-highlighting
    Type: uint64                Clearable: yes                 
    ```

29. **`scheduler.scheduleAcceptUpdate`**: Number of update schedules
    accepted.
    
    ```no-highlighting
    Type: uint64                Clearable: yes                 
    ```

30. **`scheduler.scheduleRejectFrameIndexRange`**: Number of schedules
    rejected due to out of range frame index.
    
    ```no-highlighting
    Type: uint64                Clearable: yes                 
    ```

31. **`scheduler.scheduleRejectOther`**: Number of schedules rejected
    due to other reasons.
    
    ```no-highlighting
    Type: uint64                Clearable: yes                 
    ```

32. **`scheduler.scheduleRejectSlotIndexRange`**: Number of schedules
    rejected due to out of range slot index.
    
    ```no-highlighting
    Type: uint64                Clearable: yes                 
    ```

33. **`scheduler.scheduleRejectUpdateBeforeFull`**: Number of
    schedules rejected due to an update before full schedule.
    
    ```no-highlighting
    Type: uint64                Clearable: yes                 
    ```



## Statistic Tables

Aggregation and fragmentation make it difficult to convey packet based
statistic information. The TDMA radio model addresses this by keeping
track of byte statistics where message components are used and packet
statistics where queue information is conveyed. This is different from
other radio models.

1. **`BroadcastByteAcceptTable0`**: Broadcast bytes accepted
   
   ```no-highlighting
   Clearable:  yes
   ```

2. **`BroadcastByteAcceptTable1`**: Broadcast bytes accepted
   
   ```no-highlighting
   Clearable:  yes
   ```

3. **`BroadcastByteAcceptTable2`**: Broadcast bytes accepted
   
   ```no-highlighting
   Clearable:  yes
   ```

4. **`BroadcastByteAcceptTable3`**: Broadcast bytes accepted
   
   ```no-highlighting
   Clearable:  yes
   ```

5. **`BroadcastByteAcceptTable4`**: Broadcast bytes accepted
   
   ```no-highlighting
   Clearable:  yes
   ```

6. **`BroadcastByteDropTable0`**: Broadcast bytes dropped
   
   ```no-highlighting
   Clearable:  yes
   ```

7. **`BroadcastByteDropTable1`**: Broadcast bytes dropped
   
   ```no-highlighting
   Clearable:  yes
   ```

8. **`BroadcastByteDropTable2`**: Broadcast bytes dropped
   
   ```no-highlighting
   Clearable:  yes
   ```

9. **`BroadcastByteDropTable3`**: Broadcast bytes dropped
   
   ```no-highlighting
   Clearable:  yes
   ```

10. **`BroadcastByteDropTable4`**: Broadcast bytes dropped
    
    ```no-highlighting
    Clearable:  yes
    ```

11. **`EventReceptionTable`**: Received event counts
    
    ```no-highlighting
    Clearable:  yes
    ```

12. **`NeighborMetricTable`**: Neighbor Metric Table
    
    ```no-highlighting
    Clearable:  no
    ```

13. **`NeighborStatusTable`**: Neighbor Status Table
    
    ```no-highlighting
    Clearable:  no
    ```

14. **`PacketComponentAggregationHistogram`**: Shows a histogram of
    the number of components contained in transmitted messages.
    
    ```no-highlighting
    Clearable:  no
    ```

15. **`QueueFragmentHistogram`**: Shows a per queue histogram of the
    number of message components required to transmit packets.
    
    ```no-highlighting
    Clearable:  no
    ```

16. **`QueueStatusTable`**: Shows for each queue the number of packets
    enqueued, dequeued, dropped due to queue overflow (enqueue), dropped
    due to too big (dequeue) and which slot classes fragments are being
    transmitted.
    
    ```no-highlighting
    Clearable:  no
    ```

17. **`RxSlotStatusTable`**: Shows the number of Rx slot receptions
    that were valid or missed based on slot timing deadlines
    
    ```no-highlighting
    Clearable:  no
    ```

18. **`TxSlotStatusTable`**: Shows the number of Tx slot opportunities
    that were valid or missed based on slot timing deadlines
    
    ```no-highlighting
    Clearable:  no
    ```

19. **`UnicastByteAcceptTable0`**: Unicast bytes accepted
    
    ```no-highlighting
    Clearable:  yes
    ```

20. **`UnicastByteAcceptTable1`**: Unicast bytes accepted
    
    ```no-highlighting
    Clearable:  yes
    ```

21. **`UnicastByteAcceptTable2`**: Unicast bytes accepted
    
    ```no-highlighting
    Clearable:  yes
    ```

22. **`UnicastByteAcceptTable3`**: Unicast bytes accepted
    
    ```no-highlighting
    Clearable:  yes
    ```

23. **`UnicastByteAcceptTable4`**: Unicast bytes accepted
    
    ```no-highlighting
    Clearable:  yes
    ```

24. **`UnicastByteDropTable0`**: Unicast bytes dropped
    
    ```no-highlighting
    Clearable:  yes
    ```

25. **`UnicastByteDropTable1`**: Unicast bytes dropped
    
    ```no-highlighting
    Clearable:  yes
    ```

26. **`UnicastByteDropTable2`**: Unicast bytes dropped
    
    ```no-highlighting
    Clearable:  yes
    ```

27. **`UnicastByteDropTable3`**: Unicast bytes dropped
    
    ```no-highlighting
    Clearable:  yes
    ```

28. **`UnicastByteDropTable4`**: Unicast bytes dropped
    
    ```no-highlighting
    Clearable:  yes
    ```

29. **`scheduler.ScheduleInfoTable`**: Shows the current TDMA
    schedule.
    
    ```no-highlighting
    Clearable:  no
    ```

30. **`scheduler.StructureInfoTable`**: Shows the current TDMA
    structure: slot size, slot overhead, number of slots per frame, number
    of frames per multiframe and transceiver bandwidth.
    
    ```no-highlighting
    Clearable:  no
    ```



## Examples

This guide includes the TDMA example:

1. `tdma-01`:  A five node example using precomputed pathloss and
   running the B.A.T.M.A.N manet protocol.

### tdma-01

![](images/auto-generated-topology-tdma-01.png){: width="60%"; .centered}
<p style="text-align:center;font-size:75%">tdma-01 experiment components</p><br>

The `tdma-01` example experiment contains five nodes, each running
the B.A.T.M.A.N. routing protocol.

All physical layers are configured to use the `precomputed` propagation
model and `emaneeventservice` publishes [`PathlossEvents`](events#pathlossevent)
using pathloss values in `scenario.eel`.

```text
0.0  nem:1 pathloss nem:2,80
0.0  nem:1 pathloss nem:3,80
0.0  nem:1 pathloss nem:4,80
0.0  nem:1 pathloss nem:5,80

0.0  nem:2 pathloss nem:3,80
0.0  nem:2 pathloss nem:4,80
0.0  nem:2 pathloss nem:5,80

0.0  nem:3 pathloss nem:4,80
0.0  nem:3 pathloss nem:5,80

0.0  nem:4 pathloss nem:5,80
```
<p style="float:right;font-family:courier;font-size:75%">emane-guide/examples/tdma-01/host/scenario.eel</p><br>

This example uses the TDMA schedule defined in `schedule.xml`.

```xml
<emane-tdma-schedule>
  <structure frames="1" slots="10" slotoverhead="640" slotduration="10000" bandwidth="5M"/>
  <multiframe frequency="1.2G" power="50" class="0" datarate="9M">
    <frame index="0">
      <slot index="0,5" nodes="1"/>
      <slot index="1,6" nodes="2"/>
      <slot index="2,7" nodes="3"/>
      <slot index="3,8" nodes="4"/>
      <slot index="4,9" nodes="5"/>
    </frame>
  </multiframe>
</emane-tdma-schedule>
```
<p style="float:right;font-family:courier;font-size:75%">emane-guide/examples/tdma-01/schedule.xml</p><br>

![](images/auto-generated-run-tdma-01.png){:width="75%"; .centered}

With `emane-guide/examples/tdma-01` running, we can use `emanesh` to
view the schedule assigned to `node-1` and compare this to the TDMA
schedule XML.

```text
$ emanesh node-1 get table nems mac scheduler.ScheduleInfoTable scheduler.StructureInfoTable
nem 1   mac scheduler.ScheduleInfoTable
| Index | Frame | Slot | Type | Frequency  | Data Rate | Power | Class | Destination |
| 0     | 0     | 0    | TX   | 1200000000 | 9000000   | 50.0  | 0     | 0           |
| 1     | 0     | 1    | RX   | 1200000000 |           |       |       |             |
| 2     | 0     | 2    | RX   | 1200000000 |           |       |       |             |
| 3     | 0     | 3    | RX   | 1200000000 |           |       |       |             |
| 4     | 0     | 4    | RX   | 1200000000 |           |       |       |             |
| 5     | 0     | 5    | TX   | 1200000000 | 9000000   | 50.0  | 0     | 0           |
| 6     | 0     | 6    | RX   | 1200000000 |           |       |       |             |
| 7     | 0     | 7    | RX   | 1200000000 |           |       |       |             |
| 8     | 0     | 8    | RX   | 1200000000 |           |       |       |             |
| 9     | 0     | 9    | RX   | 1200000000 |           |       |       |             |

nem 1   mac scheduler.StructureInfoTable
| Name         | Value   |
| bandwidth    | 5000000 |
| frames       | 1       |
| slotduration | 10000   |
| slotoverhead | 640     |
| slots        | 10      |
```

Using `diff`, we can quickly compare the schedules for `node-1` and
`node-2` to verify the only differences are in the assigned transmit
slots.

```text
$ diff \
  <(emanesh node-1 get table nems mac scheduler.ScheduleInfoTable scheduler.StructureInfoTable \
    | sed -e 's/| //g' -e 's/ |//g') \
  <(emanesh node-2 get table nems mac scheduler.ScheduleInfoTable scheduler.StructureInfoTable \
    | sed -e 's/| //g' -e 's/ |//g') \
  --side-by-side
nem 1   mac scheduler.ScheduleInfoTable                       | nem 2   mac scheduler.ScheduleInfoTable
Index Frame Slot Type Frequency  Data Rate Power Class Destin   Index Frame Slot Type Frequency  Data Rate Power Class Destin
0     0     0    TX   1200000000 9000000   50.0  0     0      | 0     0     0    RX   1200000000
1     0     1    RX   1200000000                              | 1     0     1    TX   1200000000 9000000   50.0  0     0
2     0     2    RX   1200000000                                2     0     2    RX   1200000000
3     0     3    RX   1200000000                                3     0     3    RX   1200000000
4     0     4    RX   1200000000                                4     0     4    RX   1200000000
5     0     5    TX   1200000000 9000000   50.0  0     0      | 5     0     5    RX   1200000000
6     0     6    RX   1200000000                              | 6     0     6    TX   1200000000 9000000   50.0  0     0
7     0     7    RX   1200000000                                7     0     7    RX   1200000000
8     0     8    RX   1200000000                                8     0     8    RX   1200000000
9     0     9    RX   1200000000                                9     0     9    RX   1200000000

nem 1   mac scheduler.StructureInfoTable                      | nem 2   mac scheduler.StructureInfoTable
Name         Value                                              Name         Value
bandwidth    5000000                                            bandwidth    5000000
frames       1                                                  frames       1
slotduration 10000                                              slotduration 10000
slotoverhead 640                                                slotoverhead 640
slots        10                                                 slots        10
```

Monitoring the `RxSlotStatusTable` and `TxSlotStatusTable` statistic
tables provides a way to assess the health of the emulation when using
the TDMA radio model. Both tables indicate the number of valid slots,
receive and transmit, respectively, along with the quartile the radio
model handled the slot activity.

```text
$ emanesh node-1 get table nems mac RxSlotStatusTable TxSlotStatusTable
nem 1   mac RxSlotStatusTable
|Index|Frame|Slot|Valid|Missed|Idle|Tx|Long|Freq|Lock|.25  |.50|.75|1.0|1.25|1.50|1.75|>1.75|
|0    |0    |0   |0    |0     |0   |0 |2   |0   |0   |0    |2  |0  |0  |0   |0   |0   |0    |
|1    |0    |1   |23121|0     |0   |0 |6   |0   |0   |23127|0  |0  |0  |0   |0   |0   |0    |
|2    |0    |2   |24992|0     |0   |0 |35  |0   |0   |24988|3  |36 |0  |0   |0   |0   |0    |
|3    |0    |3   |23267|3     |0   |0 |2   |0   |0   |23266|3  |0  |0  |0   |0   |0   |3    |
|4    |0    |4   |25380|3     |0   |0 |0   |0   |0   |25378|2  |0  |0  |0   |0   |0   |3    |
|6    |0    |6   |25505|0     |0   |0 |2   |0   |0   |25505|2  |0  |0  |0   |0   |0   |0    |
|7    |0    |7   |23029|0     |0   |0 |0   |0   |0   |23029|0  |0  |0  |0   |0   |0   |0    |
|8    |0    |8   |25351|0     |0   |0 |0   |0   |0   |25351|0  |0  |0  |0   |0   |0   |0    |
|9    |0    |9   |23202|0     |0   |0 |21  |0   |0   |23202|21 |0  |0  |0   |0   |0   |0    |

nem 1   mac TxSlotStatusTable
|Index|Frame|Slot|Valid|Missed|Big|.25  |.50|.75|1.0|1.25|1.50|1.75|>1.75|
|0    |0    |0   |60569|3     |0  |60569|0  |0  |0  |0   |0   |0   |3    |
|5    |0    |5   |60571|1     |0  |60571|0  |0  |0  |0   |0   |0   |1    |
```

A healthy emulation will have very minimal missed receive and transmit
slots, and will generally have most slot activity in the first two
quartiles. Activities such as decreasing slots size, increasing node
count, and increasing traffic profiles can affect TDMA radio model
performance as the server(s) hosting the emulation uses more CPU
resources.

OpenTestPoint Labtools can be used to create a variety of monitoring
tools to correlate statistics and tables from multiple nodes in an
experiment. The `tdma-slot-status.py` script is an example monitoring
tool that displays the delta receive and transmit slot success and
error counts.

Output can be displayed as a front-end graph or a text table (`-t/--table`).

```text
$ ~/dev/emane-guide/examples/scripts/tdma-slot-status.py localhost:9002
```

![](images/tdma-01-slot-status-monitor.png){:width="75%"; .centered}
<p style="text-align:center;font-size:75%">OpenTestPoint Labtools TDMA slot status monitor view of nodes in tdma-01.</p><br>

```text
$ ~/dev/emane-guide/examples/scripts/tdma-slot-status.py localhost:9002 -t
     Node  Rx Slot Success  Rx Slot Error  Tx Slot Success  Tx Slot Error
0  node-1              165              0              100              0
1  node-2              162              0              100              0
2  node-3              168              0              100              0
3  node-4              166              0              100              0
4  node-5              167              0              100              0
```
