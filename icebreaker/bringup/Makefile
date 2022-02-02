# Project config
PROJ = pyfive_test

PROJ_DEPS := no2misc
PROJ_RTL_SRCS := $(addprefix rtl/, \
	dutif_ctrl.v \
	dutif_flash.v \
	io_mapper.v \
	flashemu.v \
	sysmgr.v \
)
PROJ_SIM_SRCS := $(addprefix sim/, \
	spimemio.v \
)
PROJ_TESTBENCHES := \
	flashemu_tb \
	$(NULL)
PROJ_TOP_SRC := rtl/top.v
PROJ_TOP_MOD := top

# Target config
BOARD ?= icebreaker
DEVICE = up5k
PACKAGE = sg48

NEXTPNR_ARGS = --no-promote-globals --pre-pack data/clocks.py --seed 1

# Include default rules
include ../build/project-rules.mk
