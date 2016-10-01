GLUON_SITEDIR ?= $(GLUONDIR)/site
GLUON_TMPDIR ?= $(GLUONDIR)/tmp

GLUON_SITE_CONFIG := $(GLUON_SITEDIR)/site.conf

GLUON_OUTPUTDIR ?= $(GLUONDIR)/output
GLUON_IMAGEDIR ?= $(GLUON_OUTPUTDIR)/images
GLUON_MODULEDIR ?= $(GLUON_OUTPUTDIR)/modules

export GLUONDIR GLUON_SITEDIR GLUON_TMPDIR GLUON_SITE_CONFIG GLUON_OUTPUTDIR GLUON_IMAGEDIR GLUON_MODULEDIR


GLUON_LEDEDIR = $(GLUONDIR)/lede


$(GLUON_SITEDIR)/site.mk:
	$(error There was no site configuration found. Please check out a site configuration to $(GLUON_SITEDIR))

-include $(GLUON_SITEDIR)/site.mk


GLUON_VERSION := $(shell cd $(GLUONDIR) && git describe --always 2>/dev/null || echo unknown)
export GLUON_VERSION

GLUON_LANGS ?= en
export GLUON_LANGS

export GLUON_ATH10K_MESH
export GLUON_REGION


ifeq ($(GLUON_RELEASE),)
$(error GLUON_RELEASE not set. GLUON_RELEASE can be set in site.mk or on the command line.)
endif
export GLUON_RELEASE


GLUON_TARGETS :=

define GluonTarget
gluon_target := $(1)$$(if $(2),-$(2))
GLUON_TARGETS += $$(gluon_target)
GLUON_TARGET_$$(gluon_target)_BOARD := $(1)
GLUON_TARGET_$$(gluon_target)_SUBTARGET := $(if $(3),$(3),$(2))
endef

GLUON_DEFAULT_PACKAGES := gluon-core firewall ip6tables hostapd-mini
