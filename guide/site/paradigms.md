---
layout: default
title: EMANE Paradigms
nav_order: 4
permalink: /emane-paradigms
---


# EMANE Paradigms

All *EMANE* components, applications and plugins, use common
mechanisms to define, register, and access configuration parameters,
statistics, and statistic tables. This commonality creates
recognizable patterns in how you interact with a running emulation.

## Configuration

All *EMANE* components use the [`ConfigurationRegistrar`](https://github.com/adjacentlink/emane/blob/master/include/emane/configurationregistrar.h#L56) to register configuration parameters.

```cpp
namespace EMANE
{
  class ConfigurationRegistrar
  {
  public:
    virtual ~ConfigurationRegistrar();

    template<typename T>
    void registerNumeric(const std::string & sName,
                         const ConfigurationProperties & properties = ConfigurationProperties::NONE,
                         const std::initializer_list<T> & values = {},
                         const std::string & sUsage = "",
                         T minValue = std::numeric_limits<T>::lowest(),
                         T maxValue = std::numeric_limits<T>::max(),
                         std::size_t minOccurs = 1,
                         std::size_t maxOccurs = 1,
                         const std::string & sRegexPattern = {});
    template<typename T>
    void registerNonNumeric(const std::string & sName,
                            const ConfigurationProperties & properties = ConfigurationProperties::NONE,
                            const std::initializer_list<T> & values = {},
                            const std::string & sUsage = "",
                            std::size_t minOccurs = 1,
                            std::size_t maxOccurs = 1,
                            const std::string & sRegexPattern = {});

    virtual void registerValidator(ConfigurationValidator validator) = 0;

  };
}
```
<p style="float:right;font-family:courier;font-size:75%">emane/include/emane/configurationregistrar.h</p><br>

There are two registration template methods which allow components to
register numeric and non-numeric configuration items: [`registerNumeric`](https://github.com/adjacentlink/emane/blob/master/include/emane/configurationregistrar.h#L81) and [`registerNonNumeric`](https://github.com/adjacentlink/emane/blob/master/include/emane/configurationregistrar.h#L105) respectively.

Numeric configuration item types may be any of the following:

* `std::int64_t`
* `std::int32_t`
* `std::int16_t`
* `std::int8_t`
* `std::uint64_t`
* `std::uint32_t`
* `std::uint16_t`
* `std::uint8_t`
* `bool`
* `float`
* `double`

Non-numeric configuration item types are limited to:

* `std::string`
* [`INETAddr`](https://github.com/adjacentlink/emane/blob/master/include/emane/inetaddr.h#L44)

Both calls have parameters to specify a description string, zero or
more default values, minimum and maximum occurrence counts
(multiplicity), item properties such as running-state modifiable and a
regex for further validation. Additionally, [`registerNumeric`](https://github.com/adjacentlink/emane/blob/master/include/emane/configurationregistrar.h#L81) adds support for
specifying a value range.

Configuration properties may be *or*-combined  (`||`):

* `NONE`: No properties.
* `REQUIRED`: The parameter is required. No effect when combined with `DEFAULT`.
* `DEFAULT`: One or more default values are specified.
* `MODIFIABLE`: Values may be modified while the emulator is in the
  running state.

The emulator enforces data type, value range, occurrence count, regex
match and running-state modification permission without any component
interaction, so radio models do not require code to guard against
these conditions.

Below is a snippet of the configuration parameter registration within the [RF Pipe](rf-pipe-radio-model#rf-pipe-radio-model) radio model:

```cpp
  auto & configRegistrar = registrar.configurationRegistrar();

  configRegistrar.registerNumeric<bool>("enablepromiscuousmode",
                                        ConfigurationProperties::DEFAULT |
                                        ConfigurationProperties::MODIFIABLE,
                                        {false},
                                        "Defines whether promiscuous mode is enabled or not."
                                        " If promiscuous mode is enabled, all received packets"
                                        " (intended for the given node or not) that pass the"
                                        " probability of reception check are sent upstream to"
                                        " the transport.");

  configRegistrar.registerNumeric<std::uint64_t>("datarate",
                                                 ConfigurationProperties::DEFAULT |
                                                 ConfigurationProperties::MODIFIABLE,
                                                 {1000000},
                                                 "Defines the transmit datarate in bps."
                                                 " The datarate is used by the transmitter"
                                                 " to compute the transmit delay (packet size/datarate)"
                                                 " between successive transmissions.",
                                                 1);

```
<p style="float:right;font-family:courier;font-size:75%">emane/src/models/mac/rfpipe/maclayer.cc lines: <a href="https://github.com/adjacentlink/emane/blob/master/src/models/mac/rfpipe/maclayer.cc#L116-L137">116-137</a></p><br>

Two running-state modifiable configuration variables are declared,
each with a default value and description. Additionally, the
`datarate` configuration parameter has a minimum value specified.

The *EMANE* configuration registration paradigm is used by all *EMANE*
models, components, and applications, and its standardization makes it
possible to have a standardized XML configuration file format processed
directly by the emulator.

Below is `node-1`'s radio model XML from the `rfpipe-01` example
illustrating how `enablepromiscuousmode` and `datarate` configuration
parameters are set:

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

All configuration parameters in *EMANE* XML use a `<param>` element
with a `name` and `value` attribute, or for a configuration parameter
with multiple values --- `<paramlist>` with `name` attribute and a
sequence of `<item>` elements each with a `value` attribute. Where,
`name` matches the name given during configuration registration and
`value` is the configured value.

The following [Bent Pipe Model](bent-pipe-radio-model#bent-pipe-radio-model)
XML snippet shows how `<paramlist>` is used for configuration
parameters with more than one value:

```xml
  <!-- syntax: '<transponder id>:<rx freqeuncy Hz>' -->
  <paramlist name='transponder.receive.frequency'>
    <item value='0:29.910G'/>
    <item value='1:29.745G'/>
    <item value='2:29.580G'/>
  </paramlist>

```
<p style="float:right;font-family:courier;font-size:75%">emane-guide/examples/bentpipe-02/node-2/emane-bentpipe-radiomodel.xml lines: 7-13</p><br>

### Querying/Modifying Configuration

Running `emane-guide/examples/rfpipe-01`, the `emanesh` application is
used to connect to a running `emane` instance and query and/or clear
statistics.

![](images/auto-generated-run-rfpipe-01.png){:width="75%"; .centered}

To establish an shell connection and query one ore more configuration
parameters of a running radio model:

```text
$ emanesh node-1
[emanesh (node-1:47000)] ## get config nems mac
nem 1   mac  datarate = 150000000
nem 1   mac  delay = 0.0
nem 1   mac  enablepromiscuousmode = False
nem 1   mac  flowcontrolenable = False
nem 1   mac  flowcontroltokens = 10
nem 1   mac  jitter = 0.0
nem 1   mac  neighbormetricdeletetime = 60.0
nem 1   mac  pcrcurveuri = emane-rfpipe-pcr.xml
nem 1   mac  radiometricenable = False
nem 1   mac  radiometricreportinterval = 1.0
nem 1   mac  rfsignaltable.averageallantennas = False
nem 1   mac  rfsignaltable.averageallfrequencies = False
```

You can also use `emanesh` to issue any command as one-shot from the
command line:

```text
$ emanesh node-1 get config nems mac jitter datarate
nem 1   mac  datarate = 150000000
nem 1   mac  jitter = 0.0
```

To change one or more configuration parameters of a running radio
model:

```text
[emanesh (node-1:47000)] ## set config nems mac delay=1.5
nem 1   mac  configuration updated

[emanesh (node-1:47000)] ## get config nems mac delay
nem 1   mac  delay = 1.5
```

To query the configuration parameter descriptions of a running radio
model:

```text
[emanesh (node-1:47000)] ## info config rfpipemaclayer delay

    Configuration parameter information for rfpipemaclayer delay

    Defines an additional fixed delay in seconds applied to each
    transmitted packet.

     default   : True
     required  : False
     modifiable: True
     type      : float
     range     : [0.000000,340282346638528859811704183484516925440.000000]
     regex     :
     occurs    : [1,1]
     default   : 0.000000
```

## Statistics

All *EMANE* components use the [`StatisticRegistrar`](https://github.com/adjacentlink/emane/blob/master/include/emane/statisticregistrar.h#L59) to register statistics.

```cpp
namespace EMANE
{
  class StatisticRegistrar
  {
  public:
    virtual ~StatisticRegistrar(){}

    template<typename T>
    StatisticNumeric<T> * registerNumeric(const std::string & sName,
                                          const StatisticProperties & properties = StatisticProperties::NONE,
                                          const std::string & sDescription = "");

    template<typename T>
    StatisticNonNumeric<T> * registerNonNumeric(const std::string & sName,
                                                const StatisticProperties & properties = StatisticProperties::NONE,
                                                const std::string & sDescription = "");

    template<typename Key,
             typename Compare = std::less<EMANE::Any>,
             std::size_t scolumn = 0>
    StatisticTable<Key,Compare,scolumn> *
    registerTable(const std::string & sName,
                  const StatisticTableLabels & labels,
                  const StatisticProperties & properties = StatisticProperties::NONE,
                  const std::string & sDescription = "");

    template<typename Key,
             typename Function,
             typename Compare = std::less<EMANE::Any>,
             std::size_t scolumn = 0>
    StatisticTable<Key,Compare,scolumn> *
    registerTable(const std::string & sName,
                  const StatisticTableLabels & labels,
                  Function clearFunc,
                  const std::string & sDescription = "");

  };
}
```
<p style="float:right;font-family:courier;font-size:75%">emane/include/emane/statisticregistrar.h</p><br>

There are two registration template methods which allow components to
register numeric and non-numeric statistics: [`registerNumeric`](https://github.com/adjacentlink/emane/blob/master/include/emane/statisticregistrar.h#L82) and [`registerNonNumeric`](https://github.com/adjacentlink/emane/blob/master/include/emane/statisticregistrar.h#L102) respectively.

Numeric statistic types may be any of the following:

* `std :int64_t`
* `std::int32_t`
* `std::int16_t`
* `std::int8_t`
* `std::uint64_t`
* `std::uint32_t`
* `std::uint16_t`
* `std::uint8_t`
* `bool`
* `float`
* `double`

Non-numeric statistic types are limited to:

* `std::string`
* [`INETAddr`](https://github.com/adjacentlink/emane/blob/master/include/emane/inetaddr.h#L44)

Both calls have parameters to specify the statistic name, properties,
and an optional description string.

Statistic properties are one of the following:

* `NONE`: No properties.
* `CLEARABLE`: The value is clearable while the emulator is in the
  running state.

Below is a snippet of statistic registration from the [RF Pipe](rf-pipe-radio-model#rf-pipe-radio-model) radio model:

```cpp
  pNumHighWaterMark_ =
     statisticRegistrar.registerNumeric<std::uint32_t>("numHighWaterMark",
                                                       StatisticProperties::CLEARABLE,
                                                       "Downstream queue high water mark in packets.");
```
<p style="float:right;font-family:courier;font-size:75%">emane/src/models/mac/rfpipe/downstreamqueue.cc lines: <a href="https://github.com/adjacentlink/emane/blob/master/src/models/mac/rfpipe/downstreamqueue.cc#L55-L58">55-58</a></p><br>

An unsigned 32-bit integer statistic variable is declared with the
`CLEARABLE` propriety.

### Querying/Clearing Statistics

Running `emane-guide/examples/rfpipe-01`, we can use the `emanesh`
application to connect to a running `emane` instance and query and/or
clear statistics.

![](images/auto-generated-run-rfpipe-01.png){:width="75%"; .centered}

To establish an shell connection to query the statistics of a running
radio model:

```text
$ emanesh node-1
[emanesh (node-1:47000)] ## get stat nems mac
nem 1   mac  avgDownstreamProcessingDelay0 = 9148752.0
nem 1   mac  avgDownstreamQueueDelay = 9148752.0                                                                                                                
nem 1   mac  avgProcessAPIQueueDepth = 1.2433922547802265
nem 1   mac  avgProcessAPIQueueWait = 50.888313472666326
nem 1   mac  avgTimedEventLatency = 142.49969021065615
nem 1   mac  avgTimedEventLatencyRatio = 0.2250635999012512
nem 1   mac  avgUpstreamProcessingDelay0 = 19.191591262817383                                                                                                   
nem 1   mac  numAPIQueued = 11354

...

nem 1   mac  processedConfiguration = 1
nem 1   mac  processedDownstreamControl = 0
nem 1   mac  processedDownstreamPackets = 24499
nem 1   mac  processedEvents = 0
nem 1   mac  processedTimedEvents = 3228 
nem 1   mac  processedUpstreamControl = 0
nem 1   mac  processedUpstreamPackets = 85813
```

To clear those statistics that were registered as `CLEARABLE`:

```text
[emanesh (node-1:47000)] ## clear stat nems mac
nem 1   mac  statistics cleared
```

To query the statistic descriptions of a running radio model:

```text
emanesh (node-1:47000)] ## info stat rfpipemaclayer numHighWaterMark

    Statistic element information for rfpipemaclayer numHighWaterMark


     clearable : True
     type      : uint32
```

## Statistic Tables

All *EMANE* components use the [`StatisticRegistrar`](https://github.com/adjacentlink/emane/blob/master/include/emane/statisticregistrar.h#L59) to register statistic tables.

```cpp
namespace EMANE
{
  class StatisticRegistrar
  {
  public:
    virtual ~StatisticRegistrar(){}

    template<typename T>
    StatisticNumeric<T> * registerNumeric(const std::string & sName,
                                          const StatisticProperties & properties = StatisticProperties::NONE,
                                          const std::string & sDescription = "");

    template<typename T>
    StatisticNonNumeric<T> * registerNonNumeric(const std::string & sName,
                                                const StatisticProperties & properties = StatisticProperties::NONE,
                                                const std::string & sDescription = "");

    template<typename Key,
             typename Compare = std::less<EMANE::Any>,
             std::size_t scolumn = 0>
    StatisticTable<Key,Compare,scolumn> *
    registerTable(const std::string & sName,
                  const StatisticTableLabels & labels,
                  const StatisticProperties & properties = StatisticProperties::NONE,
                  const std::string & sDescription = "");

    template<typename Key,
             typename Function,
             typename Compare = std::less<EMANE::Any>,
             std::size_t scolumn = 0>
    StatisticTable<Key,Compare,scolumn> *
    registerTable(const std::string & sName,
                  const StatisticTableLabels & labels,
                  Function clearFunc,
                  const std::string & sDescription = "");

  };
}
```
<p style="float:right;font-family:courier;font-size:75%">emane/include/emane/statisticregistrar.h</p><br>

There are two template methods for registering a statistic table, both
named `registerTable`. Both methods have parameters for specifying the
table name, column labels, and an optional description. One version
includes table properties and the other is specifically for
`CLEARABLE` tables with a callback to invoke when a table is cleared.

All rows in a statistic table must have the same number of columns,
where each row value may be of any type allowed for an individual
statistic.

Below is a snippet of statistic table registration from the [Physical Layer](physical-layer#physical-layer):

```cpp
  pPathlossTable_ =
    statisticRegistrar.registerTable<NEMId>("PathlossEventInfoTable",
                                            {"NEM","Forward Pathloss","Reverse Pathloss"},
                                            StatisticProperties::NONE,
                                            "Shows the precomputed pathloss information received");

  pAntennaProfileTable_ =
    statisticRegistrar.registerTable<NEMId>("AntennaProfileEventInfoTable",
                                            {"NEM","Antenna Profile","Antenna Azimuth","Antenna Elevation"},
                                            StatisticProperties::NONE,
                                            "Shows the antenna profile information received");

  pFadingSelectionTable_ =
    statisticRegistrar.registerTable<NEMId>("FadingSelectionInfoTable",
                                            {"NEM","Model"},
                                            StatisticProperties::NONE,
                                            "Shows the selected fading model information received");

```
<p style="float:right;font-family:courier;font-size:75%">emane/src/libemane/eventtablepublisher.cc lines: <a href="https://github.com/adjacentlink/emane/blob/master/src/libemane/eventtablepublisher.cc#L47-L64">47-64</a></p><br>

These registered statistic tables provide the current event
information used by the model. Each table uses an *NEM id* key and is
not clearable.

### Querying/Clearing Statistic Tables

Running `emane-guide/examples/rfpipe-01`, the `emanesh` application is
used to connect to a running `emane` instance and query and/or clear
statistic tables.

![](images/auto-generated-run-rfpipe-01.png){:width="75%"; .centered}

To establish an shell connection to query statistic tables of a
running radio model:

```text
$ emanesh node-1
[emanesh (node-1:47000)] ## get table nems phy LocationEventInfoTable PathlossEventInfoTable AntennaProfileEventInfoTable
nem 1   phy AntennaProfileEventInfoTable
| NEM | Antenna Profile | Antenna Azimuth | Antenna Elevation |

nem 1   phy LocationEventInfoTable
| NEM | Latitude | Longitude | Altitude | Pitch | Roll | Yaw | Azimuth | Elevation | Magnitude |

nem 1   phy PathlossEventInfoTable
| NEM | Forward Pathloss | Reverse Pathloss |
| 2   | 70.0             | 70.0             |
| 3   | 70.0             | 70.0             |
| 4   | 70.0             | 70.0             |
| 5   | 70.0             | 70.0             |
```

To clear those statistic tables that were registered as `CLEARABLE`:

```text
[emanesh (node-1:47000)] ## clear table nems phy
nem 1   phy  tables cleared
```

To query the statistic table descriptions of a running radio
model:

```text
[emanesh (node-1:47000)] ## info table emanephy PathlossEventInfoTable

    Table information for emanephy PathlossEventInfoTable

    Shows the precomputed pathloss information received

     clearable : False
```
