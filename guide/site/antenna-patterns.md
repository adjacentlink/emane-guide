---
layout: default
title: Antenna Patterns
nav_order: 9
permalink: /antenna-patterns
---


# Antenna Patterns

![](images/auto-generated-incomplete-chapter.png){: width="75%"; .centered}

The antenna profile manifest is an XML file that provides a list of
all antenna profiles to be utilized within an emulation
experiment. The antenna profile manifest is specified using the
`antennaprofilemanifesturi` configuration parameter.

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE profiles SYSTEM "file:///usr/share/emane/dtd/antennaprofile.dtd">
<profiles>
  <profile id="1"
	   antennapatternuri="/var/lib/emanenode/antenna30dsector.xml"
	   blockagepatternuri="/var/lib/emanenode/blockageaft.xml">
    <placement north="0" east="0" up="0"/>
  </profile>
  <profile id="2"
	   antennapatternuri="/var/lib/emanenode/antenna30dsector.xml">
    <placement north="0" east="0" up="0"/>
  </profile>
</profiles>
```

The Antenna Profile Manifest is defined using an XML file. The
document consists of a single *\<profiles\>* element that contains one
or more <profile> elements. Each *\<profile\>* element corresponds to
a unique antenna profile where:

1. The *id* attribute is required and must be unique among all
   profiles.

2. The *antennapatternuri* attribute is required and must be specified
   as an absolute URI.

3. The *blockagepatteruri* attribute is optional and when specified
   must be an absolute URI.

4. The *\<placement\>* subelement is optional and defines the location
   of the antenna relative to the platform.

The location event provides the position of the platform and when
computing azimuth and elevation between the transmitter and receiver,
the antenna placement of the local and/or remote NEM is accounted for
within the physical layer by performing a translation and/or rotation
as required.

Where:

1. The *north* attribute defines the longitudinal offset in meters of
   the antenna location on the platform.
 
2. The *east* attribute defines the latitudinal offset in meters of
   the antenna location on the platform.
 
3. The *up* attribute defines the vertical offset in meters of the
   antenna location on the platform.

## Defining Antenna Patterns

The antenna pattern is an XML file that defines the antenna gain (i.e
radiation pattern) associated with a given antenna for all elevation
and bearing pairs. The antenna pattern is defined in the platform's
reference frame assuming to be pointing (if directional) at an
elevation and bearing of 0 degrees. The physical layer will make the
proper adjustments to account for platform orientation and antenna
pointing when computing the gain

The below sample antenna pattern XML files show an ideal omni and an
ideal 30 degree directional sector antenna. Elevation and bearing are
defined in whole degrees and as such, a single XML file can contain a
maximum of 64800 (180x360) gain values.

Ideal omni antenna XML definition:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE profiles SYSTEM "file:///usr/share/emane/dtd/antennaprofile.dtd">
<antennaprofile>
  <antennapattern>
    <elevation min="-90" max="90">
      <bearing min="0" max="359">
        <gain value='6'/>
      </bearing>
    </elevation>
  </antennapattern>
</antennaprofile>
```


30 degree directional sector antenna XML definition:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE antennaprofile SYSTEM "file:///usr/share/emane/dtd/antennaprofile.dtd">
<!-- 30degree sector antenna pattern with main beam at +6dB and
     gain decreasing by 3dB every 5 degrees in elevation or bearing.-->
