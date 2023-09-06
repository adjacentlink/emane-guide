#!/usr/bin/env python3
#
# Copyright (c) 2023 - Adjacent Link LLC, Bridgewater, New Jersey
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
#
#  * Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
#  * Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in
#    the documentation and/or other materials provided with the
#    distribution.
#  * Neither the name of Adjacent Link LLC nor the names of its
#    contributors may be used to endorse or promote products derived
#    from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
# FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
# COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
# INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
# BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
# LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
# ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.
#

from argparse import ArgumentParser
import urllib.request, json
from collections import defaultdict
from prettytable import PrettyTable
import time

argument_parser = ArgumentParser()

argument_parser.add_argument('node-count',
                             type=int,
                             help="number of nodes.")

argument_parser.add_argument('--node-name-format',
                             type=str,
                             default='node-{}',
                             help="node name format. [default: %(default)s]")

ns = argument_parser.parse_args()

args = vars(ns)

max_threshold_msecs = 1000

table = defaultdict(lambda : defaultdict(lambda : (0,max_threshold_msecs)))

# only three batman nodes in this example
node_ids = range(1,args['node-count'] + 1)

nexthop_table = PrettyTable(padding_width=4)

nexthop_table.field_names = ['Reporter'] + sorted(node_ids)

def id_from_address(address):
    node_id = 0
    if address.startswith('02:02:00:00'):
        mac = [int(x) for x in address.split(':')]
        node_id = mac[4] * 256 + mac[5]

    return node_id

while True:
    table.clear()

    nexthop_table.clear_rows()

    # request the one-hop neighbors from all batman nodes
    for node in node_ids:
        try:
            with urllib.request.urlopen('http://' +
                                        args['node_name_format'].format(node) +
                                        ':5001',
                                        timeout=1) as url:

                for originator in json.load(url):
                    orig_id = id_from_address(originator['orig_address'])

                    if orig_id:
                        neighbor_id = id_from_address(originator['neigh_address'])

                        if neighbor_id:

                            if 'best' in originator and originator['best'] == True:
                                table[node][orig_id] = (neighbor_id,int(originator['last_seen_msecs']))
        except:
            pass

    # build the neighbor display table
    for reporter_node_id in sorted(node_ids):

        row = [reporter_node_id]

        for originator_node_id in sorted(node_ids):

            if originator_node_id != reporter_node_id:
                next_hop, threshold_msecs = table[reporter_node_id][originator_node_id]

                if threshold_msecs < max_threshold_msecs:

                    if originator_node_id != next_hop:
                        row.append(next_hop)
                    else:
                        row.append('*')
                else:
                    # last seen above display threshold
                    row.append('')
            else:
                # self node
                row.append('--')

        nexthop_table.add_row(row)

    # print the matrix, clearing the screen of previous table '\x1b[2J\x1b[H',
    print('\x1b[2J\x1b[H',
          time.strftime('%a, %d %b %Y %H:%M:%S'),
          '\n == B.A.T.M.A.N. Next Hop Matrix ==',
          flush=True)

    print(nexthop_table,flush=True)

    time.sleep(1)
