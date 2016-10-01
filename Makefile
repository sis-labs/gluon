all:

LC_ALL:=C
LANG:=C
export LC_ALL LANG

export SHELL:=/usr/bin/env bash

empty:=
space:= $(empty) $(empty)

GLUONDIR:=${CURDIR}

include $(GLUONDIR)/include/gluon.mk


update: FORCE
	@$(GLUONDIR)/scripts/update.sh
	@$(GLUONDIR)/scripts/patch.sh
	@$(GLUONDIR)/scripts/feeds.sh

update-patches: FORCE
	@$(GLUONDIR)/scripts/update.sh
	@$(GLUONDIR)/scripts/update-patches.sh
	@$(GLUONDIR)/scripts/patch.sh

update-feeds: FORCE
	@$(GLUONDIR)/scripts/feeds.sh


include $(GLUONDIR)/targets/targets.mk

LEDEMAKE = $(MAKE) -C $(GLUON_LEDEDIR)

CheckTarget := [ -n '$(GLUON_TARGET)' -a -n '$(GLUON_TARGET_$(GLUON_TARGET)_BOARD)' ] \
	|| (echo -e 'Please set GLUON_TARGET to a valid target. Gluon supports the following targets:$(subst $(space),\n * ,$(GLUON_TARGETS))'; false)


CheckExternal := test -d $(GLUON_LEDEDIR) || (echo 'You don'"'"'t seem to have obtained the external repositories needed by Gluon; please call `make update` first!'; false)


BOARD = $(GLUON_TARGET_$(GLUON_TARGET)_BOARD)
SUBTARGET = $(GLUON_TARGET_$(GLUON_TARGET)_SUBTARGET)
LEDE_TARGET = $(BOARD)$(if $(SUBTARGET),-$(SUBTARGET))

export GLUON_TARGET LEDE_TARGET


prepare-target: FORCE
	@$(CheckExternal)
	@$(CheckTarget)
	( \
		cat $(GLUONDIR)/include/config && \
		echo 'CONFIG_TARGET_$(BOARD)=y' && \
		$(if $(SUBTARGET), \
			echo 'CONFIG_TARGET_$(BOARD)_$(SUBTARGET)=y' && \
		) \
		$(GLUONDIR)/scripts/target_config.sh && \
		echo '$(patsubst %,CONFIG_PACKAGE_%=m,$(sort $(filter-out -%,$(PROFILE_PACKAGES))))' \
			| sed -e 's/ /\n/g' && \
		echo '$(patsubst %,CONFIG_PACKAGE_%=y,$(sort $(filter-out -%,$(GLUON_DEFAULT_PACKAGES) $(GLUON_SITE_PACKAGES))))' \
			| sed -e 's/ /\n/g' && \
		echo '$(patsubst %,CONFIG_LUCI_LANG_%=y,$(GLUON_LANGS))' \
			| sed -e 's/ /\n/g' \
	) > $(GLUON_LEDEDIR)/.config
	+@$(LEDEMAKE) defconfig

all: prepare-target
	+@$(LEDEMAKE)
	$(GLUONDIR)/scripts/copy_output.sh

clean download: prepare-target
	+@$(LEDEMAKE) $@

#manifest: FORCE
#	@[ -n '$(GLUON_BRANCH)' ] || (echo 'Please set GLUON_BRANCH to create a manifest.'; false)
#	@echo '$(GLUON_PRIORITY)' | grep -qE '^([0-9]*\.)?[0-9]+$$' || (echo 'Please specify a numeric value for GLUON_PRIORITY to create a manifest.'; false)
#	@$(CheckExternal)
#
#	( \
#		echo 'BRANCH=$(GLUON_BRANCH)' && \
#		echo 'DATE=$(shell $(GLUON_ORIGOPENWRTDIR)/staging_dir/host/bin/lua $(GLUONDIR)/scripts/rfc3339date.lua)' && \
#		echo 'PRIORITY=$(GLUON_PRIORITY)' && \
#		echo \
#	) > $(GLUON_BUILDDIR)/$(GLUON_BRANCH).manifest.tmp
#
#	+($(foreach GLUON_TARGET,$(GLUON_TARGETS), \
#		( [ ! -e $(BOARD_BUILDDIR)/prepared ] || ( $(GLUONMAKE) manifest GLUON_TARGET='$(GLUON_TARGET)' V=s$(OPENWRT_VERBOSE) ) ) && \
#	) :)
#
#	mkdir -p $(GLUON_IMAGEDIR)/sysupgrade
#	mv $(GLUON_BUILDDIR)/$(GLUON_BRANCH).manifest.tmp $(GLUON_IMAGEDIR)/sysupgrade/$(GLUON_BRANCH).manifest

#dirclean : FORCE
#	for dir in build_dir dl staging_dir tmp; do \
#		rm -rf $(GLUON_ORIGOPENWRTDIR)/$$dir; \
#	done
#	rm -rf $(GLUON_BUILDDIR) $(GLUON_OUTPUTDIR)

FORCE: ;

.PHONY: FORCE
.NOTPARALLEL:
