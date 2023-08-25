#!/bin/bash
echo 'Please input your data:' && qrencode -8 -o /tmp/qr.png && display /tmp/qr.png && rm /tmp/qr.png
