---
layout: default
title: Events
nav_order: 8
permalink: /events
---


# Events

{: .warning }
> This chapter is incomplete.

A scenario is a set of *events* that are sent to one or more *NEMs* in
order to change environmental characteristics such as locations,
pathloss and antenna pointing. Events are delivered opaquely to
registered radio model and physical layer instances so individual
radio models may use their own specialized events.

## `AntennaProfileEvent`

An `AntennaProfileEvent` is used to set the antenna profile and
pointing information (azimuth and elevation) for an *NEM's* default
antenna (index 0).

```protobuf
package EMANEMessage;
option optimize_for = SPEED;
message AntennaProfileEvent
{
  message Profile
  {
    required uint32 nemId = 1;
    required uint32 profileId = 2;
    required double antennaAzimuthDegrees = 3;
    required double antennaElevationDegrees = 4;
  }
  repeated Profile profiles = 1;
}
```
<p style="float:right;font-family:courier;font-size:75%">emane/src/libemane/antennaprofileevent.proto</p><br>

## `LocationEvent`

A `LocationEvent` is used to set the location and optionally the
velocity and/or orientation of an *NEM*.

```protobuf
package EMANEMessage;
option optimize_for = SPEED;
message LocationEvent
{
  message Location
  {
    message Position
    {
      required double latitudeDegrees = 1;
      required double longitudeDegrees = 2;
      required double altitudeMeters = 3;
    }
    message Velocity
    {
      required double azimuthDegrees = 1;
      required double elevationDegrees = 2;
      required double magnitudeMetersPerSecond = 3;
    }
    message Orientation
    {
      required double rollDegrees = 1;
      required double pitchDegrees = 2;
      required double yawDegrees = 3;
    }
    required uint32 nemId = 1;
    required Position position = 2;
    optional Velocity velocity = 3;
    optional Orientation orientation = 4;
  }
  repeated Location locations = 1;
}
```
<p style="float:right;font-family:courier;font-size:75%">emane/src/libemane/locationevent.proto</p><br>

## `PathlossEvent`

A `PathlossEvent` is used to set the pathloss used at a receiving
*NEM* for over-the-air transmissions from one or more specified source
*NEMs*. 

```protobuf
package EMANEMessage;
option optimize_for = SPEED;
message PathlossEvent
{
  message Pathloss
  {
    required uint32 nemId = 1;
    required float forwardPathlossdB = 2;
    required float reversePathlossdB = 3;
  }
  repeated Pathloss pathlosses = 1;
}
```
<p style="float:right;font-family:courier;font-size:75%">emane/src/libemane/pathlossevent.proto</p><br>
 
## `FadingSelectionEvent`

A `FadingSelectionEvent` is used to set the fading model in use at a
receiving *NEM* for over-the-air transmission from one or more
specified source *NEMs*. Required when the physical layer
`fading.model` configuration parameter is set to `event`.

```protobuf
package EMANEMessage;
option optimize_for = SPEED;
message FadingSelectionEvent
{
  enum Model
  {
    TYPE_NONE = 1;
    TYPE_NAKAGAMI = 2;
    TYPE_LOGNORMAL = 3;
  }
  message Entry
  {
    required uint32 nemId = 1;
    required Model model = 2;
  }
  repeated Entry entries = 1;
}
```
<p style="float:right;font-family:courier;font-size:75%">emane/src/libemane/fadingselectionevent.proto</p><br>
