include $(PATSHOME)/share/atsmake-pre.mk

INCLUDE += -L $(PATSHOME)/ccomp/atslib/lib -latslib -lpq -lpcre -lmicrohttpd
INCLUDE += $(shell pkg-config --cflags json-c)
INCLUDE += $(shell pkg-config --libs json-c)

INCLUDE += -I $(PATSCONTRIB) 
INCLUDE_ATS += -IIATS $(PATSCONTRIB)
PATSCC2=$(PATSCC) $(INCLUDE) $(INCLUDE_ATS)

CC=gcc
CXX=g++

.PHONY: all watch clean

all:: main.out

%.out: %.dats
	$(PATSCC2) -DATS_MEMALLOC_LIBC -O2 $(MALLOCFLAG) -o $@ $< 


include $(PATSHOME)/share/atsmake-post.mk

stats:
	@./stats.sh

router:
	@./make_router.sh

install:
	cat schema.sql | psql photoshare khalile
	cat procedures.sql | psql photoshare khalile
	cat sample.sql | psql photoshare khalile

clean:
	rm -f main.out
	rm -f *_dats.c

