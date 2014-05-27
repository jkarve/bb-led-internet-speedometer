
COMPILER=../../PASM/pasm -b 
FILENAME=other

.PHONY: clean all

all:
	$(COMPILER) $(FILENAME).p


clean: 
	rm -rf $(FILENAME).bin


