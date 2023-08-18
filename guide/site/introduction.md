---
layout: default
title: Introduction
nav_order: 3
permalink: /introduction
---


# Introduction

The *Extendable Mobile Ad-hoc Network Emulator* (*EMANE*) is an
open source distributed emulation framework which provides wireless
network experimenters with a highly flexible modular environment for
use during the design, development and testing of simple and complex
network architectures. *EMANE* uses a physical layer model to account
for signal propagation, antenna profile effects and interference
sources to create a realistic emulated electromagnetic operating
environment.

*EMANE* is a Linux user space application that uses a radio model
plugin along with its physical layer model to emulate the lowest layer
of a waveform. A running *EMANE* instance, specifically its radio
model plugin, can be combined with existing Software Defined Radio
(SDR) implementation components to support high fidelity shared code
experimentation.

At its core, *EMANE* consists of three major subsystems: [*emulation
processing*](#emulation-processing) concerning all necessary
functionality to represent the electromagnetic properties of the radio
waveform; [*boundary processing*](#boundary-processing) providing the
connections (mechanisms/APIs) used by applications and/or protocols to
access the emulated waveform; and [*event
processing*](#event-processing) controlling emulation environmental
characteristics such as pathloss, location, orientation and velocity.

![](images/emane.png){:width="75%"; .centered}
<p style="text-align:center;font-size:75%">Example EMANE deployments.</p><br>

## Emulation Processing

*EMANE* emulation processing consists of pairing a *physical layer
model* instantiation with a *radio model* instantiation. The emulator
application, `emane`, processes a configuration file in order to
determine the type of radio model to load, how the radio model and
physical layer instance should be configured and what general
application level settings to apply.

When the emulator instantiates a radio model plugin, it along with a
dedicated instance of the emulator's physical layer, are placed in an
internal structure called a *Network Emulation Module* (*NEM*). Each
*NEM* is configured with a unique unsigned 16-bit identifier (*NEM
id*) that operates as the emulation address of the experiment node's
`emane` instance. Valid *NEM id* range is $$[1,65534]$$, with 0
being invalid and 65535 (all-1s) indicating the *NEM* broadcast
destination.

Physical layer instances are interconnected using an *Over-The-Air*
(OTA) multicast channel. All OTA messages are processed by every
emulator instance using the same OTA multicast channel. This is how
the emulator physical layer accounts for signal propagation, antenna
effects and interference sources across heterogeneous radio models.

Each radio model operates differently, but in general, a model
receives a message from a process outside the emulation to transmit
over the air and sends the message to it's physical layer instance for
transmission over the OTA multicast channel (possibly after the radio
model performs a channel access function). All emulator instances
using the same OTA multicast channel receive the message and perform a
receive power test. Those physical layer instances that determine the
message receive power was greater than the receiver sensitivity either
categorize the message as noise or as a valid *in-band* waveform
signal. An *in-band* signal in the context of *EMANE* refers to a
signal that can be properly decoded by the receiver based on waveform
transmission properties such as modulation, frequency, and
transec. Valid waveform signals are sent to the receiving radio model
for additional processing. Most radio models then employ *Bit Error
Rate* (BER) curves based on the message *Signal to Noise and
Interference Ratio* (SINR) as part of the decision as to whether or
not to deliver the message to the corresponding process outside the
emulation.

The term *process outside the emulation* is used to refer to a process
not running as a plugin within the emulator but that is somehow
connected to (using) the emulator. A process outside the emulation
would typically not know it was connected to or routing through an
emulation, and can be the same application that is run with physical
radio hardware.

*EMANE* uses the term *downstream packet message* for messages headed
towards the OTA multicast channel for over-the-air transmission and
the term *upstream packet message* for over-the-air messages received
by the OTA multicast channel and headed for further
processing. *Downstream packet messages* may originate from a *process
outside the emulation* or from a radio model and may be destined, as
an *upstream packet message*, for a *process outside the emulation*
associated with the receiving *NEM* or the receiving radio model.

A radio model can send a control message to its corresponding physical
layer to manage and control various aspects of the radio
behavior. These messages are referred to as *downstream control
messages*. A physical layer instance can also send a message to its
corresponding radio model referred to as an *upstream control
message*.

The open source *EMANE* distribution contains four radio models:
[RF Pipe Model](rf-pipe-radio-model#rf-pipe-radio-model),
[IEEE 802.11abg Model](ieee80211abg-radio-model#ieee-802.11abg-radio-model),
[TDMA Model](tdma-radio-model#tdma-radio-model),
and [Bent Pipe Model](bent-pipe-radio-model#bent-pipe-radio-model);
and one utility model: [Comm Effect Model](comm-effect-utility-model#comm-effect-utility-model).

## Boundary Processing

The emulation boundary is the emulation component responsible for
delivering messages between an emulator instance and one or more
processes outside the emulation. Historically this component has been
referred to as a *transport*. Boundaries provide the entry and exit
point for messages sent between the emulator and processes outside the
emulation.

Think of the emulation boundary as the first component encountered by
a messages on its *downstream* travel that knows it is entering an
emulation or in the upstream direction, the last component that knows
a message traversed an emulation.

Boundary plugins can either be instantiated internally as part of the
emulator process or externally as part of some other application. When
instantiated internally, boundary plugins are configured in the same
manner as radio model and physical layer instances, and are contained
in the same *NEM* structure as their respective radio model and physical
layer instance.

The *EMANE* distribution contains two boundaries: [Raw Transport](raw-transport#raw-transport) and
[Virtual Transport](virtual-transport#virtual-transport).

*EMANE* supports IP and non-IP wireless system emulation. The
mechanisms and messages *processes outside the emulation* use and
those boundaries are required to support in order to interact with
*processes outside the emulation* vary. However, once a boundary has a
message to deliver, they all generally do the same thing. In the
downstream direction, a boundary must determine the *NEM id* for the
message next hop (which may be the *NEM* broadcast address) and send
the message to its respective *NEM* along with the source and
destination *NEM ids*. In the upstream direction, a boundary must
determine the process outside the emulation to receive the message and
send it.

As messages from processes outside the emulation enter through a
boundary they lose their form and are sent through the emulator as an
opaque payload of a specified size. The boundary is the only component
in the emulator that can read and write outside-the-emulation-message
specifics.

For example, the [Virtual Transport](virtual-transport#virtual-transport), uses the
[TUN/TAP](https://www.kernel.org/doc/Documentation/networking/tuntap.txt)
interface to create a *virtual interface* (*vif*) as the boundary
entry/exit point. In the downstream direction, ethernet frames routed
to the *vif* by the kernel are packaged into messages and sent to the
appropriate *NEM* for processing. In the upstream direction, *NEM*
messages are unpackaged and written to the TUN/TAP interface as
ethernet frames.

Boundaries are not limited to plugins loaded internally by the
emulator. When connecting *Software Defined Radio* (SDR) waveforms to
*EMANE*, custom boundaries are developed and embedded within the SDR,
typically at the *Modem Hardware Abstraction Layer* (MHAL) or
equivalent. *EMANE* provides application level APIs to simplify
developing custom boundaries.

It is also possible to encounter a radio model that does not use a
boundary in the traditional sense. *EMANE* plugins have access to a
*File Descriptor Service* which allows a plugin to connect a file
descriptor, such as a socket handle, to the plugin processing loop --
often referred to as the *functor queue*. This technique is especially
useful in shared code emulation when the SDR uses a message passing
architecture to communicate between component layers.

## Event Processing

In order to be interesting, a running emulation requires a scenario. A
scenario is a set of *events* that are sent to one or more *NEMs* to
change environmental characteristics. Events are delivered opaquely to
registered radio model and physical layer instances. Individual radio
models may use their own specialized events, but whenever possible,
developers are advised to reuse *EMANE* standard events over creating
new events that provide the same capability.

The *EMANE* distribution contains four events used by the physical layer: [Antenna Profile](events#antennaprofileevent),
[Location](events#locationevent),
[Pathloss](events#pathlossevent),
 and
[Fading Selection](events#fadingselectionevent).

Additionally, the [Comm Effect](events#comm-effect-event) and
[TDMA Schedule](events#tdma-schedule-event)
events are model specific events used to communicate link characteristics and TDMA
schedules, for the Comm Effect utility model and TDMA radio model respectively.

Events are created by event generator plugins using the *Event
Service*. The *Event Service* application, `emaneeventservice`,
processes a configuration file in order to determine the types of
event generator plugins to instantiate, how the plugins should be
configured and what general application level settings to apply.

The *EMANE* distribution contains one event generator that will create
all the standard events: [EEL Event Generator](eel-event-generator#eel-event-generator). Additionally, you can use the
Python `emane.events` module to create custom event generating
applications.
