# Seed Analizer

## Introduction

This software is intended to analize the values of a .csv file corresponding to the reads of a microcontroller ADC connected to an optic sensor.

## Objectives

Generate an easy and fast way to analize a lot of readings in the optic sensor.

  * Graphics the reading values in the time.

  * Generate an histogram of the min pulse value.

  * Beatifull probabilistic analysis.

## How to use

Limitations:

  * The name of the .csv file needs to be 'data.csv' and it must to have a heading and the data needs to be in the form of: #,timeStamp,0,1,2,...,100
  
  * Max 100 values are allowed.
  
  * The min value needs to be in the value[50].
  
  * Values grater than 4096 and lower than 1 are deprecated.