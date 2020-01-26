#  to receipt of any required approvals from the U.S. Dept. of
#  Energy).  All rights reserved.
#
#  If you have questions about your rights to use or distribute this
#  software, please contact Berkeley Lab's Technology Transfer
#  Department at TTD@lbl.gov.
#
#  NOTICE.  This software is owned by the U.S. Department of Energy.
#  As such, the U.S. Government has been granted for itself and others
#  acting on its behalf a paid-up, nonexclusive, irrevocable,
#  worldwide license in the Software to reproduce, prepare derivative
#  works, and perform publicly and display publicly.  Beginning five
#  (5) years after the date permission to assert copyright is obtained
#  from the U.S. Department of Energy, and subject to any subsequent
#  five (5) year renewals, the U.S. Government is granted for itself
#  and others acting on its behalf a paid-up, nonexclusive,
#  irrevocable, worldwide license in the Software to reproduce,
#  prepare derivative works, distribute copies to the public, perform
#  publicly and display publicly, and to permit others to do so.
#
#  This code is distributed under a BSD style license, see the LICENSE
#  file for complete information.

CC = gcc
RM = rm -f

DPDK_CFLAGS += -O3 \
    -I$(MTCPROOT)/mtcp/include/ \
    -I${MTCPROOT}/io_engine/include/

DPDK_LDLIBS += ${MTCPROOT}/mtcp/lib/libmtcp.a  \
          -L$(RTE_SDK)/$(RTE_TARGET)/lib \
          # -Wl,--whole-archive -Wl,-lrte_mbuf -Wl,-lrte_mempool_ring -Wl,-lrte_mempool -Wl,-lrte_ring -Wl,-lrte_eal -Wl,-lrte_kvargs -Wl,--no-whole-archive -Wl,-export-dynamic -lnuma\
          -lrt -pthread -ldl
DPDK_MACHINE_LINKER_FLAGS=$${RTE_SDK}/$${RTE_TARGET}/lib/ldflags.txt
DPDK_MACHINE_LDFLAGS=$(shell cat ${DPDK_MACHINE_LINKER_FLAGS})
DPDK_LDLIBS += -g -O3 -pthread -lrt -march=native  -lnuma -lpthread -lrt -ldl -lgmp ${DPDK_MACHINE_LDFLAGS}

DPDK_OBJS = ./src/cjson.dpdk.o        ./src/iperf_client_api.dpdk.o \
            ./src/iperf_locale.dpdk.o ./src/iperf_server_api.dpdk.o \
            ./src/iperf_udp.dpdk.o    ./src/main.dpdk.o \
            ./src/tcp_info.dpdk.o     ./src/timer.dpdk.o \
            ./src/units.dpdk.o        ./src/iperf_api.dpdk.o \
            ./src/iperf_error.dpdk.o  ./src/iperf_tcp.dpdk.o \
            ./src/iperf_util.dpdk.o   ./src/net.dpdk.o \
						./src/tcp_window_size.dpdk.o


DPDK_TARGET = dpdk_iperf3
ORIG_TARGET = iperf3

$(DPDK_TARGET):$(DPDK_OBJS)
	$(CC) -o $(DPDK_TARGET) $(DPDK_OBJS) $(DPDK_CFLAGS) $(DPDK_LDLIBS)

$(ORIG_TARGET):$(ORIG_OBJS)
	$(CC) -o $(ORIG_TARGET) $(ORIG_OBJS)

$(DPDK_OBJS):%.dpdk.o:%.c
	$(CC) -c $(DPDK_CFLAGS) $< -o $@

$(OBJS):%.o:%.c
	$(CC) -c $< -o $@

dpdk-iperf: $(DPDK_TARGET)

clean:
	$(RM) $(DPDK_TARGET) $(DPDK_OBJS)
