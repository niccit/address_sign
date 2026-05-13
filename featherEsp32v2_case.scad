// SPDX-License-Identifier: MIT
$fa = 1;
$fs = 0.4;

include <YAPP_Box/YAPPgenerator_v3.scad>

// Feather ESP32v2 case with room to store a LiPoly battery

printBaseShell = true;
printLidShell = true;

// 52.3mm x 22.8mm x 7.2mm per https://www.adafruit.com/product/5400
pcbLength = 52.3;
pcbWidth = 22.8;
pcbThickness = 7.2;

paddingLeft = 9.5;
paddingRight = 9.5;
paddingFront = 9;
paddingBack = 2;

wallThickness = 1.5;
basePlaneThickness = 1.5;
lidPlaneThickness = 1.5;

baseWallHeight = 15;
lidWallHeight = 17;

ridgeHeight = 5;
ridgeSlack = 0.2;
roundRadius = 2.0;

standoffHeight = 7.0;
standoffPinDiameter = 2;
standoffHoleSlack = 0.5;
standoffDiameter = 4;

pcbStands = [
   [2, 3, yappHole, yappBaseOnly, yappSelfThreading]
   ,[2, (pcbWidth - paddingRight) + 7.5, yappHole, yappBaseOnly, yappSelfThreading]
   ,[(pcbLength - (paddingFront - 4.5)), 3, yappHole, yappBaseOnly, yappSelfThreading]
   ,[(pcbLength - (paddingFront - 4.5)), (pcbWidth - paddingRight) + 7.5, yappHole, yappBaseOnly, yappSelfThreading]
   ];

cutoutsBack = [
   [ (11 - (paddingRight/2)) , -12, 11.42, 8.26, 0, yappRectangle]          // charging port
   ,[10, 5.5, 10, 10, 3.9, yappCircle, yappCenter, yappLidOnly]                // reset button
   ];

cutoutsRight = [
   [pcbLength / 2, -7, 13, 7, 0, yappRectangle]                             // inlet for connectors for lights
   ];

snapJoins = [
    [shellLength, 5, yappLeft, yappRight, yappSymmetric, yappRectangle]
   ,[shellWidth / 2, 5, yappFront, yappCenter, yappRectangle]
   ,[shellWidth, 5, yappBack, yappSymmetric, yappRectangle]
    ];

YAPPgenerate();