#!/bin/bash
logpath="/logs"

a='auth-server'
q='queue-center'
su='supervise-center'
u='user-center'
f='file-center'
l='log-center'
st='statistics-center'
sy='system-center'
w='work-center'

rm -rf $logpath/$a/$a-info.2019-10*.log
rm -rf $logpath/$q/$q-info.2019-10*.log
rm -rf $logpath/$su/$su-info.2019-10*.log
rm -rf $logpath/$u/$u-info.2019-10*.log
rm -rf $logpath/$f/$f-info.2019-10*.log
rm -rf $logpath/$l/$l-info.2019-10*.log
rm -rf $logpath/$st/$st-info.2019-10*.log
rm -rf $logpath/$sy/$sy-info.2019-10*.log
rm -rf $logpath/$w/$w-info.2019-10*.log
rm -rf $logpath/$a/$a-info.2019-11*.log
rm -rf $logpath/$q/$q-info.2019-11*.log
rm -rf $logpath/$su/$su-info.2019-11*.log
rm -rf $logpath/$u/$u-info.2019-11*.log
rm -rf $logpath/$f/$f-info.2019-11*.log
rm -rf $logpath/$l/$l-info.2019-11*.log
rm -rf $logpath/$st/$st-info.2019-11*.log
rm -rf $logpath/$sy/$sy-info.2019-11*.log
rm -rf $logpath/$w/$w-info.2019-11*.log
