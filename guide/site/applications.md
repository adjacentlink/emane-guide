---
layout: default
title: Applications
nav_order: 5
permalink: /applications
---



# EMANE Applications

Most *EMANE* experiments will have four XML configuration files per
running `emane` application and an additional two XML configuration
files for a single `emaneeventservice` application responsible for
instantiating and configuring event generators used to direct the
experiment scenario.

## Emulator

The `emane` application processes a set of XML configuration files in
order to determine the type of radio model to load, how the radio
model and physical layer should be configured and what
general application level settings to apply.

![](images/auto-generated-configuration-parameter-hierarchy.png){:width="75%"; .centered}
<p style="text-align:center;font-size:75%">Configuration parameter value hierarchy for values
      specified in multiple files where the highest priority
      value for the same configuration parameter is used.</p><br>


1. *Emulator Platform XML*: The initial configuration file processed
   by the `emane` application. Contains all the emulator
   infrastructure configuration as well as a reference to the *NEM*
   XML along with the *NEM* structure, potentially including
   *NEM* component configuration values.
   
   *NEM* structure is defined using an `<nem>` element with a
   `definition` attribute specifying the *NEM* XML configuration file
   and an `id` attribute specifying the *NEM id*.
   
   If configuration values are specified for an NEM component:
   `<mac>`, `<phy>`, `<transport>` or `<shim>`, the XML configuration
   file for that component must also be supplied in component's
   respective `definition` attribute.

   Emulator platform XML configuration parameter values specified
   for *NEM* components will override the same configuration
   parameters, if present, in *NEM* XML or the same configuration
   parameters, if present, in the specific *NEM* component's XML.

   The below emulator platform configuration for `node-1` in the
   `rfpipe-01` example illustrates including boundary configuration
   via a sequence of `<param>` elements within the `<transport>`
   component and specifying the boundary configuration XML file as
   `emane-transvirtual.xml`. Values are provided for the `device`,
   `address`, and `mask` configuration parameters.

   ```xml
   <!DOCTYPE platform  SYSTEM 'file:///usr/share/emane/dtd/platform.dtd'>
   <platform>
     <param name="otamanagerchannelenable" value="on"/>
     <param name="otamanagerdevice" value="backchan0"/>
     <param name="otamanagergroup" value="224.1.2.8:45702"/>
     <param name="eventservicegroup" value="224.1.2.8:45703"/>
     <param name="eventservicedevice" value="backchan0"/>
     <param name="controlportendpoint" value="0.0.0.0:47000"/>

     <nem definition="emane-rfpipe-nem.xml" id="1">
       <transport definition="emane-transvirtual.xml">
         <param name="device" value="emane0"/>
         <param name="address" value="10.100.0.1"/>
         <param name="mask" value="255.255.255.0"/>
       </transport>
     </nem>
   </platform>
   ```
   <p style="float:right;font-family:courier;font-size:75%">emane-guide/examples/rfpipe-01/node-1/emane-platform.xml</p><br>


   For legacy reasons it is possible to configure an emulator instance
   to instantiate more than one *NEM*. For performance reasons, stick
   to one and only one *NEM* per emulator instance.

   ![](images/auto-generated-dont-run-multiple-nems.png){: width="75%"; .centered}


