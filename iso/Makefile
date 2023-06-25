.PHONY: all profile iso clean

PROFILE_BASE = releng
PROFILE_DEST = archlive
PUB_KEY = ~/.ssh/lucasfilm.key.pub

ARCHISO_TMP = /tmp/archiso-tmp

all: iso

profile:
	# Copy base profile
	cp -r /usr/share/archiso/configs/$(PROFILE_BASE) $(PROFILE_DEST)

	# Copy ssh pub key
	mkdir -p $(PROFILE_DEST)/airootfs/root/.ssh
	cat $(PUB_KEY) >> $(PROFILE_DEST)/airootfs/root/.ssh/authorized_keys
	# Set the correct permissions
	patch --forward -r - $(PROFILE_DEST)/profiledef.sh perm_ssh_authorized_keys.patch || true

	# Change the timeout so that it boots immediatly
	patch --forward -r - archlive/grub/grub.cfg grub-timeout-0.patch || true

iso: profile
	sudo mkarchiso -v -w $(ARCHISO_TMP) -o . $(PROFILE_DEST)

clean:
	rm -rf $(PROFILE_DEST)
	sudo rm -rf $(ARCHISO_TMP)
