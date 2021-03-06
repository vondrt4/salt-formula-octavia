octavia:
  api:
    enabled: true
    version: ocata
    bind:
      address: 127.0.0.1
      port: 9876
    database:
      engine: mysql
      host: 127.0.0.1
      port: 3306
      name: octavia
      user: octavia
      password: password
    identity:
      engine: keystone
      region: RegionOne
      host: 127.0.0.1
      port: 35357
      user: octavia
      password: password
      tenant: service
    message_queue:
      engine: rabbitmq
      host: 127.0.0.1
      port: 5672
      user: openstack
      password: password
      virtual_host: '/openstack'
      members:
      - host: 127.0.0.1
      - host: 127.0.1.1
      - host: 127.0.2.1
