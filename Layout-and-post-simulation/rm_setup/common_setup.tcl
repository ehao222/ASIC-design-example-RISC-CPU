puts "RM-Info: Running script [info script]\n"

##########################################################################################
# Variables common to all reference methodology scripts
# Script: common_setup.tcl
# Version: G-2012.06 (July 2, 2012)
# Copyright (C) 2007-2012 Synopsys, Inc. All rights reserved.
##########################################################################################

set DESIGN_NAME                   "control_pad"  ;#  The name of the top-level design

# 
set WORKSHOP_REF_PATH             "../../../ref"
set ICC_INPUTS_PATH               "../design_data"
set LIBRARY_TOP_PATH              "/home1/lib/smic"

set DESIGN_REF_PAD_PATH               "${LIBRARY_TOP_PATH}/SP013D3_V1p4"
set DESIGN_REF_SDCELL_PATH            "${LIBRARY_TOP_PATH}/aci/sc-x"
set DESIGN_REF_TECH_PATH          "${DESIGN_REF_SDCELL_PATH}/apollo/tf"

##########################################################################################
# Hierarchical Flow Design Variables
##########################################################################################

set HIERARCHICAL_DESIGNS           "" ;# List of hierarchical block design names "DesignA DesignB" ...
set HIERARCHICAL_CELLS             "" ;# List of hierarchical block cell instance names "u_DesignA u_DesignB" ...

##########################################################################################
# Library Setup Variables
##########################################################################################

# For the following variables, use a blank space to separate multiple entries.
# Example: set TARGET_LIBRARY_FILES "lib1.db lib2.db lib3.db"

set ADDITIONAL_SEARCH_PATH        [join "
	${DESIGN_REF_PAD_PATH}/syn
	${DESIGN_REF_SDCELL_PATH}/synopsys
        ${LIBRARY_TOP_PATH}/SmicSPM4PR8R_starRCXT013_mixrf_p1mtx_1233_V1/SmicSPM4PR8R_starRCXT013_mixrf_p1mtx_1233_V1.6/mapping/TM9k_MIM1f
        ${LIBRARY_TOP_PATH}/SmicSPM4PR8R_starRCXT013_mixrf_p1mtx_1233_V1/SmicSPM4PR8R_starRCXT013_mixrf_p1mtx_1233_V1.6/ITF/TM9k_MIM1f/TLUPLUS
	"]

#	setup
#		hold
#			leakage (and hold_hot)
#	setup_hot
#
set TARGET_LIBRARY_FILES     [join "
 typical_1v2c25.db
SP013D3_V1p2_typ.db	
"]

set ADDITIONAL_LINK_LIB_FILES     [join "
typical_1v2c25.db
SP013D3_V1p2_typ.db
	"]

set MIN_LIBRARY_FILES             ""  ;#  List of max min library pairs "max1 min1 max2 min2 max3 min3"...

set MW_REFERENCE_LIB_DIRS         [join "
	${DESIGN_REF_SDCELL_PATH}/apollo/smic13g
        ${DESIGN_REF_PAD_PATH}/apollo/SP013D3_V1p2_8MT
	"]

set MW_REFERENCE_CONTROL_FILE     ""  ;#  Reference Control file to define the Milkyway reference libs

set TECH_FILE                     "${DESIGN_REF_TECH_PATH}/smic13lvt_8lm.tf"  ;#  Milkyway technology file
#reminder: update tech file to saed32nm_1p9m_mw.tf
set MAP_FILE                      "${DESIGN_REF_TECH_PATH}/star_rc/saed32nm_tf_itf_tluplus.map"  ;#  Mapping file for TLUplus
set TLUPLUS_MAX_FILE              "${DESIGN_REF_TECH_PATH}/star_rc/saed32nm_1p9m_Cmax.tluplus"  ;#  Max TLUplus file
set TLUPLUS_MIN_FILE              "${DESIGN_REF_TECH_PATH}/star_rc/saed32nm_1p9m_Cmin.tluplus"  ;#  Min TLUplus file


set MW_POWER_NET                "VDD" ;#
set MW_POWER_PORT               "VDD" ;#
set MW_GROUND_NET               "VSS" ;#
set MW_GROUND_PORT              "VSS" ;#

set MIN_ROUTING_LAYER            "M1"   ;# Min routing layer
set MAX_ROUTING_LAYER            "M8"   ;# Max routing layer

set LIBRARY_DONT_USE_FILE        ""   ;# Tcl file with library modifications for dont_use

##########################################################################################
# Multivoltage Common Variables
#
# Define the following multivoltage common variables for the reference methodology scripts 
# for multivoltage flows. 
# Use as few or as many of the following definitions as needed by your design.
##########################################################################################

set PD1                          ""           ;# Name of power domain/voltage area  1
set VA1_COORDINATES              {}           ;# Coordinates for voltage area 1
set MW_POWER_NET1                "VDD1"       ;# Power net for voltage area 1

set PD2                          ""           ;# Name of power domain/voltage area  2
set VA2_COORDINATES              {}           ;# Coordinates for voltage area 2
set MW_POWER_NET2                "VDD2"       ;# Power net for voltage area 2

set PD3                          ""           ;# Name of power domain/voltage area  3
set VA3_COORDINATES              {}           ;# Coordinates for voltage area 3
set MW_POWER_NET3                "VDD3"       ;# Power net for voltage area 3
set PD4                          ""           ;# Name of power domain/voltage area  4
set VA4_COORDINATES              {}           ;# Coordinates for voltage area 4
set MW_POWER_NET4                "VDD4"       ;# Power net for voltage area 4

puts "RM-Info: Completed script [info script]\n"

