#!/bin/bash
for i in {177..182};do ssh 10.0.18.$i "tailf /logs/auth-server/auth-server-info.log";done
