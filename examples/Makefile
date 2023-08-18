examples= \
 commeffect-01 \
 bentpipe-01 \
 bentpipe-02 \
 ieee80211abg-01 \
 rfpipe-01 \
 tdma-01

all:
	@for example in $(examples); do \
	  $(MAKE) -C $$example;      \
	done

clean:
	@for example in $(examples); do  \
	  $(MAKE) -C $$example clean; \
	done
