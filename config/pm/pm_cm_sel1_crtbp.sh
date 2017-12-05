# Configuration file for sempm - See config/constants.h for details on the constants.
#
# This file calls sempm in order to compute the high-order parameterization of the center
# manifold about the libration point $LIBPOINT at order $OFTS_ORDER.
# Such computations requires the corresponding subfolders of data/VF and data/COC to have 
# been previously filled via qbcp.sh and nfo2.sh
#
# BLB 2017

#-----------------------------------------------------------------------------------------
# TYPE OF COMPUTATION (COMPTYPE)
#-----------------------------------------------------------------------------------------
COMPTYPE=$PM


#-----------------------------------------------------------------------------------------
# Numerical constants
#-----------------------------------------------------------------------------------------
OFTS_ORDER=16 
OFS_ORDER=30

#-----------------------------------------------------------------------------------------
# STORAGE
# FALSE = 0; TRUE = 1
#-----------------------------------------------------------------------------------------
STORAGE=$TRUE


#-----------------------------------------------------------------------------------------
# MODEL
# CRTBP = 0; QBCP = 1; BCP = 2
#-----------------------------------------------------------------------------------------
MODEL=$CRTBP  

#-----------------------------------------------------------------------------------------
# LIBRATION POINT
#-----------------------------------------------------------------------------------------
LIBPOINT=$SEL1

#-----------------------------------------------------------------------------------------
# TYPE OF MANIFOLD
# MAN_CENTER    = 0
# MAN_CENTER_S  = 1
# MAN_CENTER_U  = 2
# MAN_CENTER_US = 3
#-----------------------------------------------------------------------------------------
MANTYPE=$MAN_CENTER

#-----------------------------------------------------------------------------------------
# PM STYLE
# GRAPH = 0; NORMFORM = 1; MIXED = 2
#-----------------------------------------------------------------------------------------
PMS=$GRAPH







