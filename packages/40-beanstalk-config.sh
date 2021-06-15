#!/bin/bash

echo "Setting beanstalkd ..."
echo 'BEANSTALKD_LISTEN_ADDR=127.0.0.1' > /tmp/beanstalkd;
echo 'BEANSTALKD_LISTEN_PORT=4229' >> /tmp/beanstalkd;
mv /tmp/beanstalkd /etc/default/beanstalkd
