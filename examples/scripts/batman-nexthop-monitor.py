#!/usr/bin/env python3

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