2. *NEM XML*: The configuration file specified in the emulator
   platform XML when defining the *NEM* structure. All *NEM*
   components are defined: `<mac>`, `<phy>`, `<transport>` and/or
   `<shim>`, along with their respective `definition` attribute
   specifying the appropriate component XML configuration file.

   *NEM* XML is the most appropriate place to specify physical layer
    configuration using the `<phy>` element.

   *NEM* XML configuration parameters specified within any *NEM*
   component will override the same configuration parameters, if
   present, in the specific *NEM* component's XML.

   The below *NEM* configuration for `node-1` in the `rfpipe-01`
   example illustrates how to define the *NEM* structure and configure
   the physical layer. The order of components within the `<nem>`
   element is important and maps directly to how they will be
   connected. Always order *NEM* components from *upstream* to
   *downstream*.

   ```xml
   <!DOCTYPE nem SYSTEM 'file:///usr/share/emane/dtd/nem.dtd'>
   <nem>
     <transport definition="emane-transvirtual.xml">
       <param name="arpcacheenable" value="off"/>
     </transport>
     <mac definition="emane-rfpipe-radiomodel.xml"/>
     <phy>
       <param name="bandwidth" value="20M"/>
       <param name="frequency" value="2.4G"/>
       <param name="frequencyofinterest" value="2.4G"/>
       <param name="subid" value="1"/>
       <param name="systemnoisefigure" value="4.0"/>
       <param name="txpower" value="0"/>
       <param name="fixedantennagain" value="0.0"/>
       <param name="fixedantennagainenable" value="on"/>
       <param name="noisemode" value="outofband"/>
       <param name="noisebinsize" value="20"/>
       <param name="propagationmodel" value="precomputed"/>
       <param name="compatibilitymode" value="1"/>
     </phy>
   </nem>
   ```
   <p style="float:right;font-family:courier;font-size:75%">emane-guide/examples/rfpipe-01/node-1/emane-rfpipe-nem.xml</p><br>


