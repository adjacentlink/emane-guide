---
layout: default
title: Computing Antenna Gain
nav_order: 18
permalink: /antenna-gain
---



# Computing Antenna Gain

This below step-by-step process is used to determine the antenna gain
when utilizing antenna profiles. It should be noted that antenna gains
are computed as part of the OTA receive packet processing.

The following steps 1 through 12 define the process of determining the
$$rxAntennaGain$$ when the receiving node is configured to use
antenna profiles. Steps 2 through 12 would be required to compute the
$$txAntennaGain$$ if the transmitter was also configured to use
antenna profiles.

1. Transform the positions from WGS84 (lat/long/alt) to ECEF (Earth Centered Earth Fixed)

    1. Define the WGS84 ellipsoid constants

        ```
        semi_major=6378137
        semi_minor=6356752.3142
        f=1/298.257223563
        e2 = 2*f - f^2
        ```

    2. Compute the prime vertical radius of curvature

        ```
        N = semi_major/sqrt(1-e2*sin(latitude)^2)
        ```

    3. Perform the following coordinate transformation

        ```
        X = (N + altitude) * cos(latitude) * cos(longitude)
        Y = (N + altitude) * cos(latitude) * sin(longitude)
        U = (N*(1-e2) + altitude) * sin(latitude)
       ```

    4. Perform above transformation for both the transmitter and receiver
  
        ```
        [Xt, Yt, Ut] = Transmitter Position ECEF
        [Xr, Yr, Ur] = Receiver Position ECEF
        ```

   5. Compute the ECEF vector between receiver and transmitter

        ``` 
        X = Xt-Xr
        Y = Yt-Yr
        Z = Ut-Ur
        ```

2. Transform ECEF to NEU (North, East Up) in receiving NEM's frame
 
    ```
    N1 = -X*sin(latitude)*cos(longitude) - Y*sin(latitude)*sin(longitude) + Z*cos(latitude)
    E1 = -X*sin(longitude) + Y*cos(longitude)
    U1 = X*cos(latitude)*cos(longitude) + Y*cos(latitude)*sin(longitude) + Z*sin(latitude)
    ```

3. Adjust yaw and pitch angles to account for velocity vector

    ```
    yaw = yaw + V_azimuth
    pitch = pitch + V_elevation
    ```
   
4. Perform the following transformation to account for yaw, pitch and roll
 
    1. Define the transformation matrix

        ```
        a11 = cos(pitch)cos(yaw)  
        a12 = cos(pitch)sin(yaw)  
        a13 = sin(pitch)  
        a21 = sin(pitch)cos(yaw)sin(roll) - cos(roll)sin(yaw)  
        a22 = cos(roll)cos(yaw) + sin(pitch)sin(roll)sin(yaw)  
        a23 = -cos(pitch)sin(roll)  
        a31 = -cos(yaw)sin(pitch)cos(roll) - sin(yaw)sin(roll)  
        a32 = -sin(yaw)sin(pitch)cos(roll) + sin(roll)cos(yaw)  
        a33 = cos(pitch)cos(roll)  
        ```
      
        ```
        | a11 a12 a13 |
        | a21 a22 a23 | = A
        | a31 a32 a33 |
        ```

    2. Perform the transformation

        ```
        N = N1 * a11 + E1 * a12 + U1 * a13
        E = N1 * a21 + E1 * a22 + U1 * a23
        U = N1 * a31 + E1 * a32 + U1 * a33
        ```

5. Update NEU to include receiving node's location on the platform

    ```
    N = N + north
    E = E + east
    U = U + up
    ```

    Where, *north*/*east*/*up* are obtained from the antenna profile manifest for the receiving node.

6. Rotate transmitter's antenna placement into receiver's coordinate frame using the same transformation defined in Step 4 above replacing N1, E1 and U1 with the transmitter's antenna placement values obtained from the antenna profile manifest.

    ```
    N = N + north(transformed)
    E = E + east(transformed)
    U = U + up(transformed)
    ```

7. Compute range from receiver to transmitter

    ```
    range = sqrt(N^2 + E^2 + U^2)
    ```

8. Compute bearing and elevation from receiver to transmitter

    ```
    bearing = atan(E/N)
    elevation = asin(U/range)
    ```

9. Look up the blockage value for the receiver (if provided) based on the blockage pattern associated with the receiver's antenna profile Id and the bearing and elevation values from Step 8.

10. Adjust bearing and elevation to account for receiving NEM's antenna pointing (if provided)

    ```
    bearing = bearing - AzPointing
    elevation = elevation - ElPointing
    ```

11. Look up antenna gain value for the receiver based on the antenna pattern associated with the receiver's antenna profile Id and the bearing and elevation values from Step 10.

12. Compute *rxAntennaGain*

    ```
    rxAntennGain = antennaGain + blockage
    ```
