---
layout: default
title: Control Messages
nav_order: 7
permalink: /control-messages
---


# Control Messages

![](images/auto-generated-incomplete-chapter.png){: width="75%"; .centered}

## `AntennaProfileControlMessage`

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
<p style="float:right;font-family:courier;font-size:75%">emane/include/emane/controls/antennaprofilecontrolmessage.h</p><br>



## `FlowControlControlMessage`

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
<p style="float:right;font-family:courier;font-size:75%">emane/include/emane/controls/flowcontrolcontrolmessage.h</p><br>


## `FrequencyControlMessage`

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
<p style="float:right;font-family:courier;font-size:75%">emane/include/emane/controls/frequencycontrolmessage.h</p><br>


## `FrequencyOfInterestControlMessage`

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
<p style="float:right;font-family:courier;font-size:75%">emane/include/emane/controls/frequencyofinterestcontrolmessage.h</p><br>



## `MIMOReceivePropertiesControlMessage`

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
<p style="float:right;font-family:courier;font-size:75%">emane/include/emane/controls/mimoreceivepropertiescontrolmessage.h</p><br>


## `MIMOTransmitPropertiesControlMessage`

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
<p style="float:right;font-family:courier;font-size:75%">emane/include/emane/controls/mimotransmitpropertiescontrolmessage.h</p><br>


## `MIMOTxWhileRxInterferenceControlMessage`

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
<p style="float:right;font-family:courier;font-size:75%">emane/include/emane/controls/mimotxwhilerxinterferencecontrolmessage.h</p><br>



## `OTATransmitterControlMessage`

```cpp
namespace EMANE
{
  namespace Controls
  {
    using OTATransmitters = std::set<NEMId>;


    class OTATransmitterControlMessage : public ControlMessage
    {
    public:
      static
      OTATransmitterControlMessage * create(const Serialization & serialization);

      static
      OTATransmitterControlMessage * create(const OTATransmitters & transmitters);

      OTATransmitterControlMessage * clone() const override;

      ~OTATransmitterControlMessage();

      const OTATransmitters & getOTATransmitters() const;

      std::string serialize() const override;

      enum {IDENTIFIER = EMANE_CONTROL_MEASSGE_OTA_TRANSMITTER};

    };
  }
}
```
<p style="float:right;font-family:courier;font-size:75%">emane/include/emane/controls/otatransmittercontrolmessage.h</p><br>


## `R2RINeighborMetricControlMessage`

```cpp
namespace EMANE
{
  namespace Controls
  {

    class R2RINeighborMetricControlMessage : public ControlMessage

    {
    public:
      static
      R2RINeighborMetricControlMessage * create(const Serialization & serialization);

      static
      R2RINeighborMetricControlMessage * create(const R2RINeighborMetrics & neighborMetrics);

      R2RINeighborMetricControlMessage * clone() const override;

      ~R2RINeighborMetricControlMessage();

      const R2RINeighborMetrics & getNeighborMetrics() const;

      std::string serialize() const override;

      enum {IDENTIFIER = EMANE_CONTROL_MEASSGE_R2RI_NEIGHBOR_METRIC};

    };
  }
}
```
<p style="float:right;font-family:courier;font-size:75%">emane/include/emane/controls/r2rineighbormetriccontrolmessage.h</p><br>


## `R2RIQueueMetricControlMessage`

```cpp
namespace EMANE
{
  namespace Controls
  {
    class R2RIQueueMetricControlMessage : public ControlMessage
    {
    public:
      static
      R2RIQueueMetricControlMessage * create(const Serialization & serialization);

      static
      R2RIQueueMetricControlMessage * create(const R2RIQueueMetrics & queueMetrics);

      R2RIQueueMetricControlMessage * clone() const override;

      ~R2RIQueueMetricControlMessage();

      const R2RIQueueMetrics & getQueueMetrics() const;

      std::string serialize() const override;

      enum {IDENTIFIER = EMANE_CONTROL_MEASSGE_R2RI_QUEUE_METRIC};

    };
  }
}
```
<p style="float:right;font-family:courier;font-size:75%">emane/include/emane/controls/r2riqueuemetriccontrolmessage.h</p><br>


## `R2RISelfMetricControlMessage`

```cpp
namespace EMANE
{
  namespace Controls
  {
   class R2RISelfMetricControlMessage : public ControlMessage
    {
    public:
      static
      R2RISelfMetricControlMessage * create(const Serialization & serialization);

      static
      R2RISelfMetricControlMessage * create(std::uint64_t u64BroadcastDataRatebps,
                                            std::uint64_t u64MaxDataRatebps,
                                            const Microseconds & reportInteral);

      R2RISelfMetricControlMessage * clone() const override;

      ~R2RISelfMetricControlMessage();

      std::uint64_t getBroadcastDataRatebps() const;

      std::uint64_t getMaxDataRatebps() const;

      const Microseconds & getReportInterval() const;

      Serialization serialize() const override;

      enum {IDENTIFIER = EMANE_CONTROL_MEASSGE_R2RI_SELF_METRIC};

    };
  }
}
```
<p style="float:right;font-family:courier;font-size:75%">emane/include/emane/controls/r2riselfmetriccontrolmessage.h</p><br>


## `ReceivePropertiesControlMessage`

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
<p style="float:right;font-family:courier;font-size:75%">emane/include/emane/controls/receivepropertiescontrolmessage.h</p><br>


## `RxAntennaAddControlMessage`

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
<p style="float:right;font-family:courier;font-size:75%">emane/include/emane/controls/rxantennaaddcontrolmessage.h</p><br>


## `RxAntennaRemoveControlMessage`

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
<p style="float:right;font-family:courier;font-size:75%">emane/include/emane/controls/rxantennaremovecontrolmessage.h</p><br>


## `RxAntennaUpdateControlMessage`

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
<p style="float:right;font-family:courier;font-size:75%">emane/include/emane/controls/rxantennaupdatecontrolmessage.h</p><br>


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
<p style="float:right;font-family:courier;font-size:75%">emane/include/emane/controls/spectrumfilteraddcontrolmessage.h</p><br>


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
<p style="float:right;font-family:courier;font-size:75%">emane/include/emane/controls/spectrumfilterdatacontrolmessage.h</p><br>


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
<p style="float:right;font-family:courier;font-size:75%">emane/include/emane/controls/spectrumfilterremovecontrolmessage.h</p><br>


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
<p style="float:right;font-family:courier;font-size:75%">emane/include/emane/controls/timestampcontrolmessage.h</p><br>


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
<p style="float:right;font-family:courier;font-size:75%">emane/include/emane/controls/transmittercontrolmessage.h</p><br>


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
<p style="float:right;font-family:courier;font-size:75%">emane/include/emane/controls/txwhilerxinterferencecontrolmessage.h</p><br>