2. *Radio Model XML*: The configuration file specified in the *NEM* XML
   `<mac>` `definition` attribute. It contains the name of the plugin
   to instantiate within the `library` attribute of its `<mac>`
   element.

   Radio model XML configuration parameters specified within the
   `<mac>` component will be overridden by the same configuration
   parameters, if present, within *NEM* XML or the emulator platform
   XML, if present.

   The below radio model XML configuration for `node-1` in the
   `rfpipe-01` example illustrates the available configuration
   parameters for the [RF Pipe](rf-pipe-radio-model#rf-pipe-radio-model)
   radio model.

   ```xml
   <!DOCTYPE mac SYSTEM "file:///usr/share/emane/dtd/mac.dtd">
   <mac library='rfpipemaclayer'>
     <param name='enablepromiscuousmode' value='off'/>
     <param name='datarate'              value='150M'/>
     <param name='jitter'                value='0'/>
     <param name='delay'                 value='0'/>
     <param name='flowcontrolenable'     value='off'/>
     <param name='flowcontroltokens'     value='10'/>
     <param name='pcrcurveuri'
            value='emane-rfpipe-pcr.xml'/>
   </mac>
   ```
   <p style="float:right;font-family:courier;font-size:75%">emane-guide/examples/rfpipe-01/node-1/emane-rfpipe-radiomodel.xml</p><br>

3. *Boundary XML*:  The configuration file specified in the *NEM* XML
   `<transport>` `definition` attribute. It contains the name of the plugin
   to instantiate within within the `library` attribute of its `<transport>`
   element.

   Boundary XML configuration parameters specified within the
   `<transport>` component will be overridden by the same configuration
   parameters, if present, within *NEM* XML or the emulator platform
   XML, if present.

   The below boundary XML configuration for `node-1` in the
   `rfpipe-01` example provides no configuration parameter values,
   leaving all the [Virtual Transport](virtual-transport#virtual-transport)
   configuration parameters to their default values unless otherwise
   set in *NEM* XML or emulator platform XML.

   ```xml
   <!DOCTYPE transport SYSTEM "file:///usr/share/emane/dtd/transport.dtd">
   <transport library="transvirtual"/>
   ```
   <p style="float:right;font-family:courier;font-size:75%">emane-guide/examples/rfpipe-01/node-1/emane-transvirtual.xml</p><br>

4. *Bit Error Rate or Packet Completion Rate XML*: Most radio models
   employ *Bit Error Rate* (BER) or *Packet Completion Rate* (PCR)
   curves to factor *Signal to Noise and Interference Ratio* (SINR) into
   their reception success or failure logic.

   The below packet completion rate XML for `node-1` in the
   `rfpipe-01` example illustrates the format used by the [RF Pipe](rf-pipe-radio-model#rf-pipe-radio-model) model. There is no standard BER
   or PCR curve XML format.

   ```xml
   <!DOCTYPE pcr SYSTEM "file:///usr/share/emane/dtd/rfpipepcr.dtd">
   <pcr>
       <table pktsize="0">
           <row sinr="0.0" por="0"/>
           <row sinr="0.5"	por="2.5"/>
           <row sinr="1.0"	por="5"/>
           <row sinr="1.5"	por="7.5"/>
           <row sinr="2.0"	por="10"/>
           <row sinr="2.5"	por="12.5"/>
           <row sinr="3.0"	por="15"/>
           <row sinr="3.5"	por="17.5"/>
           <row sinr="4.0"	por="20"/>
           <row sinr="4.5"	por="22.5"/>
           <row sinr="5.0"	por="25"/>
           <row sinr="5.5"	por="27.5"/>
           <row sinr="6.0"	por="30"/>
           <row sinr="6.5"	por="32.5"/>
           <row sinr="7.0"	por="35"/>
           <row sinr="7.5"	por="37.5"/>
           <row sinr="8.0"	por="40"/>
           <row sinr="8.5"	por="42.5"/>
           <row sinr="9.0" por="45"/>
           <row sinr="9.5" por="47.5"/>
           <row sinr="10.0" por="50"/>
           <row sinr="10.5" por="52.5"/>

   <... snippet: only 25 lines shown...>
   ```
   <p style="float:right;font-family:courier;font-size:75%">emane-guide/examples/rfpipe-01/node-1/emane-rfpipe-pcr.xml</p><br>

### `emane` configuration

1. **`antennaprofilemanifesturi`**: URI of the antenna profile
   manifest to load. The antenna profile manifest contains a list of
   antenna profile entries. Each entry contains a unique profile
   identifier, an antenna pattern URI and an antenna blockage URI. This
   parameter is required when antennaprofileenable is on or if any other
   NEM participating in the emulation has antennaprofileenable set on,
   even in the case where antennaprofileenable is off locally.
   
   ```no-highlighting
   Default: no                    Required: no                    Modifiable: no                  
   Type:    string                Occurrs:  [1,1]               
   ```

2. **`controlportendpoint`**: IPv4 or IPv6 control port endpoint.
   
   ```no-highlighting
   Default: no                    Required: yes                   Modifiable: no                  
   Type:    inetaddr              Occurrs:  [1,1]               
   Values:  0.0.0.0:47000
   ```

3. **`eventservicedevice`**: Device to associate with the Event
   Service channel multicast endpoint.
   
   ```no-highlighting
   Default: no                    Required: no                    Modifiable: no                  
   Type:    string                Occurrs:  [1,1]               
   ```

4. **`eventservicegroup`**: IPv4 or IPv6 Event Service channel
   multicast endpoint.
   
   ```no-highlighting
   Default: no                    Required: yes                   Modifiable: no                  
   Type:    inetaddr              Occurrs:  [1,1]               
   ```

5. **`eventservicettl`**: Device to associate with the Event Service
   channel multicast endpoint.
   
   ```no-highlighting
   Default: yes                   Required: no                    Modifiable: no                  
   Type:    uint8                 Occurrs:  [1,1]                 Range:      [0,255]             
   Values:  1
   ```

6. **`otamanagerchannelenable`**: Enable OTA channel multicast
   communication.
   
   ```no-highlighting
   Default: yes                   Required: no                    Modifiable: no                  
   Type:    bool                  Occurrs:  [1,1]                 Range:      [false,true]        
   Values:  true
   ```

7. **`otamanagerdevice`**: Device to associate with the OTA channel
   multicast endpoint.
   
   ```no-highlighting
   Default: no                    Required: no                    Modifiable: no                  
   Type:    string                Occurrs:  [1,1]               
   ```

8. **`otamanagergroup`**: IPv4 or IPv6 Event Service OTA channel
   endpoint.
   
   ```no-highlighting
   Default: no                    Required: no                    Modifiable: no                  
   Type:    inetaddr              Occurrs:  [1,1]               
   ```

9. **`otamanagerloopback`**: Enable multicast loopback on the OTA
   channel multicast channel.
   
   ```no-highlighting
   Default: yes                   Required: no                    Modifiable: no                  
   Type:    bool                  Occurrs:  [1,1]                 Range:      [false,true]        
   Values:  false
   ```

10. **`otamanagermtu`**: OTA channel MTU.
    
    ```no-highlighting
    Default: yes                   Required: no                    Modifiable: no                  
    Type:    uint32                Occurrs:  [1,1]                 Range:      [0,4294967295]      
    Values:  0
    ```

11. **`otamanagerpartcheckthreshold`**: Defines the rate in seconds a
    check is performed to see if any OTA packet part reassembly efforts
    should be abandoned.
    
    ```no-highlighting
    Default: yes                   Required: no                    Modifiable: no                  
    Type:    uint16                Occurrs:  [1,1]                 Range:      [0,65535]           
    Values:  2
    ```

12. **`otamanagerparttimeoutthreshold`**: Defines the threshold in
    seconds to wait for another OTA packet part for an existing reassembly
    effort before abandoning the effort.
    
    ```no-highlighting
    Default: yes                   Required: no                    Modifiable: no                  
    Type:    uint16                Occurrs:  [1,1]                 Range:      [0,65535]           
    Values:  5
    ```

13. **`otamanagerttl`**: OTA channel multicast message TTL.
    
    ```no-highlighting
    Default: yes                   Required: no                    Modifiable: no                  
    Type:    uint8                 Occurrs:  [1,1]                 Range:      [0,255]             
    Values:  1
    ```

14. **`spectralmaskmanifesturi`**: URI of the RF transmit spectral
    mask manifest to load. The spectral mask manifest contains a list of
    spectral masks. Each spectral mask contains a unique mask identifier,
    a primary signal definition and zero or more spur definitions. This
    parameter is required when any NEM participating in the emulation is
    using spectral masks, even in the case where the local NEM is not.
    
    ```no-highlighting
    Default: no                    Required: no                    Modifiable: no                  
    Type:    string                Occurrs:  [1,1]               
    ```

15. **`stats.event.maxeventcountrows`**: Event channel max event count
    table rows.
    
    ```no-highlighting
    Default: yes                   Required: no                    Modifiable: no                  
    Type:    uint32                Occurrs:  [1,1]                 Range:      [0,4294967295]      
    Values:  0
    ```

16. **`stats.ota.maxeventcountrows`**: OTA channel max event count
    table rows.
    
    ```no-highlighting
    Default: yes                   Required: no                    Modifiable: no                  
    Type:    uint32                Occurrs:  [1,1]                 Range:      [0,4294967295]      
    Values:  0
    ```

17. **`stats.ota.maxpacketcountrows`**: OTA channel max packet count
    table rows.
    
    ```no-highlighting
    Default: yes                   Required: no                    Modifiable: no                  
    Type:    uint32                Occurrs:  [1,1]                 Range:      [0,4294967295]      
    Values:  0
    ```



### `emane` statistics

1. **`numEventChannelEventsRx`**:
   
   ```no-highlighting
   Type: uint64                Clearable: yes                 
   ```

2. **`numEventChannelEventsTx`**:
   
   ```no-highlighting
   Type: uint64                Clearable: yes                 
   ```

3. **`numOTAChannelDownstreamPackets`**:
   
   ```no-highlighting
   Type: uint64                Clearable: yes                 
   ```

4. **`numOTAChannelEventsRx`**:
   
   ```no-highlighting
   Type: uint64                Clearable: yes                 
   ```

5. **`numOTAChannelEventsTx`**:
   
   ```no-highlighting
   Type: uint64                Clearable: yes                 
   ```

6. **`numOTAChannelUpstreamPackets`**:
   
   ```no-highlighting
   Type: uint64                Clearable: yes                 
   ```

7. **`numOTAChannelUpstreamPacketsDroppedMissingPart`**:
   
   ```no-highlighting
   Type: uint64                Clearable: yes                 
   ```



### `emane` Statistic Tables

The `emane` application processes a set of XML configuration files in
order to determine the type of radio model to load, how the radio
model and physical layer should be configured and what
general application level settings to apply.

1. **`EventChannelEventCountTable`**: EventChannel Event count table.
   
   ```no-highlighting
   Clearable:  yes
   ```

2. **`OTAChannelEventCountTable`**: OTAChannel Event count table.
   
   ```no-highlighting
   Clearable:  yes
   ```

3. **`OTAChannelPacketCountTable`**: OTA packet count table.
   
   ```no-highlighting
   Clearable:  yes
   ```



## Event Service

The `emaneeventservice` application processes a configuration file in
order to determine the types of event generator plugins to
instantiate, how the plugins should be configured and what general
application level settings to apply.

1. *Event Service XML*: The initial configuration file processed by
   the `emaneeventservice` application. Contains all the event service
   infrastructure configuration as well as the event generators to
   load.

   Event generators are loaded by `emaneeventservice` based on an
   `<generator>` element's `definition` attribute which specifies the
   event generator XML. More than one `<generator>` element may be
   present, resulting in more than one generator being loaded by the
   event service.

    The below event service configuration for `host` in the
   `rfpipe-01` example illustrates configuring the event service to
   load the [EEL](eel-event-generator#eel-event-generator) event generator.

   ```xml
   <!DOCTYPE eventservice SYSTEM "file:///usr/share/emane/dtd/eventservice.dtd">
   <eventservice>
     <param name="eventservicegroup" value="224.1.2.8:45703"/>
     <param name="eventservicedevice" value="letce0"/>
     <generator definition="eelgenerator.xml"/>
   </eventservice>
   ```
   <p style="float:right;font-family:courier;font-size:75%">emane-guide/examples/rfpipe-01/host/eventservice.xml</p><br>

2. "*Event Generator XML*: The configuration file specified in the Event Service XML
   `<generator>` `definition` attribute. It contains the name of the plugin
   to instantiate within the `library` attribute of its `<generator>`
   element.

   Event generator XML configuration parameters are specified as a
   sequence of `<param>` or `<paramlist>` elements within `<generator>`.

   The below event generator XML configuration for `host` in the
   `rfpipe-01` example illustrates using some of the available
   configuration parameters for the [EEL](eel-event-generator#eel-event-generator)
   event generator.

   ```xml
   <!DOCTYPE eventgenerator SYSTEM "file:///usr/share/emane/dtd/eventgenerator.dtd">
   <eventgenerator library="eelgenerator">
       <param name="inputfile" value="scenario.eel"/>
       <paramlist name="loader">
         <item value="commeffect:eelloadercommeffect:delta"/>
         <item value="location,velocity,orientation:eelloaderlocation:delta"/>
         <item value="pathloss:eelloaderpathloss:delta"/>
         <item value="antennaprofile:eelloaderantennaprofile:delta"/>
         <item value="fadingselection:eelloaderfadingselection:delta"/>
       </paramlist>
   </eventgenerator>
   ```
   <p style="float:right;font-family:courier;font-size:75%">emane-guide/examples/rfpipe-01/host/eelgenerator.xml</p><br>


### `emaneeventservice` configuration

   1. **`eventservicedevice`**: Device to associate with the Event
   Service channel multicast endpoint.
      
      ```no-highlighting
      Default: no                    Required: no                    Modifiable: no                  
      Type:    string                Occurrs:  [1,1]               
      ```

   2. **`eventservicegroup`**: IPv4 or IPv6 Event Service channel
   multicast endpoint.
      
      ```no-highlighting
      Default: no                    Required: yes                   Modifiable: no                  
      Type:    inetaddr              Occurrs:  [1,1]               
      ```

   3. **`eventservicettl`**: Device to associate with the Event
   Service channel multicast endpoint.
      
      ```no-highlighting
      Default: yes                   Required: no                    Modifiable: no                  
      Type:    uint8                 Occurrs:  [1,1]                 Range:      [0,255]             
      Values:  1
      ```


