---
layout: default
title: EEL Event Generator
nav_order: 17
permalink: /eel-event-generator
---


# EEL Event Generator

{: .warning }
> This chapter is incomplete.

## Features

The Emulation Event Log (EEL) Generator creates EMANE events from
input files in EEL Format. EEL format was developed by the [Protean
Research Group at Naval Research
Laboratory](http://www.nrl.navy.mil/itd/ncs).

> This (EEL) file format is a linear, text file format that can be
  used to convey the value of properties or parameters identified by a
  keyword. This file allows for ”events” affecting modeling system
  components and/or their properties that occur over time to be
  expressed (e.g. as a file format to ”drive” event generation over
  time) or to be logged (e.g. as a log file format for ”capturing”
  run-time events for replay or post-processing analysis). The EEL
  file is a text format consisting of lines (a.k.a. ”sentences”) that
  each contain a timestamp, some ”module identifier” and an event type
  ”keyword” that implies the format and interpretation of the
  remainder of the line.The ”keyword” approach allows a mixture of
  event types to be included within an EEL file and expanded over time
  as needed. Tools that process EEL file may choose to process a
  subset of event types as needed. The format also lends itself to
  simple filtering by event type, module identifier, etc using
  commonly-available tools (e.g., ”grep”, etc).

>The linear, time-ordered format also allows it to be incrementally
 processed such that even very bulky files can be handled as
 needed. Note that, in the interest of compactness, it is typically
 expected that the events included will represent ”deltas”
 (i.e. changes) to any previously established state. However, one
 could choose to have each time epoch (or at some less granular
 interval such as once per minute) include the complete modeling
 system state (e.g. all current node locations, adjacencies,
 etc). This would result in a more bulky EEL file but could enable
 processing tools to ”skip” to desired sections of the file without
 need to process the entire file from its beginning. This
 specification does not dictate or preclude such either usage.

> Thus, the skeleton format of lines within the EEL format is:

> \<time\> \<moduleID\> \<eventType\> \<type-specific fields ...\>

\[Emulation Schema Description, NRL Protean Research Group\]


The EEL Event Generator loads EEL sentence parsing plugins to parse
and build EMANE events. Plugins are associated with event type
keywords and are capable of producing either *full* or *delta* event
updates. A *delta* event update contains EMANE events corresponding to
EEL entries loaded since the last request for events made to the
plugin. A *full* event update contains all the EMANE events necessary
to convey the complete current state for all *moduleID* information
loaded by the respective plugin.

Any EEL entries encountered that are not handled by a loaded parser are ignored.

## Sentence Parser Plugins

There are four EEL sentence parsing plugins:

1. Pathloss Parser - Parses pathloss sentences and builds the resulting event.

   ```text
   <time> nem:<SrcId> pathloss [nem:<DestId>,<pathloss>[,<reversePathloss>]]+
   ```

   Where,  
   *pathoss* is the pathloss in dB  
   *reversePathloss* is the reverse pathloss in dB

2. PathlossEx Parser - Parses pathlossex sentences and builds the resulting event.

   ```text
   <time> nem:<SrcId> pathlossex [nem:<DestId>[,<frequency>:<pathloss>[:<reversePathloss>]]+]+ 
   ```

   Where,  
   *frequency* is the transmit center frequency in Hz  
   *pathoss* is the pathloss in dB  
   *reversePathloss* is the reverse pathloss in dB

3. Location Parser - Parses location sentences and builds the resulting event.

   ```text
   <time> nem:<Id> location gps <latitude>,<longitude>,<altitude>[,msl|agl]
   ```

    Where,  
    *latitude* is the latitude in degrees  
    *longitude* is the longitude in degrees  
    *altitude* is the altitude in meters

   ```text
   <time> nem:<Id> orientation <pitch>,<roll>,<yaw>
   ```

    Where,  
    *pitch* is the pitch in degrees  
    *roll* is the roll in degrees  
    *yaw* is the yaw in degrees

   ```text
   <time> nem:<Id> velocity <azimuth>,<elevation>,<magnitude>
   ```

    Where,  
    *azimuth* is the azimuth in degrees  
    *elevation* is the elevation in degrees  
    *magnitude* is the mgnitude in meters/second  

4. Antenna Profile Parser - Parses antenna profile sentences and builds the resulting event.

   ```text
   <time> nem:<Id> antennaprofile <profileId>,<azimuth>,<elevation>
   ```

    Where,  
   *profileId* is the antenna profile id  
   *azimuth* is the antenna azimuth in degrees  
   *elevation* is the antenna elevation degrees

5. Comm Effect Parser - Parses comm effect sentences and builds the resulting event.

   ```text
   <time> nem:<Id> commeffect [nem:<Id>,<CommEffectEntryList>]+

   CommEffectEntryList := <latencySeconds>,<jitterSeconds>,<probabilityLoss>,
                          <probabilityDuplication>,<unicastBitRate>,<multicastBitRate>
   ```

    Where,  
    *latencySeconds* is the latency seconds (float)  
    *jitterSeconds* is the jitter seconds (float)  
    *probabilityLoss* is the probability of loss (float)  
    *probabilityDuplication* is the probability of duplication (float)  
    *unicastBitRate* is the unicast bit rate in bits/second (uint64)  
    *multicastBitRate* is the multicast bit rate in bits/second (uint64)

6. Fading Selection Parser - Parses fading selection sentences and builds the resulting event.

   ```text
    <time> nem:<Id> fadingselection [nem:<Id>,'none'|'nakagami']+
    ```
   
### Example Sentences

```text
0.0  nem:70 pathLoss nem:22,96.3 nem:23,95.0 nem:24,95.1 nem:25,95.2 nem:26,95.3 nem:27,95.4 nem:28,95.5 nem:29,95.0 nem:30,95.1 nem:31,95.2 nem:32,95
0.0  nem:70 pathLoss nem:42,95.3 nem:43,95.4 nem:44,95.5 nem:45,95.0 nem:46,95.1 nem:47,95.2 nem:48,95.3 nem:49,95.4 nem:50,95.5 nem:51,95.5 nem:52,95.6
0.0  nem:70 pathLoss nem:62,95.2 nem:63,95.3 nem:64,95.4 nem:65,94.2 nem:66,94.2 nem:67,96.3 nem:68,96.3 nem:69,123.3 
0.0  nem:1 location gps 40.031075,-74.523518,3.000000
0.0  nem:2 location gps 40.031165,-74.523412,3.000000
0.0  nem:3 location gps 40.031227,-74.523247,3.000000
0.0  nem:4 location gps 40.031290,-74.523095,3.000000
0.0  nem:1 antennaprofile 1,0,90
0.0  nem:2 antennaprofile 1,0,270
0.0  nem:3 antennaprofile 1,0,90
0.0  nem:4 antennaprofile 1,0,270
0.0  nem:1 commeffect nem:2,1.050000,2.000300,10.000000,12.000000,45,54 nem:3,0.050000,0.025000,0.000000,0.000000,0,0 nem:4,0.000000,0.000000,50.000000,0.000000,0,0 
0.0  nem:2 commeffect nem:1,11.055000,22.000330,11.000000,13.000000,46,55 nem:3,0.000000,0.000000,0.000000,0.000000,10000,10000 nem:4,0.000000,0.000000,0.000000,0.000000,5000,5000 
0.0  nem:3 commeffect nem:1,0.050000,0.025000,0.000000,0.000000,0,0 nem:2,0.000000,0.000000,0.000000,0.000000,10000,10000 nem:4,0.000000,0.000000,0.000000,10.000000,0,0 
0.0  nem:4 commeffect nem:1,0.000000,0.000000,50.000000,0.000000,0,0 nem:2,0.000000,0.000000,0.000000,0.000000,5000,5000 nem:3,0.000000,0.000000,0.000000,10.000000,0,0 
0.0  nem:1 fadingselection nem:2,none nem:3,nakagami nem:4,none
```

## Configuration

1. **`inputfile`**: EEL Text input file.
   
   ```no-highlighting
   Default: no                    Required: yes                   Modifiable: no                  
   Type:    string                Occurrs:  [1,1024]            
   ```

2. **`loader`**: EEL Loader plugin.
   
   ```no-highlighting
   Default: no                    Required: yes                   Modifiable: no                  
   Type:    string                Occurrs:  [1,1024]            
   ```



## Example XML

```xml
<!DOCTYPE eventgenerator SYSTEM "file:///usr/share/emane/dtd/eventgenerator.dtd">
<eventgenerator library="eelgenerator">
  <paramlist name="inputfile">
    <item value="scenario0.eel"/>
    <item value="scenario1.eel"/>
  </paramlist>
  <paramlist name="loader">
    <item value="commeffect:eelloadercommeffect:delta"/>
    <item value="location,velocity,orientation:eelloaderlocation:delta"/>
    <item value="pathloss:eelloaderpathloss:delta"/>
    <item value="pathlossex:eelloaderpathlossex:delta"/>
    <item value="antennaprofile:eelloaderantennaprofile:delta"/>
    <item value="fadingselection:eelloaderfadingselection:delta"/>
  </paramlist>
</eventgenerator>
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