<antennaprofile>
  <antennapattern>
    <elevation min='-90' max='-16'>
      <bearing min='0' max='359'>
        <gain value='-200'/>
      </bearing>
    </elevation>
    <elevation min='-15' max='-11'>
      <bearing min='0' max='5'>
        <gain value='0'/>
      </bearing>
      <bearing min='6' max='10'>
        <gain value='-3'/>
      </bearing>
      <bearing min='11' max='15'>
        <gain value='-6'/>
      </bearing>
      <bearing min='16' max='344'>
        <gain value='-200'/>
      </bearing>
      <bearing min='345' max='349'>
        <gain value='-6'/>
      </bearing>
      <bearing min='350' max='354'>
        <gain value='-3'/>
      </bearing>
      <bearing min='355' max='359'>
        <gain value='0'/>
      </bearing>
    </elevation>
    <elevation min='-10' max='-6'>
      <bearing min='0' max='5'>
        <gain value='3'/>
      </bearing>
      <bearing min='6' max='10'>
        <gain value='0'/>
      </bearing>
      <bearing min='11' max='15'>
        <gain value='-3'/>
      </bearing>
      <bearing min='16' max='344'>
        <gain value='-200'/>
      </bearing>
      <bearing min='345' max='349'>
        <gain value='-3'/>
      </bearing>
      <bearing min='350' max='354'>
        <gain value='0'/>
      </bearing>
      <bearing min='355' max='359'>
        <gain value='3'/>
      </bearing>
    </elevation>
    <elevation min='-5' max='-1'>
      <bearing min='0' max='5'>
        <gain value='6'/>
      </bearing>
      <bearing min='6' max='10'>
        <gain value='3'/>
      </bearing>
      <bearing min='11' max='15'>
        <gain value='0'/>
      </bearing>
      <bearing min='16' max='344'>
        <gain value='-200'/>
      </bearing>
      <bearing min='345' max='349'>
        <gain value='0'/>
      </bearing>
      <bearing min='350' max='354'>
        <gain value='3'/>
      </bearing>
      <bearing min='355' max='359'>
        <gain value='6'/>
      </bearing>
    </elevation>
    <elevation min='0' max='5'>
      <bearing min='0' max='5'>
        <gain value='6'/>
      </bearing>
      <bearing min='6' max='10'>
        <gain value='3'/>
      </bearing>
      <bearing min='11' max='15'>
        <gain value='0'/>
      </bearing>
      <bearing min='16' max='344'>
        <gain value='-200'/>
      </bearing>
      <bearing min='345' max='349'>
        <gain value='0'/>
      </bearing>
      <bearing min='350' max='354'>
        <gain value='3'/>
      </bearing>
      <bearing min='355' max='359'>
        <gain value='6'/>
      </bearing>
    </elevation>
    <elevation min='6' max='10'>
      <bearing min='0' max='5'>
        <gain value='3'/>
      </bearing>
      <bearing min='6' max='10'>
        <gain value='0'/>
      </bearing>
      <bearing min='11' max='15'>
        <gain value='-3'/>
      </bearing>
      <bearing min='16' max='344'>
        <gain value='-200'/>
      </bearing>
      <bearing min='345' max='349'>
        <gain value='-3'/>
      </bearing>
      <bearing min='350' max='354'>
        <gain value='0'/>
      </bearing>
      <bearing min='355' max='359'>
        <gain value='3'/>
      </bearing>
    </elevation>
    <elevation min='11' max='15'>
      <bearing min='0' max='5'>
        <gain value='0'/>
      </bearing>
      <bearing min='6' max='10'>
        <gain value='-3'/>
      </bearing>
      <bearing min='11' max='15'>
        <gain value='-6'/>
      </bearing>
      <bearing min='16' max='344'>
        <gain value='-200'/>
      </bearing>
      <bearing min='345' max='349'>
        <gain value='-6'/>
      </bearing>
      <bearing min='350' max='354'>
        <gain value='-3'/>
      </bearing>
      <bearing min='355' max='359'>
        <gain value='0'/>
      </bearing>
    </elevation>
    <elevation min='16' max='90'>
      <bearing min='0' max='359'>
        <gain value='-200'/>
      </bearing>
    </elevation>
  </antennapattern>
