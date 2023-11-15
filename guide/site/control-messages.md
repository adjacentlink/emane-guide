---
layout: default
title: Control Messages
nav_order: 7
permalink: /control-messages
---


# Control Messages

{: .warning }
> This chapter is incomplete.

A radio model exchanges control messages with the physical layer to
configure certain capabilities and to communication reception
information, and with an emulation boundary if the radio model is
implemented with flow control support. These messages are referred to
as *downstream* and *upstream* control messages based on their
direction of travel. *Downstream* control messages travel in the
direction of the emulation boundary down towards the physical layer.
*Upstream* control messages travel in the direction of the physical
layer up towards the emulation boundary. Control messages are only
exchanged between contiguous *NEM* layers.

The [physical layer](physical-layer#features) operates in one of two API modes: *compatibly
mode 1* (*compat1*) and *compatibility mode 2*
(*compat2*). *Compatibility mode 1* is a legacy non-MIMO API mode that
supports radio model control messaging for single antenna
functionality.  *Compatibility mode 2* is the newer MIMO API mode and
supports radio model control messaging for both single antenna and
MIMO.  Many control messages originating at or destined for the
physical layer are compatibility mode specific.

## AntennaProfileControlMessage

The `AntennaProfileControlMessage` is sent to the physical layer by a
radio model to set the antenna profile and pointing information for
the default antenna. The physical layer processes the control message
and either sends an [`AntennaProfileEvent`](events#antennaprofileevent) via the event
channel or as an [attached event](events#events) via the over-the-air channel, if the control
message was sent as part of
`processDownstreamPacket`.

`AntennaProfileControlMessage` is a physical layer *compatibility mode
1* control message.

```cpp
namespace EMANE
{
  namespace Controls
  {
    class AntennaProfileControlMessage : public ControlMessage
    {
    public:
      static
      AntennaProfileControlMessage * create(AntennaProfileId id,
                                            double dAntennaAzimuthDegrees,
                                            double dAntennaElevationDegrees);

      AntennaProfileControlMessage * clone() const override;

      ~AntennaProfileControlMessage();

      AntennaProfileId getAntennaProfileId() const;

      double getAntennaAzimuthDegrees() const;

      double getAntennaElevationDegrees() const;

      enum {IDENTIFIER = EMANE_CONTROL_MEASSGE_ANTENNA_PROFILE};

    };
  }
}
```
<p style="float:right;font-family:courier;font-size:75%"><a href="https://github.com/adjacentlink/emane/blob/master/include/emane/controls/antennaprofilecontrolmessage.h">emane/include/emane/controls/antennaprofilecontrolmessage.h</a></p><br>

## FlowControlControlMessage

The `FlowControlControlMessage` is exchanged between a radio model and
emulation boundary to manage flow control tokens in order to establish
backpressure between a radio model's over-the-air transmission rate
and the user offered load entering the emulation through the boundary.

{: .warning }
> Flow control does not work with either the Virtual
Transport or the Raw Transport. A custom boundary is required to take
advantage of radio models that support this capability.

```cpp
namespace EMANE
{
  namespace Controls
  {
    class FlowControlControlMessage : public ControlMessage
    {
    public:
      static
      FlowControlControlMessage * create(const Serialization & serialization);

      static
      FlowControlControlMessage * create(std::uint16_t u16Tokens);

      FlowControlControlMessage * clone() const override;

      ~FlowControlControlMessage();

      std::uint16_t getTokens() const;

      Serialization serialize() const override;

      enum {IDENTIFIER = EMANE_CONTROL_MEASSGE_FLOW_CONTROL};

    };
  }
}
```
<p style="float:right;font-family:courier;font-size:75%"><a href="https://github.com/adjacentlink/emane/blob/master/include/emane/controls/flowcontrolcontrolmessage.h">emane/include/emane/controls/flowcontrolcontrolmessage.h</a></p><br>

## FrequencyControlMessage

The `FrequencyControlMessage` is sent by a radio model to the physical
layer to set transmit frequency characteristics of an outbound
over-the-air message using `sendDownstreamPacket`. A radio model can
set the transmit bandwidth in Hz (0 indicates use of the physical
layer configuration parameter `bandwidth`) and one or more frequency
segments describing center frequency in Hz (0 indicates use of
physical layer configuration parameter `frequency`), duration in
microseconds, and offset from the start-of-transmission in
microseconds.

`FrequencyControlMessage` is a physical layer *compatibility mode 1*
control message.

```cpp
namespace EMANE
{
  namespace Controls
  {
    class FrequencyControlMessage : public ControlMessage
    {
    public:
      static
      FrequencyControlMessage * create(std::uint64_t u64BandwidthHz,
                                       const FrequencySegments & frequencySegments);

      FrequencyControlMessage * clone() const override;

      ~FrequencyControlMessage();

      const FrequencySegments & getFrequencySegments() const;

      std::uint64_t getBandwidthHz() const;

      enum {IDENTIFIER = EMANE_CONTROL_MEASSGE_FREQUENCY};

    };
  }
}
```
<p style="float:right;font-family:courier;font-size:75%"><a href="https://github.com/adjacentlink/emane/blob/master/include/emane/controls/frequencycontrolmessage.h">emane/include/emane/controls/frequencycontrolmessage.h</a></p><br>

## FrequencyOfInterestControlMessage

The `FrequencyOfInterestControlMessage` is sent by a radio model to
the physical layer to set the receive frequencies of interest using
`sendDownstreamControl`. A radio model can specify the receive
bandwidth in Hz (0 indicates use of the physical layer configuration
parameter `bandwidth`) and one or more receive frequencies in Hz,
where each frequency will be monitored for spectrum energy by the
physical layer [spectrum monitor](physical-layer#noise-processing).

`FrequencyOfInterestControlMessage` is a physical layer *compatibility
mode 1* control message.

```cpp
namespace EMANE
{
  namespace Controls
  {
    class FrequencyOfInterestControlMessage : public ControlMessage
    {
    public:
      static
      FrequencyOfInterestControlMessage * create(std::uint64_t u64BandwidthHz,
                                                 const FrequencySet & frequencySet);

      FrequencyOfInterestControlMessage * clone() const override;

      ~FrequencyOfInterestControlMessage();

      const FrequencySet & getFrequencySet() const;

      std::uint64_t getBandwidthHz() const;

      enum {IDENTIFIER = EMANE_CONTROL_MEASSGE_FREQUENCY_OF_INTEREST};

    };
  }
}
```
<p style="float:right;font-family:courier;font-size:75%"><a href="https://github.com/adjacentlink/emane/blob/master/include/emane/controls/frequencyofinterestcontrolmessage.h">emane/include/emane/controls/frequencyofinterestcontrolmessage.h</a></p><br>

## MIMOReceivePropertiesControlMessage

The `MIMOReceivePropertiesControlMessage` is sent by the physical
layer to a radio model to communicate receive properties associated
with a received over-the-air message using
`processUpstreamPacket`. `MIMOReceivePropertiesControlMessage`
contains the start-of-transmission in microseconds since the epoch,
propagation delay in microseconds, mapping of frequency in Hz to
Doppler shift in Hz, and antenna receive information for all received
transmission paths. There is one antenna receive information entry for
each transmit antenna to receive antenna path containing the received
frequency segments, overall message span in microseconds, and receiver
sensitivity in dBm.

`MIMOReceivePropertiesControlMessage` is a physical layer
*compatibility mode 2* control message.

```cpp
namespace EMANE
{
  namespace Controls
  {
    class MIMOReceivePropertiesControlMessage : public ControlMessage
    {
    public:
      static
      MIMOReceivePropertiesControlMessage * create(const TimePoint & txTime,
                                                   const Microseconds & propagation,
                                                   const AntennaReceiveInfos & antennaReceiveInfos,
                                                   const DopplerShifts & dopplerShifts);

      static
      MIMOReceivePropertiesControlMessage * create(const TimePoint & txTime,
                                                   const Microseconds & propagation,
                                                   AntennaReceiveInfos && antennaReceiveInfos,
                                                   DopplerShifts && dopplerShifts);
      MIMOReceivePropertiesControlMessage * clone() const override;

      ~MIMOReceivePropertiesControlMessage();

      const TimePoint & getTxTime() const;

      const Microseconds & getPropagationDelay() const;

      const AntennaReceiveInfos & getAntennaReceiveInfos() const;

      const DopplerShifts & getDopplerShifts() const;

      enum {IDENTIFIER = EMANE_CONTROL_MEASSGE_MIMO_RECEIVE_PROPERTIES};

    };
  }
}
```
<p style="float:right;font-family:courier;font-size:75%"><a href="https://github.com/adjacentlink/emane/blob/master/include/emane/controls/mimoreceivepropertiescontrolmessage.h">emane/include/emane/controls/mimoreceivepropertiescontrolmessage.h</a></p><br>

## MIMOTransmitPropertiesControlMessage

The `MIMOTransmitPropertiesControlMessage` is sent by a radio model to
the physical layer to communicate transmit properties associated with
an outbound over-the-air message using `sendDownstreamPacket`.
`MIMOTransmitPropertiesControlMessage` contains one or more transmit
antennas and a group of frequency segment lists. Each transmit antenna
may be mapped to its own unique frequency segment list or share a list
with other transmit antennas. Each transmit antenna is specified using
a unique antenna index value which is unrelated to indexes used when
adding receive antennas via
[RxAntennaAddControlMessage](#rxantennaaddcontrolmessage). Each
frequency segment contains a center frequency in Hz (0 indicates use
of physical layer configuration parameter `frequency`), duration in
microseconds, and offset from the start-of-transmission in
microseconds.

`MIMOTransmitPropertiesControlMessage` is a physical layer
*compatibility mode 2* control message.

```cpp
namespace EMANE
{
  namespace Controls
  {
    class MIMOTransmitPropertiesControlMessage : public ControlMessage
    {
    public:
      static
      MIMOTransmitPropertiesControlMessage * create(const FrequencyGroups & frequencyGroups,
                                                    const Antennas & transmitAntennas);

      static
      MIMOTransmitPropertiesControlMessage * create(FrequencyGroups && frequencyGroups,
                                                    const Antennas & transmitAntennas);

      static
      MIMOTransmitPropertiesControlMessage * create(FrequencyGroups && frequencyGroups,
                                                    Antennas && transmitAntennas);

      MIMOTransmitPropertiesControlMessage * clone() const override;

      ~MIMOTransmitPropertiesControlMessage();

      const FrequencyGroups & getFrequencyGroups() const;

      const Antennas & getTransmitAntennas() const;

      enum {IDENTIFIER = EMANE_CONTROL_MEASSGE_MIMO_TRANSMIT_PROPERTIES};

    };
  }
}
```
<p style="float:right;font-family:courier;font-size:75%"><a href="https://github.com/adjacentlink/emane/blob/master/include/emane/controls/mimotransmitpropertiescontrolmessage.h">emane/include/emane/controls/mimotransmitpropertiescontrolmessage.h</a></p><br>

## MIMOTxWhileRxInterferenceControlMessage

The `MIMOTxWhileRxInterferenceControlMessage` is sent by a radio model
to the physical layer to communicate any self transmit interference
associated with an outbound over-the-air message using
`processDownstreamPacket`. `MIMOTxWhileRxInterferenceControlMessage`
contains a frequency group index and power level in mW to apply as
received interference to each specified receive antenna.

`MIMOTxWhileRxInterferenceControlMessage` is a physical layer
*compatibility mode 2* control message.


```cpp
namespace EMANE
{
  namespace Controls
  {
    class MIMOTxWhileRxInterferenceControlMessage : public ControlMessage
    {
    public:

      using RxAntennaInterferenceMap = std::map<AntennaIndex,AntennaSelfInterferences>;

      static
      MIMOTxWhileRxInterferenceControlMessage *
      create(const FrequencyGroups & frequencyGroups,
             const RxAntennaInterferenceMap & rxAntennaSelections);

      static
      MIMOTxWhileRxInterferenceControlMessage *
      create(FrequencyGroups && frequencyGroups,
             const RxAntennaInterferenceMap & rxAntennaSelections);

      static
      MIMOTxWhileRxInterferenceControlMessage *
      create(FrequencyGroups && frequencyGroups,
             RxAntennaInterferenceMap && rxAntennaSelections);

      MIMOTxWhileRxInterferenceControlMessage * clone() const override;

      ~MIMOTxWhileRxInterferenceControlMessage();

      const FrequencyGroups & getFrequencyGroups() const;

      const RxAntennaInterferenceMap & getRxAntennaInterferenceMap() const;

      enum {IDENTIFIER = EMANE_CONTROL_MEASSGE_MIMO_TX_WHILE_RX_INTERFERENCE};

    };
  }
}
```
<p style="float:right;font-family:courier;font-size:75%"><a href="https://github.com/adjacentlink/emane/blob/master/include/emane/controls/mimotxwhilerxinterferencecontrolmessage.h">emane/include/emane/controls/mimotxwhilerxinterferencecontrolmessage.h</a></p><br>

## ReceivePropertiesControlMessage

The `ReceivePropertiesControlMessage` is sent by the physical layer to
a radio model to communicate receive properties associated with a
received over-the-air message using `processUpstreamPacket`.
`ReceivePropertiesControlMessage` contains the start-of-transmission
in microseconds since the epoch, propagation delay in microseconds,
overall message span in microseconds, and receiver sensitivity in dBm.

`ReceivePropertiesControlMessage` is a physical layer *compatibility
mode 1* control message.


```cpp
namespace EMANE
{
  namespace Controls
  {
    class ReceivePropertiesControlMessage : public ControlMessage
    {
    public:
      static
      ReceivePropertiesControlMessage * create(const TimePoint & txTime,
                                               const Microseconds & propagation,
                                               const Microseconds & span,
                                               double dReceiverSensitivitydBm);

      ReceivePropertiesControlMessage * clone() const override;

      ~ReceivePropertiesControlMessage();

      TimePoint getTxTime() const;

      Microseconds getPropagationDelay() const;

      Microseconds getSpan() const;

      double getReceiverSensitivitydBm() const;

      enum {IDENTIFIER = EMANE_CONTROL_MEASSGE_RECEIVE_PROPERTIES};

    };
  }
}
```
<p style="float:right;font-family:courier;font-size:75%"><a href="https://github.com/adjacentlink/emane/blob/master/include/emane/controls/receivepropertiescontrolmessage.h">emane/include/emane/controls/receivepropertiescontrolmessage.h</a></p><br>

## RxAntennaAddControlMessage

The `RxAntennaAddControlMessage` is sent by a radio model to the
physical layer to add a receive antenna.  `RxAntennaAddControlMessage`
contains the antenna receive frequencies of interest and an antenna
object with a unique antenna index, antenna type: ideal omni (fixed
gain) or antenna pattern defined (profile id and pointing), receive
bandwidth, and spectrum mask.

The unique antenna index is used to reference an antenna during an
[`RxAntennaUpdateControlMessage`](#rxantennaupdatecontrolmessage) or
[`RxAntennaRemoveControlMessage`](#rxantennaremovecontrolmessage). It
is also how per antenna receive power information is identified when
communicating received over-the-air transmissions to the radio model
via
[`MIMOReceivePropertiesControlMessage`](#mimoreceivepropertiescontrolmessage).

`RxAntennaAddControlMessage` is a physical layer *compatibility mode
2* control message.

```cpp
namespace EMANE
{
  namespace Controls
  {
    class RxAntennaAddControlMessage : public ControlMessage
    {
    public:
      static
      RxAntennaAddControlMessage * create(const Antenna & antenna,
                                          const FrequencySet & frequencyOfInterestSet);

      static
      RxAntennaAddControlMessage * create(const Antenna & antenna,
                                          FrequencySet && frequencyOfInterestSet);

      RxAntennaAddControlMessage * clone() const override;

      ~RxAntennaAddControlMessage();

      const Antenna & getAntenna() const;

      const FrequencySet & getFrequencyOfInterestSet() const;

      enum {IDENTIFIER = EMANE_CONTROL_MEASSAGE_RX_ANTENNA_ADD};

    };
  }
}
```
<p style="float:right;font-family:courier;font-size:75%"><a href="https://github.com/adjacentlink/emane/blob/master/include/emane/controls/rxantennaaddcontrolmessage.h">emane/include/emane/controls/rxantennaaddcontrolmessage.h</a></p><br>

## RxAntennaRemoveControlMessage

The `RxAntennaRemoveControlMessage` is sent by a radio model to the
physical layer to remove a receive antenna.  `RxAntennaRemoveControlMessage`
contains the unique antenna index identifying the receive antenna to remove.

The unique antenna index is assigned to a receive antenna during an
[`RxAntennaAddControlMessage`](#rxantennaaddcontrolmessage).

`RxAntennaRemoveControlMessage` is a physical layer *compatibility mode
2* control message.

```cpp
namespace EMANE
{
  namespace Controls
  {
    class RxAntennaRemoveControlMessage : public ControlMessage
    {
    public:
      static
      RxAntennaRemoveControlMessage * create(AntennaIndex antennaIndex);

      RxAntennaRemoveControlMessage * clone() const override;

      ~RxAntennaRemoveControlMessage();

      AntennaIndex getAntennaIndex() const;

      enum {IDENTIFIER = EMANE_CONTROL_MEASSAGE_RX_ANTENNA_REMOVE};

    };
  }
}
```
<p style="float:right;font-family:courier;font-size:75%"><a href="https://github.com/adjacentlink/emane/blob/master/include/emane/controls/rxantennaremovecontrolmessage.h">emane/include/emane/controls/rxantennaremovecontrolmessage.h</a></p><br>

## RxAntennaUpdateControlMessage

The `RxAntennUpdateControlMessage` is sent by a radio model to the
physical layer to update receive antenna properties.
`RxAntennaUpdateControlMessage` contains an antenna object with an
antenna index matching the target receive antenna to update, antenna
type: ideal omni (fixed gain) or antenna pattern defined (profile id
and pointing), receive bandwidth, and spectrum mask.

The unique antenna index is assigned to a receive antenna during an
[`RxAntennaAddControlMessage`](#rxantennaaddcontrolmessage).

`RxAntennaUpdateControlMessage` is a physical layer *compatibility mode
2* control message.

```cpp
namespace EMANE
{
  namespace Controls
  {
    class RxAntennaUpdateControlMessage : public ControlMessage
    {
    public:
      static
      RxAntennaUpdateControlMessage * create(const Antenna & antenna);

      RxAntennaUpdateControlMessage * clone() const override;

      ~RxAntennaUpdateControlMessage();

      const Antenna & getAntenna() const;

      enum {IDENTIFIER = EMANE_CONTROL_MEASSAGE_RX_ANTENNA_UPDATE};

    };
  }
}
```
<p style="float:right;font-family:courier;font-size:75%"><a href="https://github.com/adjacentlink/emane/blob/master/include/emane/controls/rxantennaupdatecontrolmessage.h">emane/include/emane/controls/rxantennaupdatecontrolmessage.h</a></p><br>

## `SpectrumFilterAddControlMessage`

```cpp
namespace EMANE
{
  namespace Controls
  {
    class SpectrumFilterAddControlMessage : public ControlMessage
    {
    public:
      static
      SpectrumFilterAddControlMessage * create(FilterIndex u16FilterIndex,
                                               AntennaIndex antennaIndex,
                                               std::uint64_t u64FrequencyHz,
                                               std::uint64_t u64BandwidthHz,
                                               std::uint64_t u64SubBandBinSizeHz = 0,
                                               FilterMatchCriterion * pFilterMatchCriterion = nullptr);

      static
      SpectrumFilterAddControlMessage * create(FilterIndex u16FilterIndex,
                                               std::uint64_t u64FrequencyHz,
                                               std::uint64_t u64BandwidthHz,
                                               std::uint64_t u64SubBandBinSizeHz = 0,
                                               FilterMatchCriterion * pFilterMatchCriterion = nullptr);

      SpectrumFilterAddControlMessage * clone() const override;

      ~SpectrumFilterAddControlMessage();

      FilterIndex getFilterIndex() const;

      AntennaIndex getAntennaIndex() const;

      std::uint64_t getBandwidthHz() const;

      std::uint64_t getFrequencyHz() const;

      const FilterMatchCriterion * getFilterMatchCriterion() const;

      std::uint64_t getSubBandBinSizeHz() const;

      enum {IDENTIFIER = EMANE_CONTROL_MEASSGE_SPECTRUM_FILTER_ADD};

    };
  }
}
```
<p style="float:right;font-family:courier;font-size:75%"><a href="https://github.com/adjacentlink/emane/blob/master/include/emane/controls/spectrumfilteraddcontrolmessage.h">emane/include/emane/controls/spectrumfilteraddcontrolmessage.h</a></p><br>

## `SpectrumFilterDataControlMessage`

```cpp
namespace EMANE
{
  namespace Controls
  {
    class SpectrumFilterDataControlMessage : public ControlMessage
    {
    public:
      static
      SpectrumFilterDataControlMessage * create(const FilterData & filterData);

      SpectrumFilterDataControlMessage * clone() const override;

      ~SpectrumFilterDataControlMessage();

      const FilterData & getFilterData() const;

      enum {IDENTIFIER = EMANE_CONTROL_MEASSGE_SPECTRUM_FILTER_DATA};

    };
  }
}
```
<p style="float:right;font-family:courier;font-size:75%"><a href="https://github.com/adjacentlink/emane/blob/master/include/emane/controls/spectrumfilterdatacontrolmessage.h">emane/include/emane/controls/spectrumfilterdatacontrolmessage.h</a></p><br>

## `SpectrumFilterRemoveControlMessage`

```cpp
namespace EMANE
{
  namespace Controls
  {
    class SpectrumFilterRemoveControlMessage : public ControlMessage
    {
    public:
      static
      SpectrumFilterRemoveControlMessage * create(FilterIndex filterIndex,
                                                  AntennaIndex antennaIndex);

      static
      SpectrumFilterRemoveControlMessage * create(FilterIndex filterIndex);

      SpectrumFilterRemoveControlMessage * clone() const override;

      ~SpectrumFilterRemoveControlMessage();

      FilterIndex getFilterIndex() const;

      AntennaIndex getAntennaIndex() const;

      enum {IDENTIFIER = EMANE_CONTROL_MEASSGE_SPECTRUM_FILTER_REMOVE};

    };
  }
}
```
<p style="float:right;font-family:courier;font-size:75%"><a href="https://github.com/adjacentlink/emane/blob/master/include/emane/controls/spectrumfilterremovecontrolmessage.h">emane/include/emane/controls/spectrumfilterremovecontrolmessage.h</a></p><br>

## `TimestampControlMessage`

```cpp
namespace EMANE
{
  namespace Controls
  {
    class TimeStampControlMessage : public ControlMessage
    {
    public:
      static
      TimeStampControlMessage * create(const TimePoint & timestamp);

      TimeStampControlMessage * clone() const override;

      ~TimeStampControlMessage();

      TimePoint getTimeStamp() const;

      enum {IDENTIFIER = EMANE_CONTROL_MEASSGE_TIME_STAMP};

    };
  }
}
```
<p style="float:right;font-family:courier;font-size:75%"><a href="https://github.com/adjacentlink/emane/blob/master/include/emane/controls/timestampcontrolmessage.h">emane/include/emane/controls/timestampcontrolmessage.h</a></p><br>

## `TransmitterControlMessage`

```cpp
namespace EMANE
{
  namespace Controls
  {
    class TransmitterControlMessage : public ControlMessage
    {
    public:
      ~TransmitterControlMessage();

      static
      TransmitterControlMessage * create(const Transmitters & transmitters);

      TransmitterControlMessage * clone() const override;

      const Transmitters & getTransmitters() const;

      enum {IDENTIFIER = EMANE_CONTROL_MEASSGE_TRANSMITTER};

    };
  }
}
```
<p style="float:right;font-family:courier;font-size:75%"><a href="https://github.com/adjacentlink/emane/blob/master/include/emane/controls/transmittercontrolmessage.h">emane/include/emane/controls/transmittercontrolmessage.h</a></p><br>

## `TxWhileRxInterferenceControlMessage`

```cpp
namespace EMANE
{
  namespace Controls
  {
    class TxWhileRxInterferenceControlMessage : public ControlMessage
    {
    public:
      static
      TxWhileRxInterferenceControlMessage * create(double dRxPowerdBm);

      TxWhileRxInterferenceControlMessage * clone() const override;

      ~TxWhileRxInterferenceControlMessage();

      double getRxPowerdBm() const;

      enum {IDENTIFIER = EMANE_CONTROL_MEASSGE_TX_WHILE_RX_INTERFERENCE};

    };
  }
}
```
<p style="float:right;font-family:courier;font-size:75%"><a href="https://github.com/adjacentlink/emane/blob/master/include/emane/controls/txwhilerxinterferencecontrolmessage.h">emane/include/emane/controls/txwhilerxinterferencecontrolmessage.h</a></p><br>
