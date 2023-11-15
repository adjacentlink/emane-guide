#!/usr/bin/env python3
#
# Copyright (c) 2016-2017 - Adjacent Link LLC, Bridgewater, New Jersey
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
#
# * Redistributions of source code must retain the above copyright
#   notice, this list of conditions and the following disclaimer.
# * Redistributions in binary form must reproduce the above copyright
#   notice, this list of conditions and the following disclaimer in
#   the documentation and/or other materials provided with the
#   distribution.
# * Neither the name of Adjacent Link LLC nor the names of its
#   contributors may be used to endorse or promote products derived
#   from this software without specific prior written permission.
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
# See toplevel COPYING for more information.
#
from __future__ import absolute_import, division, print_function

from argparse import ArgumentParser
import sys

from otestpoint.labtools import Stream, Transform, \
    TableColumns, Delta, View

argumentParser = ArgumentParser()

argumentParser.add_argument('endpoint',
                            type=str,
                            help="OpenTestPoint publish endpoint.")

argumentParser.add_argument('-t',
                            '--table',
                            action='store_true',
                            dest='table',
                            help='show table not plot [default: %(default)s].')

ns = argumentParser.parse_args()

args = vars(ns)

# create a stream of data by specifying the probes you want to receive
stream = Stream(args['endpoint'],
                'EMANE.TDMAEventSchedulerRadioModel.Tables.Status.Slot')

# create variables using the Measurement name and attribute
varRxSlotStatusTable = stream.variable('Measurement_emane_tdmaeventschedulerradiomodel_tables_status_slot',
                                       'rxslotstatustable')

varTxSlotStatusTable = stream.variable('Measurement_emane_tdmaeventschedulerradiomodel_tables_status_slot',
                                       'txslotstatustable')

# create a Model
model = stream.model(Delta(Transform(varRxSlotStatusTable,
                                     TableColumns(3))),
                     Delta(Transform(varRxSlotStatusTable,
                                     TableColumns(4,5,6,7,8))),
                     Delta(Transform(varTxSlotStatusTable,
                                     TableColumns(3))),
                     Delta(Transform(varTxSlotStatusTable,
                                     TableColumns(4,5))),
                     labels=['Rx Slot Success',
                             'Rx Slot Error',
                             'Tx Slot Success',
                             'Tx Slot Error'],
                     by_tag=True)

# start the data stream
stream.run()

if args['table']:
    import time
    import pandas as pd

    event_prev = 0

    pd.set_option('display.max_columns', None)
    pd.set_option('display.expand_frame_repr', False)

    while True:
        df,event_cur,(_,timestamp) = model.data(ts=False,
                                                index=None)

        if event_cur != event_prev:
            print("\x1b[2J\x1b[H",time.strftime('%a, %d %b %Y %H:%M:%S',
                                                time.localtime(timestamp)))
            print(df)

            event_prev = event_cur

        time.sleep(1)
else:
    # view the model
    view = View(model,
                kind='bar',
                title='TDMA Slot Activity',
                model_ts=False,
                model_index=None)

    view.show(View.Plot('Node',
                        'Rx Slot Error',
                        'Rx Slot Success',
                        title='Rx Slot Status',
                        ylabel='Count',
                        yticks=list(range(0,201,25)),
                        legend=True),
              View.Plot('Node',
                        'Tx Slot Error',
                        'Tx Slot Success',
                        title='Tx Slot Status',
                        ylabel='Count',
                        yticks=list(range(0,201,25)),
                        legend=True))