</antennaprofile>
```

Rendering of the above 30 degree directional sector antenna:

![](images/antennapattern.png){:width="60%"; .centered}

## Defining Blockage Patterns

The blockage pattern is an XML file that defines the blockage
associated with a given antenna mounted on a specific platform for all
elevation and bearing pairs. The blockage pattern is also defined in
the platform's reference frame and the emulator physical layer will
make the proper adjustments to account for platform orientation. The
blockage pattern is optional. When defined, it is used in conjunction
with the antenna pattern to determine the actual antenna gain.

Sample blockage pattern XML file with full blockage aft (90 degrees <=
bearing <= 270 degrees) of the platform and at elevations above and
below 10 degrees:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE antennaprofile SYSTEM "file:///usr/share/emane/dtd/antennaprofile.dtd">
<!-- blockage pattern: 1) entire aft in bearing (90 to 270) blocked
                       2) elevation below -10 blocked,
                       3) elevation from -10 to -1 is at -10dB to -1 dB
                       4) elevation from 0 to 90 no blockage-->
<antennaprofile>
  <blockagepattern>
    <elevation min='-90' max='-11'>
      <bearing min='0' max='359'>
        <gain value='-200'/>
      </bearing>
    </elevation>
    <elevation min='-10' max='-10'>
      <bearing min='0' max='89'>
        <gain value='-10'/>
      </bearing>
      <bearing min='90' max='270'>
        <gain value='-200'/>
      </bearing>
      <bearing min='271' max='359'>
        <gain value='-10'/>
      </bearing>
    </elevation>
    <elevation min='-9' max='-9'>
      <bearing min='0' max='89'>
        <gain value='-9'/>
      </bearing>
      <bearing min='90' max='270'>
        <gain value='-200'/>
      </bearing>
      <bearing min='271' max='359'>
        <gain value='-9'/>
      </bearing>
    </elevation>
    <elevation min='-8' max='-8'>
      <bearing min='0' max='89'>
        <gain value='-8'/>
      </bearing>
      <bearing min='90' max='270'>
        <gain value='-200'/>
      </bearing>
      <bearing min='271' max='359'>
        <gain value='-8'/>
      </bearing>
    </elevation>
    <elevation min='-7' max='-7'>
      <bearing min='0' max='89'>
        <gain value='-7'/>
      </bearing>
      <bearing min='90' max='270'>
        <gain value='-200'/>
      </bearing>
      <bearing min='271' max='359'>
        <gain value='-7'/>
      </bearing>
    </elevation>
    <elevation min='-6' max='-6'>
      <bearing min='0' max='89'>
        <gain value='-6'/>
      </bearing>
      <bearing min='90' max='270'>
        <gain value='-200'/>
      </bearing>
      <bearing min='271' max='359'>
        <gain value='-6'/>
      </bearing>
    </elevation>
    <elevation min='-5' max='-5'>
      <bearing min='0' max='89'>
        <gain value='-5'/>
      </bearing>
      <bearing min='90' max='270'>
        <gain value='-200'/>
      </bearing>
      <bearing min='271' max='359'>
        <gain value='-5'/>
      </bearing>
    </elevation>
    <elevation min='-4' max='-4'>
      <bearing min='0' max='89'>
        <gain value='-4'/>
      </bearing>
      <bearing min='90' max='270'>
        <gain value='-200'/>
      </bearing>
      <bearing min='271' max='359'>
        <gain value='-4'/>
      </bearing>
    </elevation>
    <elevation min='-3' max='-3'>
      <bearing min='0' max='89'>
        <gain value='-3'/>
      </bearing>
      <bearing min='90' max='270'>
        <gain value='-200'/>
      </bearing>
      <bearing min='271' max='359'>
        <gain value='-3'/>
      </bearing>
    </elevation>
    <elevation min='-2' max='-2'>
      <bearing min='0' max='89'>
        <gain value='-2'/>
      </bearing>
      <bearing min='90' max='270'>
        <gain value='-200'/>
      </bearing>
      <bearing min='271' max='359'>
        <gain value='-2'/>
      </bearing>
    </elevation>
    <elevation min='-1' max='-1'>
      <bearing min='0' max='89'>
        <gain value='-1'/>
      </bearing>
      <bearing min='90' max='270'>
        <gain value='-200'/>
      </bearing>
      <bearing min='271' max='359'>
        <gain value='-1'/>
      </bearing>
    </elevation>
    <elevation min='0' max='90'>
      <bearing min='0' max='89'>
        <gain value='0'/>
      </bearing>
      <bearing min='90' max='270'>
        <gain value='-200'/>
      </bearing>
      <bearing min='271' max='359'>
        <gain value='0'/>
      </bearing>
    </elevation>
  </blockagepattern>
</antennaprofile>
```

Rendering of the above blockage pattern:

![](images/blockagepattern.png){:width="60%"; .centered}

